local poukav = LibMarcusModules['Poukav']
local localization = poukav.localization.localized
local charLine = poukav.constants.CHAR_LINE
local localState = poukav.state
local utils = poukav.utils
local tools = poukav.tools
local consts = poukav.constants

local function selectGuild(guildId, guildName)
	localState.selectedGuild.id = guildId
	localState.selectedGuild.name = guildName
	SelectTradingHouseGuildId(guildId)
end

local function getGuildState()
	local guildState = localState[localState.selectedGuild.id]
	if (not guildState) then
		guildState = {
			lastScanned = nil,
			scanResults = {}
		}
		localState[localState.selectedGuild.id] = guildState
	end
	return guildState
end

local function execSearch()
	if not localState.isTradingHouseOpened then
		return
	end
	local scanningInBackground = getGuildState().lastScanned
	local selectedGuildName = localState.selectedGuild.name
	if not scanningInBackground and ((localState.page) % 5 == 0)then
		utils.output(localization.SCANNING_GUILD_STORE, selectedGuildName, localState.page + 1, localState.page + 5)
	end
	
	ExecuteTradingHouseSearch(localState.page + 1) -- , 1, true, false)
end

local function getCooldownDelay()
	return math.max(GetTradingHouseCooldownRemaining() + 500, 3500)
end

local function ensureScanned(processCommand, force)
	local guildState = getGuildState()
	if force and localState.isTradingHouseOpened then
		guildState.lastScanned = nil
	end
	local dataAge = os.time() - (guildState.lastScanned or 0)
	local dataIsOutdated = dataAge > (localState.data.scanExpirationTime * 60)
	if not force and guildState.lastScanned and dataIsOutdated then
		processCommand()
		if dataIsOutdated  then
			if localState.isScanning then
				utils.output(localization.OLD_DATA_SCANNING_IN_PROGRESS, utils.formatTimeObj(utils.secondsToTime(dataAge)))
				return
			else
				if localState.isTradingHouseOpened then
					utils.output(localization.OLD_DATA_SCAN_WILL_RUN, utils.formatTimeObj(utils.secondsToTime(dataAge)))
				else
					utils.output(localization.OLD_DATA_GO_TO_TRADING_HOUSE, utils.formatTimeObj(utils.secondsToTime(dataAge)))
					return
				end
			end
			
		end
	end
	if force or not guildState.lastScanned or dataIsOutdated then
		if not localState.isTradingHouseOpened then
			utils.output(localization.CANT_SCAN_NOT_AT_TRADING_HOUSE)
			return
		end
		utils.clearTable(localState.scanBuffer)
		localState.isScanning = true
		localState.page = 0
		localState.processCommand = processCommand

		-- execSearch()
		zo_callLater(function() execSearch() end, getCooldownDelay())

	else
		processCommand()
		guildState.processCommand = nil
	end
end

local function checkScanOperationValid()
	local hasData = getGuildState().lastScanned
	if not hasData then
		if not localState.isTradingHouseOpened then
			utils.output(localization.CANT_EXEC_COMMAND_NOT_AT_TRADING_HOUSE)
			return false
		end
		if localState.isScanning then
			utils.output(localization.CANT_EXEC_FIRST_SCAN_IN_PROGRESS)
			return false
		end
		utils.output(localization.WAIT_FOR_SCAN_TO_COMPLETE)
	end
	return true
end

local function readTradingHouseSearchResults()
	if (localState.isPaused or not localState.isTradingHouseOpened or not localState.isScanning) then
		return
	end
	local numItems, currentPage, hasMorePages = GetTradingHouseSearchResultsInfo()
	if (localState.page + 1 == currentPage) then
		localState.page = currentPage
	else
		zo_callLater(function() execSearch() end, getCooldownDelay())
		return
	end

	for i = 1, numItems do
		local icon, name, qual, quantity, seller, timeRemaining, price, currency, uid, unitPrice = GetTradingHouseSearchResultItemInfo(i)
		local uidString = Id64ToString(uid)
		local link = GetTradingHouseSearchResultItemLink(i) -- GetTradingHouseListingItemLink(i)
		local unitPrice = price / quantity
		local refPrice = utils.getAveragePrice(link)
		
		local margin = (refPrice and refPrice > 0 and -math.floor(((unitPrice - refPrice) / refPrice) * 1000) / 10) or nil
		local index = utils.indexOf(localState.scanBuffer, function(e) return e[10] == uidString end)
		if index then
			table.remove(localState.scanBuffer, index)
		end

		table.insert(localState.scanBuffer, {icon, name, qual, quantity, seller, (30 * consts.ONE_DAY_IN_SEC) - timeRemaining, price, link, margin, uidString})

	end
	
	if hasMorePages then
		zo_callLater(function() execSearch() end, getCooldownDelay())
	else
		local guildState = getGuildState()
		guildState.lastScanned = os.time()
		utils.clearTable(guildState.scanResults)

		for index, r in ipairs(localState.scanBuffer) do
			guildState.scanResults[index] = r
		end
		if localState.processCommand then
			localState.processCommand()
			localState.processCommand = nil
		end
		localState.page = 0
		localState.isScanning = false
	end
end

local function handleTradingHouseResponseReceived(eventCode, responseType, result)
	-- TamrielTradeCentre:DebugWriteLine("Trading house response type " .. responseType)
	if (responseType == TRADING_HOUSE_RESULT_LISTINGS_PENDING or responseType == TRADING_HOUSE_RESULT_CANCEL_SALE_PENDING or responseType == TRADING_HOUSE_RESULT_POST_PENDING) then
		-- UpdateGuildListingData()
	elseif (responseType == TRADING_HOUSE_RESULT_SEARCH_PENDING) then
		readTradingHouseSearchResults()
	end
end

local function handleOpenTradingHouse()
	localState.isTradingHouseOpened = true
	if localState.isPaused then
		localState.isScanning = true
		localState.isPaused = false
		utils.output(localization.RESUMING_SCAN)
		execSearch()
	end
end

local function handleCloseTradingHouse()
	localState.isTradingHouseOpened = false
	if localState.isScanning then
		utils.output(localization.SCAN_PAUSED)
		localState.isScanning = false
		localState.isPaused = true
	end
end


poukav.listings = {
    initialize = function()
        localState = poukav.state
        EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, handleTradingHouseResponseReceived)
        EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_CLOSE_TRADING_HOUSE, handleCloseTradingHouse)
        EVENT_MANAGER:RegisterForEvent('MarcusPoukav', EVENT_OPEN_TRADING_HOUSE, handleOpenTradingHouse)        
    end,
    processListingsCommand = function(guildId, userId, force, anonymize)
        local _, guildLabel = tools.findGuild(guildId)
        selectGuild(guildId, guildLabel)
		if not checkScanOperationValid() then
			return
		end
		local function processCommand()
			local guildState = getGuildState()
			local buff = {}
			for _, res in ipairs(guildState.scanResults) do
				local icon, name, qual, quantity, seller, timeInSell, price, link = unpack(res)
				if seller == userId then
					table.insert(buff, res)
				end
			end
			table.sort(buff, function(a, b) return (a[9] or 0) < (b[9] or 0) end)
			local hasListing = false
			for _, res in ipairs(buff) do
				local icon, name, qual, quantity, seller, timeInSell, price, link, margin = unpack(res)
				if seller == userId then
					hasListing = true
					local timeInSellObj = utils.secondsToTime(timeInSell)
					
					local marginColor
					if (margin) then
						if (margin < 0)  then
							local score = 50 - math.min(math.abs(margin), 50)
							marginColor = utils.getProgressColor(score, 50)
						else
							local score = 75 - math.min(math.abs(margin), 75)
							marginColor = utils.getProgressColor(score, 75)
						end
					end
					utils.output(
						localization.LISTED_ITEM,
						utils.cFormat(utils.applyAnonymize(seller, anonymize), nameColor),
						quantity,
						utils.formatIcon(icon),
						link, -- cFormat(zo_strformat("<<t:1>>", name), qualityColors[qual]),
						utils.formatGold(price),
						utils.formatTimeObj(timeInSellObj),
						(margin and utils.cFormat('(' .. tostring(margin) .. '%)', marginColor)) or ''
					)
				end
			end
			if not hasListing then
				utils.output(localization.USER_HAS_NO_LISTING, userId)
			end
			utils.output(charLine)
		end
		ensureScanned(processCommand, force)
    end,
    processEmptyListingsCommand = function(guildId, rankExpr, force, anonymize)
        local _, guildLabel = tools.findGuild(guildId)
        selectGuild(guildId, guildLabel)
		if not checkScanOperationValid() then
			return
		end
		local function processCommand()
			local guildState = getGuildState()
			local numMembers = GetGuildInfo(guildId)
			local sortedMembers = tools.collectMembers(guildId, rankExpr, nil, false)

			local removed = 0
			for _, res in ipairs(guildState.scanResults) do
				local icon, name, qual, quantity, seller, timeInSell, price, link = unpack(res)
				local index = utils.indexOf(sortedMembers, function(m) return m.userId == seller end)
				if index then
					removed = removed + 1
					table.remove(sortedMembers, index)
				end
			end
			local disconnectedLimit = localState.data.ignorePlayerInactivityThreashold
			local disconnectedUsers = {}
			table.sort(sortedMembers, function(m1, m2) return m2.secsSinceLogoff < m1.secsSinceLogoff end)
			for _, member in ipairs(sortedMembers) do
				-- local userId, note, rankIndex, rankName, secsSinceLogoff = unpack(res)
				local sinceLogOffObj = utils.secondsToTime(math.abs(member.secsSinceLogoff))
				if sinceLogOffObj.d >= disconnectedLimit then
					if not table.contains(disconnectedUsers, member.userId) then
						table.insert(disconnectedUsers, member.userId)
					end
				end
				utils.output(
					localization.HAS_NOTHING_LISTED,
					member.userId,
					utils.formatTimeObj(sinceLogOffObj)
				)
			end
			local rankLabel1 = (rankExpr and (' ' .. rankExpr .. (removed > 1 and 's' or ''))) or ''
			local rankLabel2 = (rankExpr and (' ' .. rankExpr .. (#sortedMembers > 1 and 's' or ''))) or ''
			utils.output(
				localization.EMPTY_LISTINGS_SUMMARY,
				numMembers, removed, rankLabel1, #sortedMembers, rankLabel2, #disconnectedUsers, disconnectedLimit
			)
			utils.output(charLine)
		end
		ensureScanned(processCommand, force)
    end
}