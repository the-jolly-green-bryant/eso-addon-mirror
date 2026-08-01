local poukav = LibMarcusModules['Poukav']
local localization = poukav.localization.localized

local consts = poukav.constants
local utils = poukav.utils
local tools = poukav.tools
local help = poukav.help
local ranks = poukav.ranks
local listings = poukav.listings
local donations = poukav.donations

local charLine = consts.CHAR_LINE

--[[
	art\tutorial\tutorial_illo_status_afk.dds
art\tutorial\tutorial_illo_status_dnd.dds
art\tutorial\tutorial_illo_status_offline.dds
art\tutorial\tutorial_illo_status_online.dds

esoui\art\contacts\social_status_afk.dds
esoui\art\contacts\social_status_dnd.dds
esoui\art\contacts\social_status_highlight.dds
esoui\art\contacts\social_status_offline.dds
esoui\art\contacts\social_status_online.dds
]]
local statusMap = {
	[PLAYER_STATUS_AWAY] = 'esoui/art/contacts/social_status_afk.dds',
	[PLAYER_STATUS_DO_NOT_DISTURB] = 'esoui/art/contacts/social_status_dnd.dds',
	[PLAYER_STATUS_OFFLINE] = 'esoui/art/contacts/social_status_offline.dds',
	[PLAYER_STATUS_ONLINE] = 'esoui/art/contacts/social_status_online.dds'
}

poukav.state = {
	isScanning = false,
	isPaused = false, -- scanning interrupted
	selectedGuild = { id = nil, name = nil },
	isTradingHouseOpened = false,
	page = 0,
	scanBuffer = {},
	--[[
		[guilId] = {
			lastScanned = nil,
			scanResults = {},
		}
	]]
	guildCategoryCaches = {},
	guildCategoryCacheInitialized = {},
	initialized = false
}

local localState = poukav.state

SLASH_COMMANDS["/poukav"] = function(extra)
	local nameColor = localState.data.memberTextColor
    utils.output(charLine)
	utils.output(localization.EXECUTING_POUKAV_COMMAND, extra)

	local params = utils.split(extra)
	local command = table.remove(params, 1)
    local noResults = true

    if not command then
        utils.output(localization.NO_COMMAND_WAS_TYPED)
		utils.output(localization.HOWTO_HELP)
		utils.output(charLine)
        return
    end
    command = command:lower()
	if command == localization.COMMAND_HELP then
		local helpCommand = params[1]
		if (help.processCommand(helpCommand)) then
			return
		end
	end
	if (command == localization.COMMAND_SEARCH) then
		if not params[1] then
			utils.output(localization.SEARCH_COMMAND_REQUIRES_SEARCH_TYPE)
			return
		end
		params[1] = params[1]:lower()
		if params[1] == localization.COMMAND_SEARCH_MEMBER then
			local guildId = tools.guildCheck(localization, params[2])
			if not guildId then return end
			-- last parameter: true means return all
			local userIds = tools.findUserId(guildId, params[3], true)
            if (#userIds == 0) then
                utils.output(localization.NO_GUILD_MEMBER_FOUND, params[2])
			else
				for _, v in ipairs(userIds) do
					utils.output(utils.cFormat(v, nameColor))
				end
            end
            utils.output(charLine)
			return
		end
		if params[1] == localization.COMMAND_SEARCH_GUILD then

			local guildId, guildLabel = tools.findGuild(params[2])
				
			if (not guildId) then
				utils.output(localization.NO_GUILD_FOUND, params[2])
			else
				utils.output(guildLabel .. ' (' .. tostring(guildId) .. ')')
			end
            utils.output(charLine)
			return
		end
		utils.output(localization.UNKNOWN_SEARCH_TYPE, params[1])
		utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_GUILD) then
		local guildSearchName = params[1]
		local userSearchName = params[2]
		local startTime, endTime = utils.getInterval(params[3])
		local anonymize = params[4] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName, anonymize)
		if not userId then return end
		tools.outputInterval(localization, startTime, endTime)
		local key = tools.getGuilCategoryCacheKey(guildId, 'guild')
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache

		-- local categoryCache = LibHistoire.internal.historyCache:GetOrCreateCategoryCache(guildId, consts.GUILD_EVENT_CATEGORY_GUILD)
		-- local numEvents = categoryCache:GetNumEvents()

		for i = 1, numEvents do
			local event = categoryCache[i]

			-- local event = categoryCache:GetEvent(i)

			local nameMatched = utils.compareNames(userId, event.info[consts.INFO_USER_NAME]) or utils.compareNames(userId, event.info[consts.INFO_TARGET_USER_NAME])
			local periodMatched = tools.eventTimeMatchesPeriod(event, startTime, endTime)
			if (nameMatched and periodMatched) then
				utils.output(tools.eventToFormatArgs(localization, event, anonymize))
                noResults = false
			end
			
		end
        if (noResults) then
            utils.output(localization.NO_GUILD_HISTORY_FOUND, params[1], params[2], params[3] and (' (' ..params[3] .. ')') or '')
        end
        utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_BANK) then
		local guildSearchName = params[1]
		local userSearchName = params[2]
		local startTime, endTime = utils.getInterval(params[3])
        local filterFlags = params[4]
		local anonymize = params[5] == '@'
		
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName)
		if not userId then return end
		tools.outputInterval(localization, startTime, endTime)
		local key = tools.getGuilCategoryCacheKey(guildId, 'bank')
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache
		for i = 1, numEvents do
			local event = categoryCache[i]
			if (utils.compareNames(userId, event.info[consts.INFO_USER_NAME])) then
				local timeMatch = tools.eventTimeMatchesPeriod(event, startTime, endTime)
                if tools.matchFilterFlags(event, filterFlags) and timeMatch then
				    utils.output(tools.eventToFormatArgs(localization, event, anonymize))
                    noResults = false
                end
			end
		end
        if (noResults) then
            utils.output(localization.NO_BANK_HISTORY_FOUND, utils.applyAnonymize(params[1], anonymize), utils.applyAnonymize(params[2], anonymize), params[3] and (' (' ..params[3] .. ')') or '')
        end
        utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_SALES) then
		local guildSearchName = params[1]
		local userSearchName = params[2]
		local startTime, endTime = utils.getInterval(params[3])
		local anonymize = params[4] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName, anonymize)
		if not userId then return end
		tools.outputInterval(localization, startTime, endTime)
		local key = tools.getGuilCategoryCacheKey(guildId, 'sales')
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache
		for i = 1, numEvents do
			local event = categoryCache[i]
			if (utils.compareNames(userId, event.info[consts.INFO_USER_NAME])) then
				
				local timeMatch = tools.eventTimeMatchesPeriod(event, startTime, endTime)

				if (timeMatch) then
					utils.output(tools.eventToFormatArgs(localization, event, anonymize))
					noResults = false
				end
			end
		end
        if (noResults) then
            utils.output(
				localization.NO_SALES_HISTORY_FOUND,
				utils.applyAnonymize(params[1], anonymize), utils.applyAnonymize(params[2], anonymize), params[3] and (' (' ..params[3] .. ')') or ''
			)
        end
        utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_PURCHASES) then
		local guildSearchName = params[1]
		local userSearchName = params[2]
		local startTime, endTime = utils.getInterval(params[3])
		local anonymize = params[4] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName, anonymize)
		if not userId then return end
		tools.outputInterval(localization, startTime, endTime)
		local key = tools.getGuilCategoryCacheKey(guildId, 'sales')
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache
		for i = 1, numEvents do
			local event = categoryCache[i]
			if (utils.compareNames(userId, event.info[consts.INFO_TARGET_USER_NAME])) then
				
				local timeMatch = tools.eventTimeMatchesPeriod(event, startTime, endTime)

				if (timeMatch) then
					utils.output(tools.eventToFormatArgs(localization, event, anonymize))
					noResults = false
				end
			end
		end
        if (noResults) then
            utils.output(
				localization.NO_PURCHASES_HISTORY_FOUND,
				utils.applyAnonymize(params[1], anonymize), utils.applyAnonymize(params[2], anonymize), params[3] and (' (' ..params[3] .. ')') or ''
			)
        end
        utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_ITEM) then
		local searchKind = params[1]
		local guildSearchName = params[2]
		local itemLink = params[3]
		local startTime, endTime = utils.getInterval(params[4])
        local filterFlags = params[4]
		local anonymize = params[5] == '@'

		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName)
		if not guildId then return end

		tools.outputInterval(localization, startTime, endTime)
		local key = tools.getGuilCategoryCacheKey(guildId, 'sales')
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache
		for i = 1, numEvents do
			local event = categoryCache[i]
			if event.info[consts.INFO_EVENT_TYPE] == consts.EVENT_TYPE_DEPOSITED_ITEM or event.info[consts.INFO_EVENT_TYPE] == consts.EVENT_TYPE_WITHDREW_ITEM then
				if (utils.compareLinks(itemLink, event.info[searchKind == 'bank' and consts.INFO_BANK_ITEM_LINK or consts.INFO_SALES_ITEM_LINK])) then
					local timeMatch = tools.eventTimeMatchesPeriod(event, startTime, endTime)
					if tools.matchFilterFlags(event, filterFlags) and timeMatch then
						utils.output(tools.eventToFormatArgs(localization, event, anonymize))
						noResults = false
					end
				end
			end
		end
        if (noResults) then
            utils.output(localization.NO_BANK_HISTORY_FOUND, utils.applyAnonymize(params[1], anonymize), utils.applyAnonymize(params[2], anonymize), params[3] and (' (' ..params[3] .. ')') or '')
        end
        utils.output(charLine)
		return
	end

	if (command == localization.COMMAND_TOTAL) then
		local totalKind = params[1]
        if (totalKind ~= localization.COMMAND_BANK and totalKind ~= localization.COMMAND_SALES) then
            utils.output(localization.UNKNOWN_TOTAL_TYPE, totalKind)
			utils.output(localization.HOWTO_HELP)
			utils.output(charLine)
            return
        end
		local guildSearchName = params[2]
		local userSearchName = params[3]
		local periodParam = params[4]
		local anonymize = params[5] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName, anonymize)
		if not userId then return end
		local startTime, endTime = utils.getInterval(periodParam)
		tools.outputInterval(localization, startTime, endTime)
        tools.getTotalsAsync(totalKind == localization.COMMAND_BANK and 'bank' or 'sales', guildId, userId, startTime, endTime, nil, function(totals)
			if not totals then
				utils.output(localization.WAIT_FOR_INITIALIZATION)
				return true
			end
			local goldIcon = utils.formatIcon(consts.GOLD_ICON)
			local formattedUserName = utils.cFormat(utils.applyAnonymize(userId, anonymize), nameColor)
			if totalKind == localization.COMMAND_SALES then
				utils.output(
					localization.SALES_TOTAL,
					formattedUserName,
					utils.formatGold(totals.sold),
					utils.formatGold(totals.taxes),
					utils.formatGold(totals.bought)
				)
			else
				utils.output(
					localization.BANK_TOTAL,
					formattedUserName,
					utils.formatGold(totals.gold.d),
					utils.formatGold(totals.gold.w),
					utils.formatGold(totals.gold.t, true),
					utils.formatGold(totals.items.d),
					utils.formatGold(totals.items.w),
					utils.formatGold(totals.items.t, true)
				)
			end
			
			utils.output(charLine)		
		end)
		
		return
	end

    if (command == localization.COMMAND_WHOSUS) then
        local guildSearchName = params[1]
		local periodParam = params[2]
		local rankParam = params[3]
		local anonymize = params[4] == '@'
        local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local startTime, endTime = utils.getInterval(periodParam)
		tools.outputInterval(localization, startTime, endTime)
		local sorted = {}
		local sortedCount = 0
		local memberList = tools.collectMembers(guildId, rankParam, startTime)
		tools.getTotalsAsync('bank', guildId, memberList, startTime, endTime, nil, function(result)
			if not result then
				utils.output(localization.WAIT_FOR_INITIALIZATION)
				return true
			end
			for k, u in pairs(result) do
				local balance = u.gold.t + u.items.t
				if balance < localState.data.susBalanceThreashold then
					sortedCount = sortedCount + 1
					sorted[sortedCount] = { balance = balance, userId = u.member.userId, note = u.member.note, rankIndex = u.member.rankIndex, secsSinceLogoff = u.member.secsSinceLogoff, totalBalance = u.totalItems.t + u.totalGold.t, goldBalance = u.gold.t }
					noResults = false
				end
			end
			table.sort(sorted, function(a, b)
				return a.balance > b.balance
			end)
			local sortedCount = #sorted
			for i = 1, sortedCount do
				local item = sorted[i]
				local balance = item.balance
	
				utils.output(localization.IS_SUS_BECAUSE, utils.applyAnonymize(item.userId, anonymize), utils.formatGold(balance, true))
			end
			localState.data.report = sorted
			if (noResults) then
				utils.output(localization.NO_SUS_FOUND)
			end
			utils.output(charLine)			
		end)
		return
    end

	if command == localization.COMMAND_LISTINGS then
		local guildSearchName = params[1]
		local userSearchName = params[2]
		local force = params[3] == 'f'
		local anonymize = params[3] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		local userId = tools.userCheck(localization, guildId, userSearchName, anonymize)
		if not userId then return end
		listings.processListingsCommand(guildId, userId, force, anonymize)
		return
	end

	if command == localization.COMMAND_EMPTY_LISTINGS then
		local guildSearchName = params[1]
		local rankSearchName = params[2]
		local force = params[3] == 'f'
		local anonymize = params[3] == '@'
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end

		listings.processEmptyListingsCommand(guildId, rankSearchName, force, anonymize)
		return
	end
	
	if command == localization.COMMAND_RANKS then
		local guildSearchName = params[1]
		local anonymize = params[2] == '@'
		local preview = params[2] == '?'
		local simulate = localState.data.guilds.simulateRankEvalutation
		local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
		-- check permission
		if not simulate then
			-- return
		end
		if (ranks.processCommand(guildId, simulate, anonymize, preview)) then
			return
		end
		
	end

	if command == localization.COMMAND_DONATIONS then
		local guildSearchName = params[1]
		local rankSearchName = params[2]
		local anonymize = params[3] == '@'
		
		donations.processCommand(localization, guildSearchName, rankSearchName, anonymize)		

		return
		
	end
	utils.output(localization.UNKNOWN_COMMAND, command)
	utils.output(localization.HOWTO_HELP)
	utils.output(charLine)

end

local categoryNameIdMap = {
	['guild'] = consts.GUILD_EVENT_CATEGORY_GUILD,
	['bank'] = consts.GUILD_EVENT_CATEGORY_BANK,
	['sales'] = consts.GUILD_EVENT_CATEGORY_SALES,
	['alliance'] = consts.GUILD_EVENT_CATEGORY_ALLIANCE,
}

--- Initialize the addon
local function initialize()
	-- attaches kiosk listeners
	listings.initialize()
	-- Saved data, uses default static data if there is no saved data
	localState.data = ZO_SavedVars:NewAccountWide(
		"MarcusPoukavData", 1, nil,
		{
			susBalanceThreashold = 5000,
			debtDurationThreashold = 7,
			ignorePlayerInactivityThreashold = 30,
			report = {},
			scanExpirationTime = 10,
			accountingWeekStartDay = 3,
			accountingDayStartHour = 16,
			textColor = { 1, 1, 1, 1 },
			memberTextColor = { 120/255, 200/255, 255/255, 1},
			localizationEnabled = true,
			noKioskExternalSalesRatioThreashold = 75
		}
	)
	-- localState.data.guilds = nil
	if localState.data.localizationEnabled then
		localization = poukav.localization.localized
	else
		localization = poukav.localization.default
	end
	poukav.settingsMenu.createMenuPanel()

	-- EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED (*integer* _guildId_, *string* _displayName_, *integer* _oldStatus_, *integer* _newStatus_)
	-- EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(eventCode, guildId, userId, oldStatus, newStatus)
		
	-- 	-- local statusMap = {
	-- 	-- 	[ONLINE_STATUS_ACTIVE] = 'ONLINE_STATUS_ACTIVE',
	-- 	-- 	[ONLINE_STATUS_AFK] = 'ONLINE_STATUS_AFK',
	-- 	-- 	[ONLINE_STATUS_OFFLINE] = 'ONLINE_STATUS_OFFLINE'
	-- 	-- }
	-- 	local statusMap = {
	-- 		[PLAYER_STATUS_AWAY] = 'PLAYER_STATUS_AWAY',
	-- 		[PLAYER_STATUS_DO_NOT_DISTURB] = 'PLAYER_STATUS_DO_NOT_DISTURB',
	-- 		[PLAYER_STATUS_OFFLINE] = 'PLAYER_STATUS_OFFLINE',
	-- 		[PLAYER_STATUS_ONLINE] = 'PLAYER_STATUS_ONLINE'
	-- 	}
	-- 	local guildName = GetGuildName(guildId)
	-- 	utils.output('%s (%s) status changed to %s', utils.cFormat(userId, localState.data.memberTextColor), guildName, statusMap[newStatus] or 'Unknown')
	-- 	-- displayName, note, rankIndex, status, secsSinceLogoff
	-- 	cachedGetGuildMemberInfo()
	-- end)
end

local function handleAddonLoaded(event, addonName)
    if addonName == 'MarcusPoukav' then
        initialize()
    end
end

EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_ADD_ON_LOADED, handleAddonLoaded)
local function onPlayerActivated(_, initial)
    EVENT_MANAGER:UnregisterForEvent('MarcusPoukav', EVENT_PLAYER_ACTIVATED)
    poukav.state.initialized = true
	utils.flushBufferedOutput()
end
EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_PLAYER_ACTIVATED, onPlayerActivated)
local function fireGuildCategoryCacheInitialized(guildId, categoryName)
	local _, guildName = tools.findGuild(guildId)
	utils.outputLater(localization.GUILD_CATEGORY_DATA_INITIALIZED, guildName, categoryName)
end

LibHistoire:RegisterCallback(LibHistoire.callback.INITIALIZED, function()
	
	local function SetUpListener(guildId, categoryName)
		local listener = LibHistoire:CreateGuildHistoryListener(guildId, categoryNameIdMap[categoryName])
		local _, guildName = tools.findGuild(guildId)
		utils.outputLater(localization.INITIALIZING_GUILD_CATEGORY_DATA, guildName, categoryName)
		local key = tools.getGuilCategoryCacheKey(guildId, categoryName)
		-- listener:SetTimeFrame(startTime, endTime)
		listener:SetNextEventCallback(
			function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)
				local eventCount, processingSpeed, timeLeft = listener:GetPendingEventMetrics()

				--[[
					INFO_EVENT_TYPE = 1,
					INFO_EVENT_TIME = 2,
					INFO_USER_NAME = 3,
					INFO_TARGET_USER_NAME = 4,
					INFO_GOLD_AMOUNT = 4,
					INFO_BANK_ITEM_QUANTITY = 4,
					INFO_SALES_ITEM_QUANTITY = 5,
					INFO_BANK_ITEM_LINK = 5,
					INFO_SALES_ITEM_LINK = 6,
					INFO_RANK_NAME = 5,
					INFO_SALES_TOTAL_PRICE = 7,
					INFO_SALES_TAX_COLLECTED = 8,
				]]
				local event = {
					info = {
						eventType,
						eventTime,
						param1,
						param2,
						param3,
						param4,
						param5,
						param6,
						eventId
					},
					GetEventTime = function(self)
						return self.info[2]	
					end
				}
				
				local bucket = localState.guildCategoryCaches[key]
				if not bucket then
					bucket = {}
					localState.guildCategoryCaches[key] = bucket
					
				end
				-- bucket[Id64ToString(eventId)] = event
				table.insert(bucket, event)
				if (--[[processingSpeed ~= -1 and ]]eventCount == 0 and not localState.guildCategoryCacheInitialized[key]) then
					localState.guildCategoryCacheInitialized[key] = true
					fireGuildCategoryCacheInitialized(guildId, categoryName)
					
				end
		end)
		
		listener:Start()
		-- empty caches will never send event so call fireGuildCategoryCacheInitialized now
		if listener:GetPendingEventMetrics() == 0 then
			localState.guildCategoryCacheInitialized[key] = true
			fireGuildCategoryCacheInitialized(guildId, categoryName)
		end
	end
	local numGuild = GetNumGuilds()
	for i = 1, numGuild do
		local guildId = GetGuildId(i)
		SetUpListener(guildId, 'guild')
		SetUpListener(guildId, 'bank')
		SetUpListener(guildId, 'sales')
	end
end)
--[[

/poukav listings marché bixente
GuildSetRank(guildId, userId, rankIndex)
]]