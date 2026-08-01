local poukav = LibMarcusModules['Poukav']
local localization = poukav.localization.localized
local utils = poukav.utils
local tools = poukav.tools
local consts = poukav.constants
local PROMOTION_DELAY = 2500

local function format_admins(admins, guildId, anonymize, nameColor)
    local out = {}
    for _, m in ipairs(admins) do
        table.insert(out, utils.sformat('%s (%s)',
		utils.cFormat(utils.applyAnonymize(m.userId, anonymize), nameColor),
		utils.trim(tools.getGuildRankName(guildId, m.rankIndex))))
    end
    return table.concat(out, " ")
end

local function processRanksFromTotals(memberList, memberResult, numRanks, weeklySalesResult, monthlySalesResult, weeklyBankResult, monthlyBankResult, guildId, startTime, endTime, guildRanksInfo, anonymize, nameColor, simulate, numMembers, ranksPromotePermission)
	local hasResults = false
					
	for _, member in ipairs(memberList) do
		local memberId = member.userId
		local currentRankIndex = member.rankIndex
		local rankInfo = guildRanksInfo[currentRankIndex]
		if not rankInfo then
			utils.output(localization.CREATED_RANK_AFTER_LOADING_NEED_RELOAD)
			utils.output(consts.CHAR_LINE)
			return true
		end
		local isPermanent = rankInfo.permanentPromotion
		local demoted = false
		local alreayDemoted = false
		local memberValue = 0
		-- compute demotion first if needed
		if currentRankIndex < numRanks and not isPermanent and rankInfo.evaluationPeriodicity ~= 'none' then
			local salesToConsider = rankInfo.evaluationPeriodicity == 'weekly' and weeklySalesResult or monthlySalesResult
			local bankToConsider = rankInfo.evaluationPeriodicity == 'weekly' and weeklyBankResult or monthlyBankResult
			memberValue = salesToConsider[memberId].bought + salesToConsider[memberId].sold + bankToConsider[memberId].gold.d
			if memberValue < (rankInfo.minSales or 0) then
				member.value = memberValue
				member.sales = salesToConsider[memberId].sold
				member.purchases = salesToConsider[memberId].bought
				member.donations = bankToConsider[memberId].gold.d
				-- check if already demoted
				
				if rankInfo.evaluationPeriodicity == 'weekly' then
					-- this week
					startTime, endTime = utils.getInterval('W')
				else
					-- or this month
					startTime, endTime = utils.getInterval('M')
				end
				local key = tools.getGuilCategoryCacheKey(guildId, 'guild')
				local initialized = poukav.state.guildCategoryCacheInitialized[key]
				if not initialized then
					utils.output(localization.WAIT_FOR_INITIALIZATION)
					return
				end
				local categoryCache = poukav.state.guildCategoryCaches[key]
				local numEvents = #categoryCache
				for i = 1, numEvents do
					local event = categoryCache[i]
					if (not alreayDemoted and event.info[consts.INFO_EVENT_TYPE] == consts.EVENT_TYPE_DEMOTED and utils.compareNames(memberId, event.info[consts.INFO_TARGET_USER_NAME])) then
						
						local timeMatch = tools.eventTimeMatchesPeriod(event, startTime, endTime)

						if (timeMatch) then
							alreayDemoted = true
							table.insert(memberResult.alreadyDemoted, member)
						end
					end
				end
				if not alreayDemoted then
					demoted = true
					table.insert(memberResult.demoted, member)
				end
			end
		end
		if not demoted then
			local nextRankIndex = currentRankIndex
			for i = 1, currentRankIndex - 1 do
				local evaluatedRankInfo = guildRanksInfo[i]
				
				
				-- if next rank unchanged (we're going downward, from highest rank to lower rank)
				if nextRankIndex == currentRankIndex and (not ranksPromotePermission[i]) and (evaluatedRankInfo.evaluationPeriodicity ~= 'none') then
					local salesToConsider = evaluatedRankInfo.evaluationPeriodicity == 'weekly' and weeklySalesResult or monthlySalesResult
					local bankToConsider = evaluatedRankInfo.evaluationPeriodicity == 'weekly' and weeklyBankResult or monthlyBankResult
					memberValue = salesToConsider[memberId].bought + salesToConsider[memberId].sold + bankToConsider[memberId].gold.d
					if memberValue >= (evaluatedRankInfo.minSales or 10000000) then
						member.value = memberValue
						member.sales = salesToConsider[memberId].sold
						member.purchases = salesToConsider[memberId].bought
						member.donations = bankToConsider[memberId].gold.d
						nextRankIndex = i
					end
				end
			end
			if nextRankIndex ~= currentRankIndex then
				local currentRankName = utils.trim(tools.getGuildRankName(guildId, currentRankIndex))
				local nextRankName = utils.trim(tools.getGuildRankName(guildId, nextRankIndex))
				local evaluatedRankInfo = guildRanksInfo[nextRankIndex]
				
				member.nextRankIndex = nextRankIndex
				member.nextRankName = nextRankName
				member.rankName = currentRankName
				table.insert(memberResult.promoted, member)
				
				hasResults = true
			else
				table.insert(memberResult.unchanged, member)
			end
		else
			-- lower ranks are higher index, so demoting is adding 1 to the current rank index
			local currentRankName = utils.trim(tools.getGuildRankName(guildId, currentRankIndex))
			local nextRankName = utils.trim(tools.getGuildRankName(guildId, currentRankIndex + 1))
			member.nextRankIndex = currentRankIndex + 1
			member.nextRankName = nextRankName
			member.rankName = currentRankName
			
			hasResults = true
		end
	end
	utils.output(
		localization.RANK_CALCULATION_RESULT_MESSAGE,
		numMembers,
		#memberResult.ignored,
		#memberResult.inactives,
		#memberResult.promoted,
		#memberResult.demoted,
		#memberResult.alreadyDemoted,
		#memberResult.unchanged
	)
	if not hasResults then
		utils.output(localization.FOUND_NO_RANK_TO_UPDATE)
	else
		utils.output(localization.ADMINISTRATORS)
		table.sort(memberResult.ignored, function(m1, m2) return m1.userId < m2.userId end)
		utils.output(
			format_admins(memberResult.ignored, guildId, anonymize, nameColor)
		)
		utils.output(utils.cFormat(localization.PROMOTIONS, '00ff00'))
		table.sort(memberResult.promoted, function(m1, m2) return m1.userId < m2.userId end)
		-- (t, op, batchSize, delay, callback, index, context)
		utils.chainOp(
			memberResult.promoted,
			function(t, index)
				local m = t[index]
				local memberId = m.userId
				utils.output(
					simulate and localization.RANK_SHOULD_CHANGE or localization.CHANGING_RANK,
					utils.cFormat(utils.applyAnonymize(memberId, anonymize), nameColor),
					utils.cFormat(localization.PROMOTED, '00ff00'),
					m.rankName, m.nextRankName,
					utils.formatThousands(m.sales),
					utils.formatThousands(m.purchases),
					utils.formatThousands(m.donations),
					utils.formatThousands(m.value) .. ' >= ' .. (utils.formatThousands(guildRanksInfo[m.nextRankIndex].minSales or 0))
				)
				if not simulate then
					GuildSetRank(guildId, memberId, m.nextRankIndex)
					tools.invalidateGuildMemberInfo(guildId, m.memberIndex)
				end
			end,
			1,
			(simulate and 200) or PROMOTION_DELAY,
			function()
				utils.output(utils.cFormat(localization.DEMOTIONS, 'ff0000'))
				table.sort(memberResult.demoted, function(m1, m2) return m1.userId < m2.userId end)
				utils.chainOp(
					memberResult.demoted,
					function(t, index)
						local m = t[index]
						local memberId = m.userId
						utils.output(
							simulate and localization.RANK_SHOULD_CHANGE or localization.CHANGING_RANK,
							utils.cFormat(utils.applyAnonymize(memberId, anonymize), nameColor),
							utils.cFormat(localization.DEMOTED, 'ff0000'),
							m.rankName, m.nextRankName,
							utils.formatThousands(m.sales),
							utils.formatThousands(m.purchases),
							utils.formatThousands(m.donations),
							utils.formatThousands(m.value) .. ' < ' .. (utils.formatThousands(guildRanksInfo[m.rankIndex].minSales or 0))
						)
						if not simulate then
							-- GuildSetRank(*integer* _guildId_, *string* _displayName_, *luaindex* _rankIndex_)
							GuildSetRank(guildId, memberId, m.nextRankIndex)
							tools.invalidateGuildMemberInfo(guildId, m.memberIndex)
						end
					end,
					1,
					simulate and 200 or PROMOTION_DELAY,
					function()
						utils.output(consts.CHAR_LINE)
					end
				)
			end
		)
		
	end
end

poukav.ranks = {
    processCommand = function(guildId, simulate, anonymize, preview)
		if type(simulate) ~= 'boolean' or preview or anonymize then
			simulate = true
		end
        local localState = poukav.state
        local nameColor = localState.data.memberTextColor
        if not localState.data.guilds[guildId] then
			utils.output(localization.JOINED_GUILD_AFTER_LOADING_NEED_RELOAD)
			utils.output(consts.CHAR_LINE)
			return true
		end
		local guildRanksInfo = localState.data.guilds[guildId].ranks
		local numMembers = GetGuildInfo(guildId)
		local sorted = {}
		local sortedCount = 0
		local now = os.time()
		local memberList = {}
		local memberResult = {
			promoted = {},
			demoted = {},
			alreadyDemoted = {},
			unchanged = {},
			ignored = {},
			inactives = {}
		}
		local ranksPromotePermission = {}
		local numRanks =  GetNumGuildRanks(guildId)
		for i = 1, numRanks do
			-- * DoesGuildRankHavePermission(*integer* _guildId_, *luaindex* _rankIndex_, *[GuildPermission|#GuildPermission]* _permission_)
			-- ** _Returns:_ *bool* _hasPermission_
			ranksPromotePermission[i] = 
				DoesGuildRankHavePermission(guildId, i, GUILD_PERMISSION_DEMOTE) or
				DoesGuildRankHavePermission(guildId, i, GUILD_PERMISSION_PROMOTE) or
				DoesGuildRankHavePermission(guildId, i, GUILD_PERMISSION_PERMISSION_EDIT)
		end
        for i = 1, numMembers do
			-- string name, string note, luaIndex rankIndex, integer playerStatus, integer secsSinceLogoff 
            local userId, note, rankIndex, playerStatus, secsSinceLogoff, memberIndex = tools.cachedGetGuildMemberInfo(guildId, i)
			if rankIndex == 1 or ranksPromotePermission[rankIndex] then
				table.insert(memberResult.ignored, { userId = userId, note = note, rankIndex = rankIndex, playerStatus = playerStatus, secsSinceLogoff = secsSinceLogoff, memberIndex = memberIndex })
			else
				local lastLoggedIn = now - (secsSinceLogoff or 0)
				local inactiveDays = math.floor(secsSinceLogoff / consts.ONE_DAY_IN_SEC)
				local inactiveMatch = inactiveDays < localState.data.ignorePlayerInactivityThreashold
				if inactiveMatch then
					table.insert(memberList, { userId = userId, note = note, rankIndex = rankIndex, playerStatus = playerStatus, secsSinceLogoff = secsSinceLogoff, memberIndex = memberIndex })
				else
					table.insert(memberResult.inactives, { userId = userId, note = note, rankIndex = rankIndex, playerStatus = playerStatus, secsSinceLogoff = secsSinceLogoff, memberIndex = memberIndex })
				end
			end
			
        end
		local startTime, endTime = utils.getInterval((preview and 'M') or 'M-1')
		tools.getTotalsAsync('sales', guildId, memberList, startTime, endTime, nil, function(monthlySalesResult, monthlyRatio)
			if not monthlySalesResult then
				utils.output(localization.WAIT_FOR_INITIALIZATION)
				return true
			end
			startTime, endTime = utils.getInterval((preview and 'W') or 'W-1')
			tools.getTotalsAsync('sales', guildId, memberList, startTime, endTime, nil, function(weeklySalesResult, weeklyRatio)
				if not weeklySalesResult then
					utils.output(localization.WAIT_FOR_INITIALIZATION)
					return true
				end
				-- local weeklySalesResult, weeklyRatio = tools.getTotals('sales', guildId, memberList, startTime, endTime, nil)
				local looksLikeMerchantMissing = weeklyRatio < (localState.data.noKioskExternalSalesRatioThreashold / 100)-- or math.abs(monthlyRatio - weeklyRatio) > 0.1
				if (looksLikeMerchantMissing) then
					utils.output(localization.CANT_RANK_IT_LOOKS_LIKE_NO_MERCHANT_WAS_HIRED, tools.getIntervalString(localization, startTime, endTime), math.floor(weeklyRatio * 100))
					utils.output(consts.CHAR_LINE)
					return true
				end
				
				tools.outputInterval(localization, startTime, endTime)
				utils.output(
					localization.GUILD_HAD_A_MERCHANT,
					math.floor(weeklyRatio * 100), localState.data.noKioskExternalSalesRatioThreashold
				)
				startTime, endTime = utils.getInterval((preview and 'M') or 'M-1')
				tools.getTotalsAsync('bank', guildId, memberList, startTime, endTime, nil, function(monthlyBankResult)
					if not monthlyBankResult then
						utils.output(localization.WAIT_FOR_INITIALIZATION)
						return true
					end
					startTime, endTime = utils.getInterval((preview and 'W') or 'W-1')
					tools.getTotalsAsync('bank', guildId, memberList, startTime, endTime, nil, function(weeklyBankResult)
						if not weeklyBankResult then
							utils.output(localization.WAIT_FOR_INITIALIZATION)
							return true
						end
						processRanksFromTotals(memberList, memberResult, numRanks, weeklySalesResult, monthlySalesResult, weeklyBankResult, monthlyBankResult, guildId, startTime, endTime, guildRanksInfo, anonymize, nameColor, simulate, numMembers, ranksPromotePermission)
					end)
					
				end)
				
			end)
			
		end)
		return true
    end
}