local poukav = LibMarcusModules['Poukav']
local localization = poukav.localization.localized
local charLine = poukav.constants.CHAR_LINE
local function multiOutput(...) 
	local args = {...}
	for _, v in ipairs(args) do
		if type(v) == 'table' then
			poukav.utils.output(unpack(v))
		else
			poukav.utils.output(v)
		end
		
	end
end
poukav.help = {
    processCommand = function(helpCommand)
		local utils = poukav.utils
        if not helpCommand then
			multiOutput(
				localization.HELP_REQUIRES_COMMAND_NAME,
				{localization.HELP_USAGE_FORMAT, localization.COMMAND_HELP, '<keyword>'},
				{localization.HELP_PARAM_ONE_OF, '<keyword>'},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_SEARCH, localization.COMMAND_SEARCH_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_GUILD, localization.COMMAND_GUILD_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_BANK, localization.COMMAND_BANK_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_SALES, localization.COMMAND_SALES_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_TOTAL, localization.COMMAND_TOTAL_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_LISTINGS, localization.COMMAND_LISTINGS_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_EMPTY_LISTINGS, localization.COMMAND_EMPTY_LISTINGS_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_WHOSUS, localization.COMMAND_WHOSUS_DESCRIPTION},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_RANKS, 'auto ranking'},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.COMMAND_DONATIONS, 'member late on donations'},
				{localization.HELP_COMMAND_DESCRIPTION_LINE, localization.TIMEFRAME_PARAM, localization.TIMEFRAME_PARAM_DESCRIPTION},
				localization.HELP_COMMAND_HELP_EXAMPLE,
				charLine
			)
			return true
		end
		local testUserId1 = '@PoukavBilly'
		local testUserId2 = '@AnnaSnitch'
		local testGuild1 = 'PoukavCrew1'
		local testGuild2 = 'PoukavCrew2'
		if helpCommand == localization.COMMAND_SEARCH then
			utils.output(
				localization.SEARCH_HELP_OUTPUT,
				localization.COMMAND_SEARCH,
				localization.COMMAND_SEARCH_GUILD,
				localization.COMMAND_SEARCH_MEMBER,
				localization.COMMAND_SEARCH,
				localization.COMMAND_SEARCH_GUILD,
				localization.COMMAND_SEARCH,
				localization.COMMAND_SEARCH_MEMBER
			)
			utils.output(charLine)
			return true
		end
		if helpCommand == localization.COMMAND_GUILD then
			multiOutput(
				'Searches for guild history events given a guild and a member name.',
				'Usage: /poukav ' .. localization.COMMAND_GUILD .. ' <guild name> <member name> [<timeframe param>]',
				'Example: /poukav ' .. localization.COMMAND_GUILD .. ' PoukavCrew billy',
				'Returns:',
				'[24/12/2022 00:00] @PoukavBilly joined the guild',
				charLine
			)
			return true
		end
		if helpCommand == localization.COMMAND_BANK then
			multiOutput(
				'Searches for bank history events given a guild, a member name (or * for all users), a timeframe param and optional filter flags.',
				'Usage: /poukav ' .. localization.COMMAND_BANK .. ' <guild name> <member name> [<timeframe param>] [<filter flags>]',
				'Where the optional <timeframe param> argument is D for current day, W current week, M current month, D-1 yesterday, W-1 last week...',
				'W-4=>W-1 for the last four weeks excluding the current week, M-5=>M for the last 6 months including the current month',
				'Where the optional <filter flags> argument is a string of any combination of the G,I,D,W flags',
				'Where W stands for Withdrawal, D for Deposit, I for Item and G for Gold',
				'Example: /poukav ' .. localization.COMMAND_BANK .. ' PoukavCrew billy GD',
				'Returns:',
				'[24/12/2022 00:00] @PoukavBilly deposited 10K gold',
				charLine
			)
			return true
		end
		if helpCommand == localization.COMMAND_SALES then
			multiOutput(
				'Searches for sales history events given a guild, a seller name (or * for all members), and a timeframe param.',
				'Usage: /poukav ' .. localization.COMMAND_SALES .. ' <guild name> <seller name> [<timeframe param>]',
				'Where the optional <timeframe param> argument is D for current day, W current week, M current month, D-1 yesterday, W-1 last week...',
				'W-4=>W-1 for the last four weeks excluding the current week, M-5=>M for the last 6 months including the current month',
				'Example: /poukav ' .. localization.COMMAND_SALES .. ' PoukavCrew billy W-1',
				'Returns:',
				'[24/12/2022 00:00] @PoukavBilly sold 200 rubedite ingot to @AnnaSnitch from 1,400 gold',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_PURCHASES then
			multiOutput(
				'Searches for sales history events given a guild, a buyer name (or * for all members), and a timeframe param.',
				'Usage: /poukav ' .. localization.COMMAND_PURCHASES .. ' <guild name> <buyer name> [<timeframe param>]',
				'Where the optional <timeframe param> argument is D for current day, W current week, M current month, D-1 yesterday, W-1 last week...',
				'W-4=>W-1 for the last four weeks excluding the current week, M-5=>M for the last 6 months including the current month',
				'Example: /poukav ' .. localization.COMMAND_PURCHASES .. ' PoukavCrew billy W-1',
				'Returns:',
				'[24/12/2022 00:00] @AnnaSnitch sold 200 rubedite ingot to @PoukavBilly from 1,400 gold',
				charLine
			)
			return true
		end

		if (helpCommand == localization.COMMAND_TOTAL) then
			multiOutput(
				'Sums in bank history events the balance value of deposit/withdrawals or sales/taxes/purchases in sales history for a given guild and member.',
				'Usage: /poukav total <bank or sales> <guild name> <member name> [<timeframe param>]',
				'Example: /poukav total bank PoukavCrew billy M-1',
				'Returns:',
				'@PoukavBilly has a gold balance of -15K',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_WHOSUS then
			multiOutput(
				'Searches for sus users (below a specified balance).',
				'Usage: /poukav ' .. localization.COMMAND_WHOSUS .. ' <guild name> [<timeframe param>]',
				'Example: /poukav ' .. localization.COMMAND_WHOSUS .. ' PoukavCrew M',
				'Returns:',
				'@PoukavBilly is sus because their balance is -20K gold',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_LISTINGS then
			multiOutput(
				'Scans guild store and return listed products for the specified member, along with their margin according to TTC or MM.',
				'Usage: /poukav ' .. localization.COMMAND_LISTINGS .. ' <guild name> <member name or *>',
				'Example: /poukav ' .. localization.COMMAND_LISTINGS .. ' PoukavCrew PoukavBilly',
				'Returns:',
				'@PoukavBilly has listed 1 rubedite ore for 600 gold (-10000%%)',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_EMPTY_LISTINGS then
			multiOutput(
				'Scans guild store and returns a list of member without any products listed.',
				'Usage: /poukav ' .. localization.COMMAND_EMPTY_LISTINGS .. ' <guild name> [<rank name>]',
				'Example: /poukav ' .. localization.COMMAND_EMPTY_LISTINGS .. ' PoukavCrew Recruit',
				'Returns:',
				'@PoukavBilly has nothing listed (last seen 3 Day(s) and 5 Hour(s) ago).',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_RANKS then
			multiOutput(
				'Auto ranking (simulated by default).',
				'Usage: /poukav ' .. localization.COMMAND_RANKS .. ' <guild name>',
				'Example: /poukav ' .. localization.COMMAND_RANKS .. ' PoukavCrew',
				'Returns:',
				'....',
				charLine
			)
			return true
		end

		if helpCommand == localization.COMMAND_DONATIONS then
			multiOutput(
				'Search in gold deposits to retrieve a list of members late on their donations.',
				'Usage: /poukav ' .. localization.COMMAND_DONATIONS .. ' <guild name> [<rank name>]',
				'Example: /poukav ' .. localization.COMMAND_DONATIONS .. ' PoukavCrew Recruit',
				'Returns:',
				'....',
				charLine
			)
			return true
		end

		if helpCommand == localization.TIMEFRAME_PARAM then
			multiOutput(
				localization.TIMEFRAME_PARAM_LONG_DESCRIPTION,
				charLine
			)
			return true
		end
		return false
    end
}