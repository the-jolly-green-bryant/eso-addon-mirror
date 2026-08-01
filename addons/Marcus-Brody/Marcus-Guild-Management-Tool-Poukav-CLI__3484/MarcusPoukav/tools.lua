local poukav = LibMarcusModules['Poukav']
local consts = poukav.constants
local utils = poukav.utils

local charLine = consts.CHAR_LINE

local function eventToFormatArgs(localization, event, anonymize)
    local localState = poukav.state
    local nameColor = localState.data.memberTextColor
	local info = event.info
	local userName = utils.cFormat(utils.applyAnonymize(info[consts.INFO_USER_NAME], anonymize), nameColor)
	local targetUserName = type(info[consts.INFO_TARGET_USER_NAME]) == 'string' and utils.cFormat(utils.applyAnonymize(info[consts.INFO_TARGET_USER_NAME], anonymize), nameColor)
	local rankName = utils.trim(info[consts.INFO_RANK_NAME])
	local formattedTime = os.date('%c', info[consts.INFO_EVENT_TIME])
	local eventType = info[consts.INFO_EVENT_TYPE]
	local goldIcon = utils.formatIcon(consts.GOLD_ICON)
	if (eventType == consts.EVENT_TYPE_INVITED) then
		return localization.LOG_EVENT_TYPE_INVITED, formattedTime, userName, targetUserName
	end
	if (eventType == consts.EVENT_TYPE_PROMOTED) then
		return localization.LOG_EVENT_TYPE_PROMOTED, formattedTime, userName, targetUserName, rankName
	end
	if (eventType == consts.EVENT_TYPE_DEMOTED) then
		return localization.LOG_EVENT_TYPE_DEMOTED, formattedTime, userName, targetUserName, rankName
	end
	if (eventType == consts.EVENT_TYPE_JOINED) then
		return localization.LOG_EVENT_TYPE_JOINED, formattedTime, userName, (targetUserName == 'Unknown' and '') or '(invited by ' .. targetUserName .. ')'
	end
	if (eventType == consts.EVENT_TYPE_LEFT) then
		return localization.LOG_EVENT_TYPE_LEFT, formattedTime, userName
	end
	if (eventType == consts.EVENT_TYPE_KICKED) then
		return localization.LOG_EVENT_TYPE_KICKED, formattedTime, userName, targetUserName
	end
    if (eventType == consts.EVENT_TYPE_DEPOSITED_ITEM) then
		return localization.LOG_EVENT_TYPE_DEPOSED_ITEM, formattedTime, userName, info[consts.INFO_BANK_ITEM_QUANTITY], info[consts.INFO_BANK_ITEM_LINK], utils.formatGold(info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK]))
	end
    if (eventType == consts.EVENT_TYPE_WITHDREW_ITEM) then
		return localization.LOG_EVENT_TYPE_WITHDREW_ITEM, formattedTime, userName, info[consts.INFO_BANK_ITEM_QUANTITY], info[consts.INFO_BANK_ITEM_LINK], utils.formatGold(info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK]))
	end
    if (eventType == consts.EVENT_TYPE_DEPOSITED_GOLD) then
		return localization.LOG_EVENT_TYPE_DEPOSITED_GOLD, formattedTime, userName, utils.formatGold(info[consts.INFO_BANK_ITEM_QUANTITY])
	end
    if (eventType == consts.EVENT_TYPE_WITHDREW_GOLD) then
		return localization.LOG_EVENT_TYPE_WITHDREW_GOLD, formattedTime, userName, utils.formatGold(info[consts.INFO_BANK_ITEM_QUANTITY])
	end
	if (eventType == consts.EVENT_TYPE_EDITED_MESSAGE_OF_THE_DAY) then
		return localization.LOG_EVENT_TYPE_EDITED_MESSAGE_OF_THE_DAY, formattedTime, userName
	end
	if (eventType == consts.EVENT_TYPE_DECLINED_APPLICATION) then
		return localization.LOG_EVENT_TYPE_DECLINED_APPLICATION, formattedTime, userName, targetUserName
	end
	if (eventType == consts.EVENT_TYPE_ACCEPTED_APPLICATION) then
		return localization.LOG_EVENT_TYPE_ACCEPTED_APPLICATION, formattedTime, userName, targetUserName
	end
	if (eventType == consts.EVENT_TYPE_LISTED_THE_GUILD) then
		return localization.LOG_EVENT_TYPE_LISTED_THE_GUILD, formattedTime, userName
	end
	if (eventType == consts.EVENT_TYPE_SOLD_ITEMS) then
		return 
			localization.LOG_EVENT_TYPE_SOLD_ITEMS,
			formattedTime, userName,
			info[consts.INFO_SALES_ITEM_QUANTITY], info[consts.INFO_SALES_ITEM_LINK],
			targetUserName, utils.formatGold(info[consts.INFO_SALES_TOTAL_PRICE]),
			utils.formatGold(info[consts.INFO_SALES_TAX_COLLECTED])
	end
	local eventStr = ''
	for j = 1, #event.info do
		eventStr = eventStr .. ((j == 1 and '') or ', ') .. event.info[j]
	end
	return localization.UNHANDLED_EVENT_TYPE, tostring(eventType), '\n', eventStr
end

local guildMemberCache = {}
local function cachedGetGuildMemberInfo(guildId, userIndex)
	-- THIS IS PROBABLY A VERY BAD IDEA
	-- userIndex is not constant

	-- local bucket = guildMemberCache[guildId]
	-- if not bucket then
	-- 	bucket = {}
	-- 	guildMemberCache[guildId] = bucket
	-- end
	-- local userData = bucket[userIndex]
	-- if not userData then
	-- 	-- displayName, note, rankIndex, status, secsSinceLogoff
	-- 	userData = utils.pack(GetGuildMemberInfo(guildId, userIndex))
	-- 	table.insert(userData, userIndex)
	-- 	bucket[userIndex] = userData
	-- end
	-- return unpack(userData)

	return GetGuildMemberInfo(guildId, userIndex)
end

local function invalidateGuildMemberInfo(guildId, userIndex)
	local bucket = guildMemberCache[guildId]
	if not bucket then
		bucket = {}
		guildMemberCache[guildId] = bucket
	end
	bucket[userIndex] = nil
end

local function findGuild(input)
	
	local isId = type(input) == 'number'
	if not input or utils.trim(input) == '' then
		return
	end
	if isId then
		local label = GetGuildName(input)
		return input, label
	end
	local normSearch = string.lower(string.gsub(input, '[^%w]', ''))
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		local guildId = GetGuildId(i)
		local label = GetGuildName(guildId)
		local normName = string.lower(string.gsub(label, '[^%w]', ''))
		if (string.find(normName, normSearch, 1, true)) then
			return guildId, label
		end
	end
end

local function findUserId(guildId, str, returnAll)
	if (str == '*' and not returnAll) then
		return '*'
	end
	local res
	if returnAll then
		res = {}
	end
	local numMembers = GetGuildInfo(guildId)
	for i = 1, numMembers do
		local userId, note, rankIndex, playerStatus, secsSinceLogoff, memberIndex = cachedGetGuildMemberInfo(guildId, i) 
		if utils.compareNames(str, userId) then
			if not returnAll then
				return userId
			else
				table.insert(res, userId)
			end
			
		end
	end
	return res
end

local function getNote(guildId, userId)
	local index = GetGuildMemberIndexFromDisplayName(guildId, userId)
	local _, note = GetGuildMemberInfo(guildId, index)
	return note
end


local function matchFilterFlags(event, filterFlags) 
    if not filterFlags or filterFlags == '' or filterFlags == '*' then
        return true
    end
    
    local hasD = not not filterFlags:match('D')
    local hasW = not not filterFlags:match('W')
    local hasI = not not filterFlags:match('I')
    local hasG = not not filterFlags:match('G')
    -- utils.output('hasG: %t, hasI: %t, hasD: %t, hasW: %t', hasG, hasI, hasD, hasW)
    if (hasG and hasI and hasW and hasD) then
        return true
    end
    local flavourDontCare = (hasG and hasI) or (not hasG and not hasI)

    local dirDontCare = (hasW and hasD) or (not hasW and not hasD)

    local info = event.info
    local eventType = info[consts.INFO_EVENT_TYPE]

    local isG = eventType == consts.EVENT_TYPE_DEPOSITED_GOLD or eventType == consts.EVENT_TYPE_WITHDREW_GOLD
    local isI = eventType == consts.EVENT_TYPE_DEPOSITED_ITEM or eventType == consts.EVENT_TYPE_WITHDREW_ITEM
    local isD = eventType == consts.EVENT_TYPE_DEPOSITED_GOLD or eventType == consts.EVENT_TYPE_DEPOSITED_ITEM
    local isW = eventType == consts.EVENT_TYPE_WITHDREW_GOLD or eventType == consts.EVENT_TYPE_WITHDREW_ITEM
    -- utils.output('isG: %t, isI: %t, isD: %t, isW: %t', isG, isI, isD, isW)
    if flavourDontCare then
        return isD == hasD
    end

    if dirDontCare then
        -- utils.output('returning comp of %t and %t', isG, hasG)
        return isG == hasG
    end

    return isD == hasD and isW == hasW and isG == hasG and isI == hasI
end

local function eventTimeMatchesPeriod(event, startTime, endTime)
	local time = event:GetEventTime()
	return (not startTime or time >= startTime) and (not endTime or time <= endTime)
end

local function getGuilCategoryCacheKey(guildId, categoryName)
	local serverName = GetWorldName()
	return serverName .. ':' .. tostring(guildId) .. ':' .. tostring(categoryName)
end

local typeToCategory = {
	['bank'] = consts.GUILD_EVENT_CATEGORY_BANK,
	['sales'] = consts.GUILD_EVENT_CATEGORY_SALES,
	['alliance'] = consts.GUILD_EVENT_CATEGORY_ALLIANCE,
}

local function processEventForTotal(event, isMultiple, res, userId, startTime, endTime, filterFlags, totalType, inGuild, external)
	

	local nameMatch
	if isMultiple then
		nameMatch = res[event.info[consts.INFO_USER_NAME]] or res[event.info[consts.INFO_TARGET_USER_NAME]]
	else
		nameMatch = userId == '*' or utils.compareNames(userId, event.info[consts.INFO_USER_NAME]) or utils.compareNames(userId, event.info[consts.INFO_TARGET_USER_NAME])
	end
	local isBuying = not isMultiple and userId ~= '*' and utils.compareNames(userId, event.info[consts.INFO_TARGET_USER_NAME])
	local timeMatch = eventTimeMatchesPeriod(event, startTime, endTime)
	local filterMatch = matchFilterFlags(event, filterFlags)
	if (nameMatch and filterMatch) then
		local info = event.info
		
		local eventType = info[consts.INFO_EVENT_TYPE]
		local userBucket = userId == '*' and res['*'] or res[event.info[consts.INFO_USER_NAME]]
		local targetUserBucket = userId ~= '*' and res[event.info[consts.INFO_TARGET_USER_NAME]]
		 
		if (totalType == 'sales') then
			local totalSalePrice = info[consts.INFO_SALES_TOTAL_PRICE]
			if (eventType == consts.EVENT_TYPE_SOLD_ITEMS) then
				if userBucket then
					if timeMatch then
						userBucket.sold = userBucket.sold + totalSalePrice
						userBucket.taxes = userBucket.taxes + info[consts.INFO_SALES_TAX_COLLECTED]
					end
					userBucket.totalSold = userBucket.totalSold + totalSalePrice
					userBucket.totalTaxes = userBucket.totalTaxes + info[consts.INFO_SALES_TAX_COLLECTED]
				end
				if targetUserBucket then
					if timeMatch then
						targetUserBucket.bought = targetUserBucket.bought + totalSalePrice
						inGuild = inGuild + totalSalePrice
					end
					targetUserBucket.totalBought = targetUserBucket.totalBought + totalSalePrice
					
				else
					-- external
					if timeMatch then
						external = external + totalSalePrice
					end
				end
				
			end
		else
			if (eventType == consts.EVENT_TYPE_DEPOSITED_GOLD) then
				if timeMatch then
					userBucket.gold.d = userBucket.gold.d + info[consts.INFO_GOLD_AMOUNT]
					userBucket.gold.t = userBucket.gold.t + info[consts.INFO_GOLD_AMOUNT]
				end
				userBucket.totalGold.d = userBucket.totalGold.d + info[consts.INFO_GOLD_AMOUNT]
				userBucket.totalGold.t = userBucket.totalGold.t + info[consts.INFO_GOLD_AMOUNT]
			elseif (eventType == consts.EVENT_TYPE_WITHDREW_GOLD) then
				if timeMatch then
					userBucket.gold.w = userBucket.gold.w + info[consts.INFO_GOLD_AMOUNT]
					userBucket.gold.t = userBucket.gold.t - info[consts.INFO_GOLD_AMOUNT]
				end
				userBucket.totalGold.w = userBucket.totalGold.w + info[consts.INFO_GOLD_AMOUNT]
				userBucket.totalGold.t = userBucket.totalGold.t - info[consts.INFO_GOLD_AMOUNT]
			elseif (eventType == consts.EVENT_TYPE_DEPOSITED_ITEM) then
				if timeMatch then
					userBucket.items.d = userBucket.items.d + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
					userBucket.items.t = userBucket.items.t + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
				end
				userBucket.totalItems.d = userBucket.totalItems.d + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
				userBucket.totalItems.t = userBucket.totalItems.t + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
			elseif (eventType == consts.EVENT_TYPE_WITHDREW_ITEM) then
				if timeMatch then
					userBucket.items.w = userBucket.items.w + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
					userBucket.items.t = userBucket.items.t - info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
				end
				userBucket.totalItems.w = userBucket.totalItems.w + info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
				userBucket.totalItems.t = userBucket.totalItems.t - info[consts.INFO_BANK_ITEM_QUANTITY] * utils.getAveragePrice(info[consts.INFO_BANK_ITEM_LINK])
			end
		end
		
	end
	return inGuild, external
end
--- func desc
---@param totalType 'bank' or 'sales'
---@param guildId number
---@param userId string or table
---@param startTime number
---@param endTime number
---@param filterFlags string
---@return table{ gold = number, items = number, bought = number, taxes = number, sold = number, totalGold = number, totalItems = number, totalBought = number, totalTaxes = number, totalSold = number}, number
local function getTotals(totalType, guildId, userId, startTime, endTime, filterFlags)
	local isMultiple = type(userId) == 'table'
	local res = {}
	if isMultiple then
		res = {}
		for _, v in ipairs(userId) do
			res[v.userId] = {
				gold = { d = 0, w = 0, t = 0 },
				items = { d = 0, w = 0, t = 0 },
				bought = 0,
				taxes = 0,
				sold = 0,
				totalGold = { d = 0, w = 0, t = 0 },
				totalItems = { d = 0, w = 0, t = 0 },
				totalBought = 0,
				totalTaxes = 0,
				totalSold = 0,
				member = v
			}
		end
	else
		res[userId] = {
			gold = { d = 0, w = 0, t = 0 },
			items = { d = 0, w = 0, t = 0 },
			bought = 0,
			taxes = 0,
			sold = 0,
			totalGold = { d = 0, w = 0, t = 0 },
			totalItems = { d = 0, w = 0, t = 0 },
			totalBought = 0,
			totalTaxes = 0,
			totalSold = 0,
		}
	end
	local key = getGuilCategoryCacheKey(guildId, totalType)
	local initialized = poukav.state.guildCategoryCacheInitialized[key]
	if not initialized then
		return
	end
    local categoryCache = poukav.state.guildCategoryCaches[key]
    local numEvents = #categoryCache

	-- local categoryCache = LibHistoire.internal.historyCache:GetOrCreateCategoryCache(guildId, typeToCategory[totalType])
	-- local numEvents = categoryCache:GetNumEvents()

	local inGuild = 0
	local external = 0
    for i = 1, numEvents do
        local event = categoryCache[i]
		-- local event = categoryCache:GetEvent(i)
        inGuild, external = processEventForTotal(event, isMultiple, res, userId, startTime, endTime, filterFlags, totalType, inGuild, external)
    end
	local externalRatio = 0
	if external > 0 then
		externalRatio = external / (inGuild + external)
	end
	if isMultiple then
		return res, externalRatio
	end
    return res[userId], externalRatio
end

--- func desc
---@param totalType 'bank' or 'sales'
---@param guildId number
---@param userId string or table
---@param startTime number
---@param endTime number
---@param filterFlags string
---@return table{ gold = number, items = number, bought = number, taxes = number, sold = number, totalGold = number, totalItems = number, totalBought = number, totalTaxes = number, totalSold = number}, number
local function getTotalsAsync(totalType, guildId, userId, startTime, endTime, filterFlags, callback)
	local isMultiple = type(userId) == 'table'
	local res = {}
	if isMultiple then
		res = {}
		for _, v in ipairs(userId) do
			res[v.userId] = {
				gold = { d = 0, w = 0, t = 0 },
				items = { d = 0, w = 0, t = 0 },
				bought = 0,
				taxes = 0,
				sold = 0,
				totalGold = { d = 0, w = 0, t = 0 },
				totalItems = { d = 0, w = 0, t = 0 },
				totalBought = 0,
				totalTaxes = 0,
				totalSold = 0,
				member = v
			}
		end
	else
		res[userId] = {
			gold = { d = 0, w = 0, t = 0 },
			items = { d = 0, w = 0, t = 0 },
			bought = 0,
			taxes = 0,
			sold = 0,
			totalGold = { d = 0, w = 0, t = 0 },
			totalItems = { d = 0, w = 0, t = 0 },
			totalBought = 0,
			totalTaxes = 0,
			totalSold = 0,
		}
	end

    local key = getGuilCategoryCacheKey(guildId, totalType)
	local initialized = poukav.state.guildCategoryCacheInitialized[key]
	if not initialized then
		callback(nil)
		return
	end
    local categoryCache = poukav.state.guildCategoryCaches[key]
    local numEvents = #categoryCache

	local inGuild = 0
	local external = 0
	-- (t, op, batchSize, delay, callback, index, context)
	utils.chainOp(
		numEvents,
		function(n, startOffset, endOffset)
			for i = startOffset, endOffset do
				local event = categoryCache[i] -- categoryCache:GetEvent(i)
				inGuild, external = processEventForTotal(event, isMultiple, res, userId, startTime, endTime, filterFlags, totalType, inGuild, external)
			end
		end,
		1000,
		10,
		function()
			local externalRatio = 0
			if external > 0 then
				externalRatio = external / (inGuild + external)
			end
			if isMultiple then
				callback(res, externalRatio)
				return
			end
			callback(res[userId], externalRatio)
		end
	)
end

local function getBoundaryEventsTime(guildId, userId, callback, categoryName)
	local isMultiple = type(userId) == 'table'
	local res = {}
	local bigNumber = os.time() * 2 -- not reachable
	if isMultiple then
		res = {}
		for _, v in ipairs(userId) do
			res[v.userId] = {
				first = bigNumber,
				last = 0,
				member = v
			}
		end
	else
		res[userId] = {
			first = bigNumber,
			last = 0,
		}
	end
	if not categoryName then
		getBoundaryEventsTime(guildId, userId, function(guildResult)
			if not guildResult then
				callback(nil)
				return
			end
			for k, memberResult in pairs(guildResult) do
				res[k] = memberResult
			end
			getBoundaryEventsTime(guildId, userId, function(bankResult)
				if not bankResult then
					callback(nil)
					return
				end
				for k, memberResult in pairs(bankResult) do
					res[k].first = math.min(res[k].first, memberResult.first)
					res[k].last = math.max(res[k].last, memberResult.last)
				end
				getBoundaryEventsTime(guildId, userId, function(salesResult)
					if not salesResult then
						callback(nil)
						return
					end
					for k, memberResult in pairs(salesResult) do
						res[k].first = math.min(res[k].first, memberResult.first)
						res[k].last = math.max(res[k].last, memberResult.last)
					end
					for _, v in pairs(res) do
						if v.first == bigNumber then
							v.first = nil
						end
						if v.last == 0 then
							v.last = nil
						end
					end
					if isMultiple then
						callback(res)
						return
					end
					callback(res[userId])
				end, 'sales')		
			end, 'bank')		
		end, 'guild')
	else
		local key = getGuilCategoryCacheKey(guildId, categoryName)
		local initialized = poukav.state.guildCategoryCacheInitialized[key]
		if not initialized then
			callback(nil)
			return
		end
		local categoryCache = poukav.state.guildCategoryCaches[key]
		local numEvents = #categoryCache
	
		-- (t, op, batchSize, delay, callback, index, context)
		utils.chainOp(
			numEvents,
			function(n, startOffset, endOffset)
				for i = startOffset, endOffset do
					local event = categoryCache[i] -- categoryCache:GetEvent(i)
					local time = event.info[consts.INFO_EVENT_TIME]
					local userId = event.info[consts.INFO_USER_NAME]
					local current = res[userId]
					if current then
						if time < current.first then
							current.first = time
						end
						if time > current.last then
							current.last = time
						end
					end
				end
			end,
			1000,
			10,
			function()
				if isMultiple then
					callback(res)
					return
				end
				callback(res[userId])
			end
		)		
	end
end

local rankNamesMap = {}
local function getGuildRankName(guildId, rankIndex)
	local guildBucket = rankNamesMap[guildId]
	if not guildBucket then
		guildBucket = {}
		rankNamesMap[guildId] = guildBucket
	end
	local name = guildBucket[rankIndex]
	if not name then
		name = GetGuildRankCustomName(guildId, rankIndex)
		if type(name) ~= 'string' or utils.trim(name) == '' then
			local rankId = GetGuildRankId(guildId, rankIndex)
			-- "Invited", -- SI_GUILDRANKS0
			-- "Recruit", -- SI_GUILDRANKS1
			-- "Member", -- SI_GUILDRANKS2
			-- "Officer", -- SI_GUILDRANKS254
			-- "Guildmaster", -- SI_GUILDRANKS255
			if (rankId == 0) then
				name = GetString(SI_GUILDRANKS0)
			elseif (rankId == 1) then
				name = GetString(SI_GUILDRANKS1)
			elseif (rankId == 2) then
				name = GetString(SI_GUILDRANKS2)
			elseif (rankId == 254) then
				name = GetString(SI_GUILDRANKS254)
			elseif (rankId == 255) then
				name = GetString(SI_GUILDRANKS255)
			end
		end
		-- still no name ?
		if type(name) ~= 'string' or utils.trim(name) == '' then
			name = 'Rank' .. rankIndex
		end
		guildBucket[rankIndex] = name
	end
	return name
end

local function getIntervalString(localization, startTime, endTime)
	local startStr = (startTime and os.date('%c', startTime)) or localization.FIRST_RECORDED_DATA
	local endStr = (endTime and os.date('%c', endTime)) or localization.NOW
	return utils.sformat(localization.FROM_TO, startStr, endStr)
end

local function outputInterval(localization, startTime, endTime)
	return utils.output(utils.capitalize(getIntervalString(localization, startTime, endTime)))
end

local function collectMembers(guildId, rankSearchName, startTime, filterInactives)
	local localState = poukav.state
	if filterInactives == nil then
		filterInactives = true
	end
	local now = os.time()
	local memberList = {}
	local numMembers = GetGuildInfo(guildId)
	for i = 1, numMembers do
		-- string name, string note, luaIndex rankIndex, integer playerStatus, integer secsSinceLogoff 
		local userId, note, rankIndex, playerStatus, secsSinceLogoff, memberIndex = cachedGetGuildMemberInfo(guildId, i)
		local lastLoggedIn = now - (secsSinceLogoff or 0)
		local inactiveDays = math.floor(secsSinceLogoff / consts.ONE_DAY_IN_SEC)
		local startTimeMatch = not startTime or (lastLoggedIn >= startTime)
		local inactiveMatch = not filterInactives or (inactiveDays < localState.data.ignorePlayerInactivityThreashold)
		local rankName = getGuildRankName(guildId, rankIndex)
		local rankMatch = not rankSearchName or rankSearchName == '*' or (utils.compareNames(rankName, rankSearchName))
		if startTimeMatch and inactiveMatch and rankMatch then
			table.insert(memberList, { userId = userId, note = note, rankIndex = rankIndex, playerStatus = playerStatus, secsSinceLogoff = secsSinceLogoff, rankName = rankName, memberIndex = memberIndex })
		end
	end
	return memberList
end

local function updateGuildsOptionsData()
    local localState = poukav.state
    local guildsOptions = localState.data.guilds
    if not guildsOptions then
        guildsOptions = {
            simulateRankEvalutation = true
        }
        localState.data.guilds = guildsOptions
    end
    
    local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do

		local guildId = GetGuildId(i)
        local currentGuildOptions = guildsOptions[guildId]
        if not currentGuildOptions then
            currentGuildOptions = {
                -- >= v1.9
                donation = {
                    frequency = 'none',
                    amount = 0,
                    startTime = 0
                },
                -- >= v1.8
                ranks = {}
            }
            guildsOptions[guildId] = currentGuildOptions
        end
        -- donation added on v1.9, update old saved variables this way
        if not currentGuildOptions.donation then
            currentGuildOptions.donation = {
                frequency = 'none',
                amount = 0,
                startTime = 0
            }
        end

        local numRanks =  GetNumGuildRanks(guildId)
        for rankIndex = 1, numRanks do

            local isAdminRank = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_DEMOTE) or
				DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PROMOTE) or
				DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PERMISSION_EDIT)

            local currentRankOptions = currentGuildOptions.ranks[rankIndex]
            if not currentRankOptions then
                local salesStepSize = math.floor((10000000 / numRanks) / 50000) * 50000
                local minSales
                if isAdminRank then
                    minSales = 10000000
                elseif rankIndex == numRanks then
                    minSales = 1000
                elseif rankIndex == 1 then
                    minSales = 10000000
                else
                    minSales = (numRanks - rankIndex) * salesStepSize
                end

                currentRankOptions = {
                    evaluationPeriodicity = 'none',
                    minSales = minSales,
                    permanentPromotion = true
                }
                currentGuildOptions.ranks[rankIndex] = currentRankOptions
            end

        end
    end
end

local function guildCheck(localization, guildSearchName, anonymize)
	if not guildSearchName or utils.trim(guildSearchName) == '' then
		utils.output(localization.NEED_GUILD_PARAM)
		return
	end
	local guildId, guildLabel = findGuild(guildSearchName)
	if (not guildLabel) then
		utils.output(localization.NO_GUILD_FOUND, utils.applyAnonymize(guildSearchName, anonymize))
		utils.output(charLine)
		return
	end
	utils.output(localization.FOUND_GUILD, utils.applyAnonymize(guildLabel, anonymize), utils.applyAnonymize(guildId, anonymize))
	return guildId, guildLabel
end

local function userCheck(localization, guildId, userSearchName, anonymize)
	local userId = findUserId(guildId, userSearchName)
	if (not userId) then
		utils.output(localization.NO_GUILD_MEMBER_FOUND, utils.applyAnonymize(userSearchName, anonymize))
		utils.output(charLine)
		return
	end
	utils.output(localization.FOUND_GUILD_MEMBER, utils.applyAnonymize(userId, anonymize))
	return userId
end

local function getSliceIndex(slices, sliceCount, time)
	local sliceCursor = 1
	while sliceCursor <= sliceCount do
		local slice = slices[sliceCursor]
		if time >= slice[1] and time < slice[2] then
			return sliceCursor
		end
		sliceCursor = sliceCursor + 1
	end
	return 0
end

local function updateActivityResultForEvent(frequency, donationsSlices, sliceCount, time, current)
	local sliceIndex = getSliceIndex(donationsSlices, sliceCount, time)
	if sliceIndex ~= 0 then
		if frequency == 'monthly' then
			-- week ordinal since epoch
			local weekNum = math.floor(time / (consts.ONE_DAY_IN_SEC *7))
			if not table.contains(current[sliceIndex], weekNum) then
				table.insert(current[sliceIndex], weekNum)
			end								
		else
			-- day ordinal since epoch
			local dayNum = math.floor(time / consts.ONE_DAY_IN_SEC)
			if not table.contains(dayNum) then
				table.insert(current[sliceIndex], current[sliceIndex], dayNum)
			end
		end
	end
end

local function collectActivities(guildId, userId, frequency, startTime, callback)
	local isMultiple = type(userId) == 'table'
	
	local now = os.time()
	local timeCursor = startTime
	local donationsSlices = {}
	while timeCursor < now do
		local sliceStart = timeCursor
		local cursorObj = os.date('*t', timeCursor)
		local dayIncrement = (frequency == 'monthly' and utils.daysInMonth(cursorObj.month)) or 7
		local sliceEnd = sliceStart + (consts.ONE_DAY_IN_SEC * dayIncrement)
		timeCursor = sliceEnd
		table.insert(donationsSlices, { sliceStart, sliceEnd })
	end
	local sliceCount = #donationsSlices
	local res = {}

	if isMultiple then
		for _, m in ipairs(userId) do
			local userSlices = {}
			res[m.userId] = userSlices
			for i = 1, sliceCount do
				userSlices[i] = {}
			end
		end
	else
		local userSlices = {}
		res[userId] = userSlices
		for i = 1, sliceCount do
			userSlices[i] = {}
		end
	end

	local bankKey = getGuilCategoryCacheKey(guildId, 'bank')
	if not poukav.state.guildCategoryCacheInitialized[bankKey] then
		callback(nil)
		return
	end
	local bankCache = poukav.state.guildCategoryCaches[bankKey]
	local numBankEvents = #bankCache

	local salesKey = getGuilCategoryCacheKey(guildId, 'sales')
	if not poukav.state.guildCategoryCacheInitialized[salesKey] then
		callback(nil)
		return
	end
	local salesCache = poukav.state.guildCategoryCaches[salesKey]
	local numSalesEvents = #salesCache

	local maxNumEvents = math.max(numBankEvents, numSalesEvents)
	-- (t, op, batchSize, delay, callback, index, context)
	utils.chainOp(
		maxNumEvents,
		function(n, startOffset, endOffset)
			for i = startOffset, endOffset do
				local bankEvent = bankCache[i] -- categoryCache:GetEvent(i)
				if bankEvent then
					local time = bankEvent.info[consts.INFO_EVENT_TIME]
					local type = bankEvent.info[consts.INFO_EVENT_TYPE]
					local userId = bankEvent.info[consts.INFO_USER_NAME]
					local current = res[userId]
					if current and type == consts.EVENT_TYPE_WITHDREW_ITEM then
						updateActivityResultForEvent(frequency, donationsSlices, sliceCount, time, current)
					end					
				end
				local salesEvent = salesCache[i] -- categoryCache:GetEvent(i)
				if salesEvent then
					local time = salesEvent.info[consts.INFO_EVENT_TIME]
					local type = salesEvent.info[consts.INFO_EVENT_TYPE]
					local userId = salesEvent.info[consts.INFO_USER_NAME]
					local current = res[userId]
					if current and type == consts.EVENT_TYPE_SOLD_ITEMS then
						updateActivityResultForEvent(frequency, donationsSlices, sliceCount, time, current)
					end					
				end
			end
		end,
		1000,
		10,
		function()
			-- event on 2 different weeks in a month or 3 different days in a week
			local target = (frequency == 'monthly' and 2) or 3
			if isMultiple then
				for _, m in ipairs(userId) do
					
					local userSlices = res[m.userId]
					for i = 1, sliceCount do
						local active = #userSlices[i] >= target
						userSlices[i] = active
					end
				end
			else
				local userSlices = res[userId]
				for i = 1, sliceCount do
					local active = #userSlices[i] >= target
					userSlices[i] = active
				end
			end
			if isMultiple then
				callback(donationsSlices, res)
				return
			end
			callback(donationsSlices, res[userId])
		end
	)	
end

poukav.tools = {
    cachedGetGuildMemberInfo = cachedGetGuildMemberInfo,
	invalidateGuildMemberInfo = invalidateGuildMemberInfo,
    eventTimeMatchesPeriod = eventTimeMatchesPeriod,
    eventToFormatArgs = eventToFormatArgs,
    matchFilterFlags = matchFilterFlags,
    findGuild = findGuild,
    findUserId = findUserId,
    getTotals = getTotals,
	getTotalsAsync = getTotalsAsync,
	getGuilCategoryCacheKey = getGuilCategoryCacheKey,
	getGuildRankName = getGuildRankName,
	outputInterval = outputInterval,
	getIntervalString = getIntervalString,
	collectMembers = collectMembers,
	collectActivities = collectActivities,
	getBoundaryEventsTime = getBoundaryEventsTime,
	updateGuildsOptionsData = updateGuildsOptionsData,
	guildCheck = guildCheck,
	userCheck = userCheck,
	getNote = getNote
}