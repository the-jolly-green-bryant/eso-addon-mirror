local poukav = LibMarcusModules['Poukav']
local tools = poukav.tools
local utils = poukav.utils
local consts = poukav.constants

local statusMap = {
	[PLAYER_STATUS_AWAY] = 'esoui/art/contacts/social_status_afk.dds',
	[PLAYER_STATUS_DO_NOT_DISTURB] = 'esoui/art/contacts/social_status_dnd.dds',
	[PLAYER_STATUS_OFFLINE] = 'esoui/art/contacts/social_status_offline.dds',
	[PLAYER_STATUS_ONLINE] = 'esoui/art/contacts/social_status_online.dds'
}

poukav.donations = {
    processCommand = function(localization, guildSearchName, rankSearchName, anonymize)
        local localState = poukav.state
        local nameColor = localState.data.memberTextColor
        local guildId, guildLabel = tools.guildCheck(localization, guildSearchName, anonymize)
		if not guildId then return end
        local donationInfo = localState.data.guilds[guildId].donation or {}
		local frequency = donationInfo.frequency
		local amount = donationInfo.amount
		if not frequency or frequency == 'none' or not amount or amount == 0 or not donationInfo.startTime or donationInfo.startTime == 0 then
			utils.output(localization.NO_DONATION_SET, guildLabel)
			return
		end
		
		local startTime = donationInfo.startTime
		startTime = (frequency == 'monthly' and utils.startOfMonth(startTime)) or utils.startOfWeek(startTime)
		local memberList = tools.collectMembers(guildId, rankSearchName, startTime, true)
		local notDonatedList = {}

		utils.output(localization.READING_BANK_DATA )
		tools.getTotalsAsync('bank', guildId, memberList, startTime, nil, nil, function(fromStartTimeBankTotals)
			if not fromStartTimeBankTotals then
				utils.output(localization.WAIT_FOR_INITIALIZATION)
				return
			end
			utils.output(localization.READING_SALES_DATA )
			tools.getTotalsAsync('sales', guildId, memberList, startTime, nil, nil, function(fromStartTimeSalesTotals)
				if not fromStartTimeSalesTotals then
					utils.output(localization.WAIT_FOR_INITIALIZATION)
					return
				end
				utils.output(localization.COMPUTING_MEMBER_INFO)
				tools.collectActivities(guildId, memberList, frequency, startTime, function(donationsSlices, memberActivities)
					if not donationsSlices then
						utils.output(localization.WAIT_FOR_INITIALIZATION)
						return
					end
					-- utils.chainOp(t, op, batchSize, delay, callback)
					utils.chainOp(
						memberList,
						function(t, startOffset, endOffset)
							for i = startOffset, endOffset do
								local userId = t[i].userId
								local expectedDonationsCount = 0
								for sliceIndex, slice in ipairs(donationsSlices) do
									if memberActivities[userId][sliceIndex] then
										expectedDonationsCount = expectedDonationsCount + 1
									end 
								end
								local expectedDonationsAmount = expectedDonationsCount * amount
								local memberDonationsCount = math.floor(fromStartTimeBankTotals[userId].gold.d / amount)
								if fromStartTimeBankTotals[userId].gold.d < expectedDonationsAmount then
									table.insert(notDonatedList, { userId = userId, rankIndex = t[i].rankIndex, rankName = t[i].rankName, playerStatus = t[i].playerStatus, note = t[i].note, memberDonationsCount = memberDonationsCount, expectedDonationsCount = expectedDonationsCount, bankTotals = fromStartTimeBankTotals[userId], salesTotals = fromStartTimeSalesTotals[userId] })						
								end
							end
							
						end,
						40, 
						15,
						function()
							
							table.sort(notDonatedList, function(l1, l2)
								local r1 = l1.expectedDonationsCount - l1.memberDonationsCount
								local r2 = l2.expectedDonationsCount - l2.memberDonationsCount
								if r1 ~= r2 then
									return r1 < r2
								end
								-- if l1.rankIndex ~= l2.rankIndex then
								-- 	return l1.rankIndex < l2.rankIndex
								-- end
								-- if l2.bankTotals.totalGold.d ~= l1.bankTotals.totalGold.d then
								-- 	return l2.bankTotals.totalGold.d < l1.bankTotals.totalGold.d
								-- end
								return l2.salesTotals.sold < l1.salesTotals.sold
							end)
							local count = 0
							for _, line in ipairs(notDonatedList) do
								count = count + (line.expectedDonationsCount - line.memberDonationsCount)
								local englishTag = ''
								if (line.note) then
									if string.find(line.note:upper(), '*ENGLISH*', 1, true) then
										englishTag = utils.cFormat('EN ', 'ff0000')
									end
								end
								utils.output(
									localization.MEMBER_LATE_ON_DONATION,
									(statusMap[line.playerStatus] and utils.formatIcon(statusMap[line.playerStatus])) or '?',
									englishTag,
									utils.cFormat(utils.applyAnonymize(line.userId, anonymize), nameColor), utils.trim(line.rankName),
									line.memberDonationsCount, line.expectedDonationsCount,
									utils.formatGold(line.bankTotals.totalGold.d),
									utils.formatGold(line.salesTotals.sold)
								)
							end
							utils.output(localization.DONATIONS_SUMMARY, #memberList, #memberList - #notDonatedList, #notDonatedList)
							utils.output(localization.MISSING_AMOUNT, utils.formatGold(count * amount))
						end
					)					
				end)
			end)
		end)        
    end
}