-- RaffleH
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------
-- Acknowledgements:	Seerah for LibAddonMenu-2.0
--						instant (and KLingo) for the basics of command handling
--
--						Everyone who helped with the testing
-------------------------------------------------------------------------------

-- TODO: Build results into a mail message?
--

local LAM = LibStub("LibAddonMenu-2.0")

RaffleH = {}

ldebug = true
desiredGuildName 		= nil
desiredGuildRankCutoff 	= 3
desiredTicketPrice 		= 1000

desiredGuildCut 		= 0.15
desiredFirstPrize 		= 0.5
desiredSecondPrize 		= 0.25
desiredThirdPrize 		= 0.1

guildNameList = {}
numGuilds = 0

ranSeed = GetTimeStamp()
last_winningTicket_1st = 0
last_winningTicket_2nd = 0
last_winningTicket_3rd = 0

-- Setup Colours
local colWhite     = "|cFFFFFF" -- white (c1)
local colYellow    = "|cFFFF00" -- yellow (c2)
local colGreen     = "|c00FF00" -- green (c3)
local colTeal      = "|c00FFFF" -- teal (c4)
local colRed       = "|cFF0000" -- Red


function RaffleH.DetermineNumberOfDeposits(gId)
    local testForDeposits = true
    while testForDeposits == true do
        testForDeposits = RaffleH.RequestMoreGuildBankData(gId)
        numGuildDeposits = GetNumGuildEvents(gId, GUILD_HISTORY_BANK)
        d("Num Guild Deposits: "..numGuildDeposits)
        if numGuildDeposits ~= 0 then
            local lTimeStamp = GetTimeStamp()
            local testLastIndex = numGuildDeposits
            while testForDeposits == true do
                if testLastIndex == 0 then return 0 end
                local eventType, secondsSinceDeposit, depositerName, amount, param3, param4, param5, param6 = GetGuildEventInfo(gId, GUILD_HISTORY_BANK, testLastIndex)
                if eventType == GUILD_EVENT_BANKGOLD_ADDED then
                    local DepositTime = lTimeStamp - secondsSinceDeposit
                    if DepositTime > RaffleH.SavedVariables.endTime then
                        testLastIndex = testLastIndex - 1
                    else
                        numGuildDeposits = testLastIndex
                        testForDeposits = false
                    end
                else
                    testLastIndex = testLastIndex - 1
                end
            end
        end
    end
    return numGuildDeposits
end


--- Perform the raffle draw
-- Addition 18/06	------------------------------------------------------------------------------
function RaffleH.Draw()
-- End Addition 18/06	------------------------------------------------------------------------------
	local runRaffle = RaffleH.CheckPercentage(true)

	--- Get local time and calculate elapsed time from last run
	local lTimeStamp = GetTimeStamp()

-- Addition 18/06	------------------------------------------------------------------------------
	--- Check time is past the end
	RaffleH.TimeCheck()
	if RaffleH.SavedVariables.bComplete == false then
		local timeToGo = RaffleH.TimeToGo()
		d("Raffle time period has not finished. There are still: "..timeToGo.." seconds remaining.")
		runRaffle = false
	end
-- End Addition 18/06	------------------------------------------------------------------------------

	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 and runRaffle == true then
		--- Need to find correct guild!!
		for gIndex = 1, numGuilds, 1 do
			guildId = GetGuildId(gIndex)
			guildName = GetGuildName(guildId)
			--- Run the raffle
			if guildName == desiredGuildName then
				--- Loop through bank deposits within time-frame
				-- RequestGuildHistoryCategoryNewest(guildId, GUILD_HISTORY_BANK)
				--- Need to loop through the current deposits history (one item at a time)
--				numGuildDeposits = GetNumGuildEvents(guildId, GUILD_HISTORY_BANK)
				numGuildDeposits = RaffleH.DetermineNumberOfDeposits(guildId)
				--d("numGuildDeposits"..numGuildDeposits)
				if numGuildDeposits ~= 0 then
					local memberNameList = {}
					local depositTotal = {}
					local ticketsTotal = {}
					local refundTotal = {}
					local numberOfMembersInList = 0
					for depositIndex = 1 , numGuildDeposits , 1 do
						local eventType, secondsSinceDeposit, depositerName, amount, param3, param4, param5, param6 = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, depositIndex)

                        if eventType == GUILD_EVENT_BANKGOLD_ADDED then
                            local currentMemberName = depositerName
                            local depositvalue = amount

                            -- Add a check for rank
                            local rankIsTooHigh = RaffleH.RankIsHigher(guildId, currentMemberName)

                            --- Check deposits within time frame
                            local DepositTime = lTimeStamp - secondsSinceDeposit

                            -- Too late, so refund
                            if DepositTime > RaffleH.SavedVariables.endTime then
                                --- Make a list of all members who deposited outside of the time limit
                                if numberOfMembersInList == 0 then
                                    memberNameList[1] = currentMemberName
                                    depositTotal[1] = 0
                                    ticketsTotal[1] = 0
                                    refundTotal[1] = depositvalue
                                    numberOfMembersInList = 1
                                else
                                    local isNewMember = true
                                    for listOfSellersIndex = 1, numberOfMembersInList, 1 do
                                        if memberNameList[listOfSellersIndex] == currentMemberName then
                                            refundTotal[listOfSellersIndex] = refundTotal[listOfSellersIndex] + depositvalue
                                            isNewMember = false
                                        end
                                    end
                                    if isNewMember == true then
                                        numberOfMembersInList = numberOfMembersInList + 1
                                        memberNameList[numberOfMembersInList] = currentMemberName
                                        depositTotal[numberOfMembersInList] = 0
                                        refundTotal[listOfSellersIndex] = depositvalue
                                        ticketsTotal[numberOfMembersInList] = 0
                                    end
                                end
                            -- Within timeframe, so include in raffle
                            elseif DepositTime <= RaffleH.SavedVariables.endTime and DepositTime >= RaffleH.SavedVariables.startTime then
                                --- Make a list of all members who deposited
                                if numberOfMembersInList == 0 then
                                    memberNameList[1] = currentMemberName
                                    -- Too high a rank, so refund
                                    if rankIsTooHigh == true then
                                        depositTotal[1] = 0
                                        refundTotal[1] = depositvalue
                                        ticketsTotal[1] = 0
                                    else
                                        depositTotal[1] = depositvalue
                                        refundTotal[1] = 0
                                        ticketsTotal[1] = 0
                                    end
                                    numberOfMembersInList = 1
                                else
                                    local isNewMember = true
                                    for listOfSellersIndex = 1, numberOfMembersInList, 1 do
                                        if memberNameList[listOfSellersIndex] == currentMemberName then
                                            if rankIsTooHigh == true then
                                                refundTotal[listOfSellersIndex] = refundTotal[listOfSellersIndex] + depositvalue
                                            else
                                                depositTotal[listOfSellersIndex] = depositTotal[listOfSellersIndex] + depositvalue
                                            end
                                            isNewMember = false
                                        end
                                    end
                                    if isNewMember == true then
                                        numberOfMembersInList = numberOfMembersInList + 1
                                        memberNameList[numberOfMembersInList] = currentMemberName
                                        if rankIsTooHigh == true then
                                            depositTotal[numberOfMembersInList] = 0
                                            refundTotal[numberOfMembersInList] = depositvalue
                                            ticketsTotal[numberOfMembersInList] = 0
                                        else
                                            depositTotal[numberOfMembersInList] = depositvalue
                                            ticketsTotal[numberOfMembersInList] = 0
                                            refundTotal[numberOfMembersInList] = 0
                                        end
                                    end
                                end
                            -- Anything else is before the raffle started
--                            else
--                                d("Time incorrect")
                            end
						end
					end

                    --d("numberOfMembersInList "..numberOfMembersInList)
					--- Post results
					--- Post results for missed deadlines and disqualifications
					if numberOfMembersInList ~= 0 then
						local numberOfTicketsSold = 0

						--- Determine number of tickets sold and to whom
						for listOfDonatorsIndex = 1, numberOfMembersInList, 1 do
							ticketsTotal[listOfDonatorsIndex] = math.floor (depositTotal[listOfDonatorsIndex] / desiredTicketPrice)
							numberOfTicketsSold = numberOfTicketsSold + ticketsTotal[listOfDonatorsIndex]
							d(memberNameList[listOfDonatorsIndex].." gets "..ticketsTotal[listOfDonatorsIndex].." tickets for donations of "..depositTotal[listOfDonatorsIndex])
							if refundTotal[listOfDonatorsIndex] > 0 then
								d(memberNameList[listOfDonatorsIndex].." is due a refund of "..refundTotal[listOfDonatorsIndex])
							end
							--d(memberNameList[listOfDonatorsIndex].." gets "..ticketsTotal[listOfDonatorsIndex].." tickets for donations of "..depositTotal[listOfDonatorsIndex])
						end

						local totalPot = numberOfTicketsSold * desiredTicketPrice
						local guildTake = totalPot * desiredGuildCut
						local prizePot = totalPot - guildTake
						local prize_1st = totalPot * desiredFirstPrize
						local prize_2nd = totalPot * desiredSecondPrize
						local prize_3rd = totalPot * desiredThirdPrize

						d("Total Tickets Sold: "..numberOfTicketsSold.." means a pot of "..totalPot)
						d("First Prize currently: "..prize_1st)
						d("Second Prize currently: "..prize_2nd)
						d("Third Prize currently: "..prize_3rd)

						d("This raffle will raise "..guildTake.." for the guild")

						--- Set a new seed based on current time
						--- Basic time seed is generally poor, so reverse it to ensure a better seed
--						local lSeed = GetTimeStamp()
                        if numberOfTicketsSold == 0 then
                            d("No tickets sold = no raffle")
                            return
                        end
--						local lSeed = tonumber(tostring(GetTimeStamp()):reverse():sub(1,6))
--						math.randomseed(lSeed)

						-- Pop a few numbers to ensure randomness
--						math.random(numberOfTicketsSold)
--						math.random(numberOfTicketsSold)
--						math.random(numberOfTicketsSold)

						-- Set up a winning ticket list
						local WinningTicketList = {}

						--- Run a random function to determine winner, second place and third
						local winningTicket_1st = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
						WinningTicketList[1] = winningTicket_1st
						local winningTicket_2nd = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
						WinningTicketList[2] = winningTicket_2nd
						local winningTicket_3rd = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
						WinningTicketList[3] = winningTicket_3rd

						--- Run a random function to determine winner, second place and third
--						local winningTicket_1st = math.random(numberOfTicketsSold)
--						local winningTicket_2nd = math.random(numberOfTicketsSold)
--						local winningTicket_3rd = math.random(numberOfTicketsSold)

						-- Error check
						if RaffleH.SavedVariables.last_winningTicket_1st == winningTicket_1st and
						RaffleH.SavedVariables.last_winningTicket_2nd == winningTicket_2nd and
						RaffleH.SavedVariables.last_winningTicket_3rd == winningTicket_3rd then
							d("Results invalid, random seed failure. Retrying.")
--							lSeed = GetTimeStamp()
--							lSeed = tonumber(tostring(GetTimeStamp()):reverse():sub(1,6))
--							math.randomseed(lSeed * 0.23562)

							-- Pop a few numbers to ensure randomness
--							math.random(numberOfTicketsSold)
--							math.random(numberOfTicketsSold)
--							math.random(numberOfTicketsSold)

							-- Set up a winning ticket list
							WinningTicketList = {}

							--- Run a random function to determine winner, second place and third
							winningTicket_1st = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
							WinningTicketList[1] = winningTicket_1st
							winningTicket_2nd = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
							WinningTicketList[2] = winningTicket_2nd
							winningTicket_3rd = RaffleH.DrawTicket(numberOfTicketsSold, WinningTicketList)
							WinningTicketList[3] = winningTicket_3rd

--							winningTicket_1st = math.random(numberOfTicketsSold)
--							winningTicket_2nd = math.random(numberOfTicketsSold)
--							winningTicket_3rd = math.random(numberOfTicketsSold)
						end

						local winner_1st = 0
						local winner_2nd = 0
						local winner_3rd = 0

						--- Post results
						local currentTicketNumber = 0
						local numTicketsCounted = 0
						for listOfDonatorsIndex = 1, numberOfMembersInList, 1 do
							currentTicketNumber = currentTicketNumber + ticketsTotal[listOfDonatorsIndex]
							if currentTicketNumber >= winningTicket_1st and numTicketsCounted < winningTicket_1st then
								winner_1st = listOfDonatorsIndex
							end
							if currentTicketNumber >= winningTicket_2nd and numTicketsCounted < winningTicket_2nd then
								winner_2nd = listOfDonatorsIndex
							end
							if currentTicketNumber >= winningTicket_3rd and numTicketsCounted < winningTicket_3rd then
								winner_3rd = listOfDonatorsIndex
							end
							numTicketsCounted = currentTicketNumber
						end

						d("Winning ticket "..winningTicket_1st)
						d("Runner-up ticket "..winningTicket_2nd)
						d("Third prize ticket "..winningTicket_3rd)

						d("Winner is: "..memberNameList[winner_1st].." and receives: "..prize_1st)
						d("Runner-up is: "..memberNameList[winner_2nd].." and receives: "..prize_2nd)
						d("Third place is: "..memberNameList[winner_3rd].." and receives: "..prize_3rd)

-- Addition 18/06	------------------------------------------------------------------------------
						-- Store results
						RaffleH.SavedVariables.ranSeed = lSeed
						RaffleH.SavedVariables.last_winningTicket_1st = winningTicket_1st
						RaffleH.SavedVariables.last_winningTicket_2nd = winningTicket_2nd
						RaffleH.SavedVariables.last_winningTicket_3rd = winningTicket_3rd

						RaffleH.SavedVariables.WinnerName_1st = memberNameList[winner_1st]
						RaffleH.SavedVariables.prize_1st = prize_1st
						RaffleH.SavedVariables.WinnerName_2nd = memberNameList[winner_2nd]
						RaffleH.SavedVariables.prize_2nd = prize_2nd
						RaffleH.SavedVariables.WinnerName_3rd = memberNameList[winner_3rd]
						RaffleH.SavedVariables.prize_3rd = prize_3rd

						RaffleH.SavedVariables.bComplete = false
-- End Addition 18/06	------------------------------------------------------------------------------
					end
				end
				break
			end
		end
	end
end

-- Draw a ticket and check it has not been drawn before
function RaffleH.DrawTicket(numberToDrawFrom , WTList)
	-- Draw a ticket
--	local winningTicket = math.random(numberToDrawFrom)
	local winningTicket = zo_random(numberToDrawFrom)
	-- If no tickets have been drawn already, then it must be new
	if WTList == nil then return winningTicket end

	-- Go through the previously drawn tickets and check if the newly drawn one is a match for any
	local bTicketIsNew = false
	local numDrawnTickets = #WTList
	while bTicketIsNew == false do
		bTicketIsNew = true
		for ticketId = 1, numDrawnTickets, 1 do
			if WTList[ticketId] == winningTicket then
				bTicketIsNew = false
			end
		end
		if bTicketIsNew == false then
--			winningTicket = math.random(numberToDrawFrom)
			winningTicket = zo_random(numberToDrawFrom)
		end
	end
	return winningTicket
end

-- Test random
function RaffleH.TestRandom()
	local numToTest = 3

	-- No seed test
	local testmathrandom = math.random(numToTest)
	local testzorandom = zo_random(numToTest)
	d("No Seed::")
	d("Maths: "..testmathrandom.."     Zo: "..testzorandom)

	-- Timestamp test
	d("GetTimeStamp Seed::")
	local lSeed = GetTimeStamp()
	math.randomseed(lSeed)
	math.random(numToTest)
	math.random(numToTest)
	math.random(numToTest)
	testmathrandom = math.random(numToTest)
	testzorandom = zo_random(numToTest)
	zo_randomseed(lSeed)
	testzorandomSeeded = zo_random(numToTest)
	d("Maths: "..testmathrandom.."     Zo: "..testzorandom.."     Zo-seeded: "..testzorandomSeeded)

	-- Inverse Timestamp test
	d("Inverse GetTimeStamp Seed::")
	lSeed = tonumber(tostring(GetTimeStamp()):reverse():sub(1,6))
	math.randomseed(lSeed)
	math.random(numToTest)
	math.random(numToTest)
	math.random(numToTest)
	testmathrandom = math.random(numToTest)
	testzorandom = zo_random(numToTest)
	zo_randomseed(lSeed)
	testzorandomSeeded = zo_random(numToTest)
	d("Maths: "..testmathrandom.."     Zo: "..testzorandom.."     Zo-seeded: "..testzorandomSeeded)
end

-- Check the current number of tickets sold
function RaffleH.Check()
	--- Get local time and calculate elapsed time from last run
	local lTimeStamp = GetTimeStamp()
	local runRaffle = RaffleH.CheckPercentage(true)

-- Addition 18/06	------------------------------------------------------------------------------
	--- Check time is past the end
	RaffleH.TimeCheck()
	if RaffleH.SavedVariables.bComplete == false then
		if RaffleH.SavedVariables.bRunning == false then
			d("Cannot perform check")
			d("No current raffle in progress or awaiting draw")
			return
		else
			local timeToGo = RaffleH.TimeToGo()
			d("Raffle time period has not finished. There are still: "..timeToGo.." seconds remaining.")
		end
	else
		d("Raffle is ready to be drawn. Use /rh draw to run")
	end
-- End Addition 18/06	------------------------------------------------------------------------------

	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 and runRaffle == true then
		--- Need to find correct guild!!
		for gIndex = 1, numGuilds, 1 do
			guildId = GetGuildId(gIndex)
			guildName = GetGuildName(guildId)
			--- Run the raffle
			if guildName == desiredGuildName then
				--- Loop through bank deposits within time-frame
                d("Guild :"..guildName)
				--- Need to loop through the current deposits history (one item at a time)
--				numGuildDeposits = GetNumGuildEvents(guildId, GUILD_HISTORY_BANK)
				numGuildDeposits = RaffleH.DetermineNumberOfDeposits(guildId)
				if numGuildDeposits ~= 0 then
					local memberNameList = {}
					local depositTotal = {}
					local ticketsTotal = {}
					local refundTotal = {}
					local numberOfMembersInList = 0
					for depositIndex = 1 , numGuildDeposits , 1 do
						local eventType, secondsSinceDeposit, depositerName, amount, param3, param4, param5, param6 = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, depositIndex)

                        if eventType == GUILD_EVENT_BANKGOLD_ADDED then
                            local currentMemberName = depositerName
                            local depositvalue = amount

                            --- Check deposits within time frame
                            local DepositTime = lTimeStamp - secondsSinceDeposit
                            -- Check rank
                            local rankIsTooHigh = RaffleH.RankIsHigher(guildId, currentMemberName)

                            -- Too late, so refund
                            if DepositTime > RaffleH.SavedVariables.endTime then
                                --- Make a list of all members who deposited outside of the time limit
                                if numberOfMembersInList == 0 then
                                    memberNameList[1] = currentMemberName
                                    depositTotal[1] = 0
                                    ticketsTotal[1] = 0
                                    refundTotal[1] = depositvalue
                                    numberOfMembersInList = 1
                                else
                                    local isNewMember = true
                                    for listOfSellersIndex = 1, numberOfMembersInList, 1 do
                                        if memberNameList[listOfSellersIndex] == currentMemberName then
                                            refundTotal[listOfSellersIndex] = refundTotal[listOfSellersIndex] + depositvalue
                                            isNewMember = false
                                        end
                                    end
                                    if isNewMember == true then
                                        numberOfMembersInList = numberOfMembersInList + 1
                                        memberNameList[numberOfMembersInList] = currentMemberName
                                        depositTotal[numberOfMembersInList] = 0
                                        refundTotal[listOfSellersIndex] = depositvalue
                                        ticketsTotal[numberOfMembersInList] = 0
                                    end
                                end
                            -- Within timeframe, so include in raffle
                            elseif DepositTime <= RaffleH.SavedVariables.endTime and DepositTime >= RaffleH.SavedVariables.startTime then
                                --- Make a list of all members who deposited
                                if numberOfMembersInList == 0 then
                                    memberNameList[1] = currentMemberName
                                    -- Too high a rank, so refund
                                    if rankIsTooHigh == true then
                                        depositTotal[1] = 0
                                        refundTotal[1] = depositvalue
                                        ticketsTotal[1] = 0
                                    else
                                        depositTotal[1] = depositvalue
                                        refundTotal[1] = 0
                                        ticketsTotal[1] = 0
                                    end
                                    numberOfMembersInList = 1
                                else
                                    local isNewMember = true
                                    for listOfSellersIndex = 1, numberOfMembersInList, 1 do
                                        if memberNameList[listOfSellersIndex] == currentMemberName then
                                            if rankIsTooHigh == true then
                                                refundTotal[listOfSellersIndex] = refundTotal[listOfSellersIndex] + depositvalue
                                            else
                                                depositTotal[listOfSellersIndex] = depositTotal[listOfSellersIndex] + depositvalue
                                            end
                                            isNewMember = false
                                        end
                                    end
                                    if isNewMember == true then
                                        numberOfMembersInList = numberOfMembersInList + 1
                                        memberNameList[numberOfMembersInList] = currentMemberName
                                        if rankIsTooHigh == true then
                                            depositTotal[numberOfMembersInList] = 0
                                            refundTotal[numberOfMembersInList] = depositvalue
                                            ticketsTotal[numberOfMembersInList] = 0
                                        else
                                            depositTotal[numberOfMembersInList] = depositvalue
                                            ticketsTotal[numberOfMembersInList] = 0
                                            refundTotal[numberOfMembersInList] = 0
                                        end
                                    end
                                end
                            -- Anything else is before the raffle started
                            end
                        end
					end

					--- Disqualify guild leaders
					--- Post results
					--- Post results for missed deadlines and disqualifications
					if numberOfMembersInList ~= 0 then
						local numberOfTicketsSold = 0

						--- Determine number of tickets sold and to whom
						for listOfDonatorsIndex = 1, numberOfMembersInList, 1 do
							ticketsTotal[listOfDonatorsIndex] = math.floor (depositTotal[listOfDonatorsIndex] / desiredTicketPrice)
							numberOfTicketsSold = numberOfTicketsSold + ticketsTotal[listOfDonatorsIndex]
							d(memberNameList[listOfDonatorsIndex].." gets "..ticketsTotal[listOfDonatorsIndex].." tickets for donations of "..depositTotal[listOfDonatorsIndex])
							if refundTotal[listOfDonatorsIndex] > 0 then
								d(memberNameList[listOfDonatorsIndex].." is due a refund of "..refundTotal[listOfDonatorsIndex])
							end
--							print(memberNameList[listOfDonatorsIndex].." gets "..ticketsTotal[listOfDonatorsIndex].." points for donations of "..depositTotal[listOfDonatorsIndex])
						end

						local totalPot = numberOfTicketsSold * desiredTicketPrice
						local guildTake = totalPot * desiredGuildCut
						local prizePot = totalPot - guildTake
						local prize_1st = totalPot * desiredFirstPrize
						local prize_2nd = totalPot * desiredSecondPrize
						local prize_3rd = totalPot * desiredThirdPrize

						d("Total Tickets Sold: "..numberOfTicketsSold.." means a pot of "..totalPot)
						d("First Prize currently: "..prize_1st)
						d("Second Prize currently: "..prize_2nd)
						d("Third Prize currently: "..prize_3rd)

						d("This raffle will raise "..guildTake.." for the guild")
					end
--					RaffleH.SavedVariables.time = GetTimeStamp()
					--- TIME = current time
				end
				break
			end
		end
	end
end

-- Addition 18/06	------------------------------------------------------------------------------
-- Restart the raffle
function RaffleH.Restart()
	d("Restarting raffle.")
	RaffleH.SavedVariables.bRunning = false
	RaffleH.SavedVariables.bComplete = false
	RaffleH.StartTime()
end

-- Get last raffle results
function RaffleH.GetResults()
	if RaffleH.SavedVariables.prize_1st == nil then
		d("No raffles have been completed as yet")
		return
	end
	if RaffleH.SavedVariables.bComplete == true then
		d("The results from the last raffle.")
	end

	d("Winning ticket "..RaffleH.SavedVariables.last_winningTicket_1st)
	d("Runner-up ticket "..RaffleH.SavedVariables.last_winningTicket_2nd)
	d("Third prize ticket "..RaffleH.SavedVariables.last_winningTicket_3rd)

	d("Winner is: "..RaffleH.SavedVariables.WinnerName_1st.." and received: "..RaffleH.SavedVariables.prize_1st)
	d("Runner-up is: "..RaffleH.SavedVariables.WinnerName_2nd.." and received: "..RaffleH.SavedVariables.prize_2nd)
	d("Third place is: "..RaffleH.SavedVariables.WinnerName_3rd.." and received: "..RaffleH.SavedVariables.prize_3rd)
end
-- End Addition 18/06	------------------------------------------------------------------------------

-- This returns true if rank is higher within the guild
-- However code-wise the ranks are actually reversed (i.e. GM == 1)
function RaffleH.RankIsHigher(guildId_in, gMemName)
	local rankIsHigher = false

	--- Need to loop through the current membership
    numGuildMembers = GetNumGuildMembers(guildId_in)
    if numGuildMembers ~= 0 then
		for memberIndex = 1 , numGuildMembers , 1 do
			--- Get Member info
            ---	 str, 		 str, 		 int, 		   int, 				  int
            local memberName, memberNote, memberRank, memberStatus, memberSecsSinceLogOff = GetGuildMemberInfo(guildId, memberIndex)
            if memberName ~= nil and memberName == gMemName then
				--- Check to see if member rank is equal to or above the cutoff (desiredGuildRankCutoff)
                if memberRank <= desiredGuildRankCutoff then
					rankIsHigher = true
				end
                break
            end
		end
	end
	return rankIsHigher
end

--- Set the current time as the time for raffle start
--- and the end time based off the raffle time period
function RaffleH.StartTime()
	--- Get local time
	local lTimeStamp = GetTimeStamp()

-- Addition 18/06	------------------------------------------------------------------------------
	-- Check if we are already running!!
	if RaffleH.SavedVariables.bRunning == true then
		local timeToGo = RaffleH.TimeToGo()
		d("Raffle already running. Time to go is:"..timeToGo)
		d("Use /rh restart if you wish to restart the raffle timer")
		d("or /rh stopnow if you wish to end the raffle now")
	else
		--- Set the start and end times
		RaffleH.SavedVariables.startTime = lTimeStamp
		RaffleH.SavedVariables.endTime = lTimeStamp + RaffleH.SavedVariables.RaffleTimePeriod
		--- Set raffle as running but not completed
		RaffleH.SavedVariables.bRunning = true
		RaffleH.SavedVariables.bComplete = false
	end
-- End Addition 18/06	------------------------------------------------------------------------------
end

-- Addition 18/06	------------------------------------------------------------------------------
-- Determine time to raffle complete
function RaffleH.TimeToGo()
	-- Not running or complete means 0 TTG
	if RaffleH.SavedVariables.bRunning == false then return 0 end
	if RaffleH.SavedVariables.bComplete == true then return 0 end
	-- Calculate TTG using local time
	local timeToGo = RaffleH.SavedVariables.endTime - GetTimeStamp()
	if timeToGo < 0 then timeToGo = 0 end
	return timeToGo
end

--- Determine if raffle time has ended!
function RaffleH.TimeCheck()
	--- Get local time
	local lTimeStamp = GetTimeStamp()
	if lTimeStamp > RaffleH.SavedVariables.endTime then
		--- Set raffle as not running but completed
		RaffleH.SavedVariables.bRunning = false
		RaffleH.SavedVariables.bComplete = true
	end
end

--- Forces the raffle to end now
function RaffleH.StopNow(bDrawNow)
	if RaffleH.SavedVariables.bRunning == true then
		local ttg = RaffleH.TimeToGo()
		d("Performing a hard stop to current raffle. The Raffle had :"..ttg.." seconds remaining")
		-- Set the end time as current minus 1 second
		RaffleH.SavedVariables.endTime =  GetTimeStamp() - 1
		RaffleH.TimeCheck()
		if RaffleH.SavedVariables.bComplete == true then
			if bDrawNow == true then RaffleH.Draw()
			else d("Raffle is ready for the draw!!. Use /rh draw to perform the draw") end
		end
	elseif RaffleH.SavedVariables.bComplete == true then
		if bDrawNow == true then RaffleH.Draw()
		else d("Raffle is ready for the draw!!. Use /rh draw to perform the draw") end
	end
end
-- End Addition 18/06	------------------------------------------------------------------------------

function RaffleH.Update()
  if RaffleH.active then
	  -- I don't think anything actually needs to happen here!!
	  -- TODO
	  -- Maybe show current QS somewhere?
	  -- Or Show the list of QSs with a highlight?
  end
end

-- Just cause a chain by itself is boring.
function RaffleH.BallAndChain( object )

	local T = {}
	setmetatable( T , { __index = function( self , func )

		if func == "__BALL" then	return object end

		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })

	return T
end

-- Perform a check of the percentages
function RaffleH.CheckPercentage(showMsg)
	local checkTotalPercent = desiredGuildCut + desiredFirstPrize + desiredSecondPrize + desiredThirdPrize
	local isPercentOK = true
	if checkTotalPercent > 1.0 then isPercentOK = false
	elseif checkTotalPercent < 1.0 then isPercentOK = false end
	if showMsg == true then
		if isPercentOK == false then d("Total Percentages are incorrect: ")
		else d("Total Percentages are okay: ") end
		d("Guild Cut: "..desiredGuildCut)
		d("First Prize: "..desiredFirstPrize)
		d("Second Prize: "..desiredSecondPrize)
		d("Third Prize: "..desiredThirdPrize)
		d("Total: "..checkTotalPercent)
		if isPercentOK == false then
            d("You must correct this before performing a raffle!! Use /rh for more details on how to set these parameters")
        end
	end
	return isPercentOK
end

-- Addition 18/06	------------------------------------------------------------------------------
-- Clear all saved data
function RaffleH.ClearAll()
	-- Reset all data to defaults
	desiredGuildName 		= nil
	desiredGuildRankCutoff 	= 3
	desiredTicketPrice 		= 1000
	desiredGuildCut 		= 0.15
	desiredFirstPrize 		= 0.5
	desiredSecondPrize 		= 0.25
	desiredThirdPrize 		= 0.1
	guildNameList = {}
	numGuilds = 0
	ranSeed = GetTimeStamp()
	last_winningTicket_1st = 0
	last_winningTicket_2nd = 0
	last_winningTicket_3rd = 0

	RaffleH.PopulateGuildNameTable()
	desiredGuildName = guildNameList[1]
	RaffleH.SavedVariables.desiredGuildName = desiredGuildName

	RaffleH.SavedVariables.RaffleTimePeriod = 7 * 86400

	RaffleH.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff

	RaffleH.SavedVariables.endTime = GetTimeStamp() + 604801
	RaffleH.SavedVariables.startTime = GetTimeStamp()

	RaffleH.SavedVariables.desiredTicketPrice = desiredTicketPrice

	RaffleH.SavedVariables.desiredGuildCut = desiredGuildCut
	RaffleH.SavedVariables.desiredFirstPrize = desiredFirstPrize
	RaffleH.SavedVariables.desiredSecondPrize = desiredSecondPrize
	RaffleH.SavedVariables.desiredThirdPrize = desiredThirdPrize

	RaffleH.SavedVariables.ranSeed = ranSeed

	RaffleH.SavedVariables.last_winningTicket_1st = last_winningTicket_1st
	RaffleH.SavedVariables.last_winningTicket_2nd = last_winningTicket_2nd
	RaffleH.SavedVariables.last_winningTicket_3rd = last_winningTicket_3rd

	RaffleH.SavedVariables.bRunning = false
	RaffleH.SavedVariables.bComplete = false

	RaffleH.SavedVariables.WinnerName_1st = nil
	RaffleH.SavedVariables.prize_1st = nil
	RaffleH.SavedVariables.WinnerName_2nd = nil
	RaffleH.SavedVariables.prize_2nd = nil
	RaffleH.SavedVariables.WinnerName_3rd = nil
	RaffleH.SavedVariables.prize_3rd = nil
end

-- Show all data
function RaffleH.ShowAll()
	-- Reset all data to defaults
	d("GuildName: "..desiredGuildName)
	d("RankCutoff: "..desiredGuildRankCutoff)
    d("TicketPrice: "..desiredTicketPrice)
    d("GuildCut: "..desiredGuildCut)
	d("FirstPrize: "..desiredFirstPrize)
	d("SecondPrize: "..desiredSecondPrize)
	d("ThirdPrize: "..desiredThirdPrize)
	d("Seed:"..RaffleH.SavedVariables.ranSeed)
	d("Ticket 1:"..last_winningTicket_1st)
	d("Ticket 2:"..last_winningTicket_2nd)
	d("Ticket 3:"..last_winningTicket_3rd)

	d("Period:"..RaffleH.SavedVariables.RaffleTimePeriod)

	d("StartTime:"..RaffleH.SavedVariables.startTime)
	d("EndTime:"..RaffleH.SavedVariables.endTime)

	if RaffleH.SavedVariables.bRunning == true then
        d("Running")
    else d("Not running") end
	if RaffleH.SavedVariables.bComplete == true then
        d("Complete")
    else d("Not complete") end

	d("1st:"..RaffleH.SavedVariables.WinnerName_1st)
	d("2nd:"..RaffleH.SavedVariables.WinnerName_2nd)
	d("3rd:"..RaffleH.SavedVariables.WinnerName_3rd)
	d("Prize 1:"..RaffleH.SavedVariables.prize_1st)
	d("Prize 2:"..RaffleH.SavedVariables.prize_2nd)
	d("Prize 3:"..RaffleH.SavedVariables.prize_3rd)
end

-- End Addition 18/06	------------------------------------------------------------------------------

-- Check if total percentages are too high (greater than 100%)
function RaffleH.CheckPercentageTooHigh()
	local checkTotalPercent = desiredGuildCut + desiredFirstPrize + desiredSecondPrize + desiredThirdPrize
--	d(checkTotalPercent .. "="..desiredGuildCut .."+".. desiredFirstPrize .."+".. desiredSecondPrize .."+".. desiredThirdPrize)
	local isPercentOK = false
	if checkTotalPercent > 1.0 then isPercentOK = true end
	return isPercentOK
end

-- Settings menu --------------------------------------------------------------
-- Make a table of guild names
function RaffleH.PopulateGuildNameTable()
	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 then
		--- Grab the names of the guilds and their index
		for gIndex = 1, numGuilds, 1 do
			local guildId = GetGuildId(gIndex)
			local guildName = GetGuildName(guildId)
			guildNameList[gIndex] = guildName
		end
	end
end

-- Create the settings menu UI using LAM
function RaffleH.CreateSettingsMenu()
   local panelData = {
      type = "panel",
      name = "RaffleHelper",
      displayName = "RaffleHelper",
      author = "Jar-Ek",
      version = 0.1,
      slashCommand = "/rhset",
      registerForRefresh = true,
      registerForDefaults = true,
   }
   LAM:RegisterAddonPanel("RaffleHelperPanel", panelData)

   local optionsTable = {
	[1] = {
		type = "header",
		name = "Raffle Helper Settings",
		width = "full",	--or "half" (optional)
	},
	[2] = {
		type = "description",
		--title = "My Title",	--(optional)
		title = nil,	--(optional)
		text = "Settings for raffle helper, an add-on to help run a raffle",
		width = "full",	--or "half" (optional)
	},
	[3] = {
		type = "button",
		name = "Draw NOW",
		tooltip = "Stop the raffle time and Draw immediately",
		func = function() RaffleH.StopNow(true) end,
		width = "half",	--or "half" (optional)
--		warning = "This will reset all your settings!",	--(optional)
    },
	[4] = {
		type = "dropdown",
		name = "Guild Select",
		tooltip = "Select the correct guild",
		choices = guildNameList,
		getFunc = function() return desiredGuildName end,
		setFunc = function(var)
-- Addition 18/06	------------------------------------------------------------------------------
			if RaffleH.SavedVariables.bRunning == true or RaffleH.SavedVariables.bComplete == true then
				d(colRed.."CANNOT set GuildName to "..colTeal..tostring(var)..colRed..".")
				d(colRed.."GuildName cannot be set whilst raffle running or awaiting a draw."..colWhite.."")
			else
				desiredGuildName = var
				RaffleH.SavedVariables.desiredGuildName = desiredGuildName
			end
-- End Addition 18/06	------------------------------------------------------------------------------
		end,
		width = "half",	--or "half" (optional)
--		warning = "Will need to reload the UI.",	--(optional)
    },
	[5] = {
         type = "slider",
         name = "Guild Cut",
         tooltip = "Set the Guild cut as a percentage",
         min = 0,
         max = 100,
         step = 5,
         getFunc = function() return desiredGuildCut*100 end,
         setFunc = function(val)
				if val == 0 then desiredGuildCut = 0.0
				else desiredGuildCut = val / 100.0 end
				if RaffleH.CheckPercentageTooHigh() then
					desiredGuildCut = RaffleH.SavedVariables.desiredGuildCut
					d("Cannot have a total of greater than 100% from Guild Cut and First, Second and Third Prizes")
				else
					RaffleH.SavedVariables.desiredGuildCut = desiredGuildCut
				end
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.desiredGuildCut * 100,
    },
	[6] = {
         type = "slider",
         name = "First Prize",
         tooltip = "Set the First prize as a percentage",
         min = 0,
         max = 100,
         step = 5,
         getFunc = function() return desiredFirstPrize*100 end,
         setFunc = function(val)
				if val == 0 then desiredFirstPrize = 0.0
				else desiredFirstPrize = val / 100.0 end
				if RaffleH.CheckPercentageTooHigh() then
					desiredFirstPrize = RaffleH.SavedVariables.desiredFirstPrize
					d("Cannot have a total of greater than 100% from Guild Cut and First, Second and Third Prizes")
				else
					RaffleH.SavedVariables.desiredFirstPrize = desiredFirstPrize
				end
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.desiredFirstPrize * 100,
    },
	[7] = {
         type = "slider",
         name = "Second Prize",
         tooltip = "Set the Second prize as a percentage",
         min = 0,
         max = 100,
         step = 5,
         getFunc = function() return desiredSecondPrize*100 end,
         setFunc = function(val)
				if val == 0 then desiredSecondPrize = 0.0
				else desiredSecondPrize = val / 100.0 end
				if RaffleH.CheckPercentageTooHigh() then
					desiredSecondPrize = RaffleH.SavedVariables.desiredSecondPrize
					d("Cannot have a total of greater than 100% from Guild Cut and First, Second and Third Prizes")
				else
					RaffleH.SavedVariables.desiredSecondPrize = desiredSecondPrize
				end
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.desiredSecondPrize * 100,
    },
	[8] = {
         type = "slider",
         name = "Third Prize",
         tooltip = "Set the Third prize as a percentage",
         min = 0,
         max = 100,
         step = 5,
         getFunc = function() return desiredThirdPrize*100 end,
         setFunc = function(val)
				if val == 0 then desiredThirdPrize = 0.0
				else desiredThirdPrize = val / 100.0 end
				if RaffleH.CheckPercentageTooHigh() then
					desiredThirdPrize = RaffleH.SavedVariables.desiredThirdPrize
					d("Cannot have a total of greater than 100% from Guild Cut and First, Second and Third Prizes")
				else
					RaffleH.SavedVariables.desiredThirdPrize = desiredThirdPrize
				end
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.desiredThirdPrize * 100,
    },
	[9] = {
         type = "slider",
         name = "Guild Rank Cutoff",
         tooltip = "Set the rank at which you may may not participate in the raffle (1 = GuildMaster)",
         min = 1,
         max = 5,
         step = 1,
         getFunc = function() return desiredGuildRankCutoff end,
         setFunc = function(val)
				desiredGuildRankCutoff = val
				RaffleH.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.desiredGuildRankCutoff,
    },
	[10] = {
         type = "slider",
         name = "Time Period",
         tooltip = "Set the time period to run the raffle for in days",
         min = 1,
         max = 14,
         step = 1,
         getFunc = function() return RaffleH.SavedVariables.RaffleTimePeriod / 86400 end,
         setFunc = function(val)
				RaffleH.SavedVariables.RaffleTimePeriod = val * 86400
            end,
		 width = "half",	--or "half" (optional)
         default = RaffleH.SavedVariables.RaffleTimePeriod,
    },
-- Addition 18/06	------------------------------------------------------------------------------
	[11] = {
		type = "editbox",
		name = "TicketPrice",
		tooltip = "Ticketprice for 1 ticket.",
		getFunc = function() return tostring(desiredTicketPrice) end,
		setFunc = function(text)
            desiredTicketPrice = tonumber(text)
            RaffleH.SavedVariables.desiredTicketPrice = desiredTicketPrice
		end,
		isMultiline = false,	--boolean
		width = "half",	--or "half" (optional)
--		warning = "Will need to reload the UI.",	--(optional)
		default = "",	--(optional)
    },
	[12] = {
		type = "button",
		name = "Reset",
		tooltip = "Reset the add-on to default values",
		func = function() RaffleH.ClearAll() end,
		width = "half",	--or "half" (optional)
		warning = "This will reset all your settings!",	--(optional)
    },
-- End Addition 18/06	------------------------------------------------------------------------------
   }
   LAM:RegisterOptionControls("RaffleHelperPanel", optionsTable)
end


--- Handle "/" commands
function RaffleH.CommandHandler(text)
	-- put everything in lowercase
	local input = text --string.lower(text)
	-- set up some variables
	local com = {}
	local index = 1

	-- separate arguments
	if text~=nil then
		if ldebug==true then d(text.." "..input) end
		for value in string.gmatch(input,"%w+") do
			com[index] = value
	    	index = index + 1
		end
	end

	-- the check...
-- Addition 18/06	------------------------------------------------------------------------------
	if com[1]=="draw" then
		d("Performing raffle draw")
		RaffleH.Draw()
	elseif com[1]=="check" or com[1] == "status" then
  		d("Performing raffle status check")
		RaffleH.Check()
	elseif com[1]=="start" then
  		d("Starting raffle timer")
		RaffleH.StartTime()
	elseif com[1]=="restart" then
  		d("Restarting raffle timer from now.")
  		d("Any donations from previous raffle will not be included.")
		RaffleH.Restart()
	elseif com[1]=="stopnow" then
  		d("Stopping raffle.")
		RaffleH.StopNow(false)
	elseif com[1]=="drawnow" then
  		d("Stopping raffle and performing draw.")
		RaffleH.StopNow(true)
	elseif com[1]=="results" then
  		d("Getting results of last raffle.")
		RaffleH.GetResults()
	elseif com[1]=="clear" then
  		d("Clearing all saved data.")
		RaffleH.ClearAll()
	elseif com[1]=="show" then
  		d("Show all.")
		RaffleH.ShowAll()
	elseif com[1]=="test" then
  		d("Test Randomness")
		RaffleH.TestRandom()
-- Addition 18/06	------------------------------------------------------------------------------
	elseif com[1]=="list" then
		d("Raffle Helper:"..colWhite.." current settings:")
		d(colWhite.."GuildName: "..colTeal..tostring(desiredGuildName)..colWhite..".")
		d(colWhite.."StartTime: "..colTeal..tostring(RaffleH.SavedVariables.startTime)..colWhite..".")
		d(colWhite.."EndTime: "..colTeal..tostring(RaffleH.SavedVariables.endTime)..colWhite..".")
		d(colWhite.."RaffleRunPeriod: "..colTeal..tostring(RaffleH.SavedVariables.RaffleTimePeriod)..colWhite..".")
		d(colWhite.."RankCuttOff: "..colTeal..tostring(desiredGuildRankCutoff)..colWhite..".")
		d(colWhite.."GuildCut: "..colTeal..tostring(desiredGuildCut)..colWhite..".")
		d(colWhite.."FirstPrize: "..colTeal..tostring(desiredFirstPrize)..colWhite..".")
		d(colWhite.."SecondPrize: "..colTeal..tostring(desiredSecondPrize)..colWhite..".")
		d(colWhite.."ThirdPrize: "..colTeal..tostring(desiredThirdPrize)..colWhite..".")
	elseif com[1]=="set" then
		if com[2]=="guildname" then
			if com[3] ~= nil then
				local buildGuildName = com[3]
				for nameTextIndex = 4, index, 1 do
					if com[nameTextIndex] ~= nil then
						buildGuildName = buildGuildName .. " " .. tostring(com[nameTextIndex])
					end
				end
-- Addition 18/06	------------------------------------------------------------------------------
				if RaffleH.SavedVariables.bRunning == true or RaffleH.SavedVariables.bComplete == true then
					d(colRed.."CANNOT set GuildName to "..colTeal..tostring(buildGuildName)..colRed..".")
					d(colRed.."GuildName cannot be set whilst raffle running or awaiting a draw."..colWhite.."")
				else
					desiredGuildName = buildGuildName
					RaffleH.SavedVariables.desiredGuildName = desiredGuildName
					d(colWhite.."GuildName set to "..colTeal..tostring(desiredGuildName)..colWhite..".")
				end
-- Addition 18/06	------------------------------------------------------------------------------
			end
		elseif com[2]=="raffleperiod" then
			if com[3] ~= nil then
				RaffleH.SavedVariables.RaffleTimePeriod = tonumber(com[3]) * 86400
				d(colWhite.."RaffleTimePeriod set to "..colTeal..tostring(RaffleH.SavedVariables.RaffleTimePeriod)..colWhite.." seconds.")
			end
		elseif com[2]=="ticketprice" then
			if com[3] ~= nil then
                if tonumber(com[3]) > 0 then
                    RaffleH.SavedVariables.desiredTicketPrice = tonumber(com[3])
                    desiredTicketPrice = RaffleH.SavedVariables.desiredTicketPrice
                    d(colWhite.."Ticket price set to "..colTeal..tostring(RaffleH.SavedVariables.desiredTicketPrice)..colWhite..".")
                else
                    d(colWhite.."Ticket price cannot be set to less than 1.")
                end
			end
		elseif com[2]=="guildcut" then
			if com[3] ~= nil then
				RaffleH.SavedVariables.desiredGuildCut = tonumber(com[3])
				if RaffleH.SavedVariables.desiredGuildCut > 1.0 then
					RaffleH.SavedVariables.desiredGuildCut = RaffleH.SavedVariables.desiredGuildCut / 100.0
				end
				desiredGuildCut = RaffleH.SavedVariables.desiredGuildCut
				d(colWhite.."GuildCut set to "..colTeal..tostring(RaffleH.SavedVariables.desiredGuildCut)..colWhite..".")
			end
		elseif com[2]=="firstprize" then
			if com[3] ~= nil then
				RaffleH.SavedVariables.desiredFirstPrize = tonumber(com[3])
				if RaffleH.SavedVariables.desiredFirstPrize > 1.0 then
					RaffleH.SavedVariables.desiredFirstPrize = RaffleH.SavedVariables.desiredFirstPrize / 100.0
				end
				desiredFirstPrize = RaffleH.SavedVariables.desiredFirstPrize
				d(colWhite.."1st prize set to "..colTeal..tostring(RaffleH.SavedVariables.desiredFirstPrize)..colWhite..".")
			end
		elseif com[2]=="secondprize" then
			if com[3] ~= nil then
				RaffleH.SavedVariables.desiredSecondPrize = tonumber(com[3])
				if RaffleH.SavedVariables.desiredSecondPrize > 1.0 then
					RaffleH.SavedVariables.desiredSecondPrize = RaffleH.SavedVariables.desiredSecondPrize / 100.0
				end
				desiredSecondPrize = RaffleH.SavedVariables.desiredSecondPrize
				d(colWhite.."2nd prize set to "..colTeal..tostring(RaffleH.SavedVariables.desiredSecondPrize)..colWhite..".")
			end
		elseif com[2]=="thirdprize" then
			if com[3] ~= nil then
				RaffleH.SavedVariables.desiredThirdPrize = tonumber(com[3])
				if RaffleH.SavedVariables.desiredThirdPrize > 1.0 then
					RaffleH.SavedVariables.desiredThirdPrize = RaffleH.SavedVariables.desiredThirdPrize / 100.0
				end
				desiredThirdPrize = RaffleH.SavedVariables.desiredThirdPrize
				d(colWhite.."3rd prize set to "..colTeal..tostring(RaffleH.SavedVariables.desiredThirdPrize)..colWhite..".")
			end
		elseif com[2]=="rankcutoff" then
			if com[3] ~= nil then
				if tonumber(com[3])>=0 and tonumber(com[3])<=8 then
					desiredGuildRankCutoff = tonumber(com[3])
					RaffleH.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
					d(colWhite.."Rank cutoff set to "..colTeal..tostring(desiredGuildRankCutoff)..colWhite..".")
				end
			end
		end
	else
		d("RaffleHelper"..colWhite.." commands:")
		d(colTeal.."/rafflehelper or /rh")
-- Addition 18/06	------------------------------------------------------------------------------
		d(colTeal.."draw"..colWhite.." - Performs the raffle draw")
		d(colTeal.."check"..colWhite.." - Check raffle status.")
		d(colTeal.."start"..colWhite.." - Start the timer.")
		d(colTeal.."restart"..colWhite.." - Restart the current raffle timer - this will lose any current deposits.")
		d(colTeal.."stopnow"..colWhite.." - Stops the raffle now, regardless of time remaining.")
		d(colTeal.."drawnow"..colWhite.." - Stops the raffle now, regardless of time remaining - and immediately performs the draw")
		d(colTeal.."results"..colWhite.." - Get the results of the last raffle.")
		d(colTeal.."clear"..colWhite.." - Clear all saved data")
-- Addition 18/06	------------------------------------------------------------------------------
		d(colTeal.."list"..colWhite.." - List the current settings")
		d(colTeal.."set <command>"..colWhite.." - To set guild, raffleperiod, rankcutoff, guildcut, firstprize, secondprize, thirdprize")
		d(colTeal.."set guildname <string>"..colWhite.." - To set guild name, where <string> is the guild name")
		d(colTeal.."set raffleperiod <number>"..colWhite.." - To set period for the raffle in days, between start and end")
		d(colTeal.."set rankcutoff <integer>"..colWhite.." - To set the cutoff point at which you may not play. Uses the guild ranks 1 = Master")
		d(colTeal.."set ticketprice <number>"..colWhite.." - To set ticket price in gold")
		d(colTeal.."set guildcut <number>"..colWhite.." - To set guild cut as a percentage of the total")
		d(colTeal.."set firstprize <number>"..colWhite.." - To set first prize as a percent of the total")
		d(colTeal.."set secondprize <number>"..colWhite.." - To set second prize as a percent of the total")
		d(colTeal.."set thirdprize <number>"..colWhite.." - To set third prize as a percent of the total")
	end
end

-- Initialise
function RaffleH.Initialize( self, addOnName )

	if addOnName ~= "RaffleHelper" then return end
	-- Register keybindings
-- Addition 18/06	------------------------------------------------------------------------------
	ZO_CreateStringId("SI_BINDING_NAME_DRAW_RAFFLE", "Perform the raffle draw")
-- Addition 18/06	------------------------------------------------------------------------------
	ZO_CreateStringId("SI_BINDING_NAME_CHECK_RAFFLE", "Check the raffle")
	ZO_CreateStringId("SI_BINDING_NAME_START_RAFFLE", "Set the raffle going")
	ZO_CreateStringId("SI_BINDING_NAME_STOPDRAW_RAFFLE", "Ends the raffle immediately and perform the draw")

    RaffleH.PopulateGuildNameTable()

-- Addition 18/06	------------------------------------------------------------------------------
	RaffleH.SavedVariables = ZO_SavedVars:NewAccountWide("RaffleHelper_Save", 28, nil, {})
-- Addition 18/06	------------------------------------------------------------------------------

	-- Since we added some fields we have to add them here, or users will have to reconfigure.
	if RaffleH.SavedVariables.desiredGuildName ~= nil then
		desiredGuildName = RaffleH.SavedVariables.desiredGuildName
    else
-- Addition 18/06	------------------------------------------------------------------------------
		if numGuilds > 0 then
			desiredGuildName = guildNameList[1]
		else
			desiredGuildName = ""
		end
        RaffleH.SavedVariables.desiredGuildName = desiredGuildName
-- Addition 18/06	------------------------------------------------------------------------------
	end

	if RaffleH.SavedVariables.RaffleTimePeriod == nil then
		RaffleH.SavedVariables.RaffleTimePeriod = 7 * 86400
	end

	if RaffleH.SavedVariables.desiredGuildRankCutoff ~= nil then
		desiredGuildRankCutoff = RaffleH.SavedVariables.desiredGuildRankCutoff
    else
        RaffleH.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
	end

	if RaffleH.SavedVariables.endTime == nil then
		RaffleH.SavedVariables.endTime = GetTimeStamp() + 604801
	end

	if RaffleH.SavedVariables.startTime == nil then
		RaffleH.SavedVariables.startTime = GetTimeStamp()
	end

	if RaffleH.SavedVariables.desiredTicketPrice == nil then
		RaffleH.SavedVariables.desiredTicketPrice = desiredTicketPrice
	else
		desiredTicketPrice = RaffleH.SavedVariables.desiredTicketPrice
	end

	if RaffleH.SavedVariables.desiredGuildCut == nil then
		RaffleH.SavedVariables.desiredGuildCut = desiredGuildCut
	else
		desiredGuildCut = RaffleH.SavedVariables.desiredGuildCut
	end

	if RaffleH.SavedVariables.desiredFirstPrize == nil then
		RaffleH.SavedVariables.desiredFirstPrize = desiredFirstPrize
	else
		desiredFirstPrize = RaffleH.SavedVariables.desiredFirstPrize
	end

	if RaffleH.SavedVariables.desiredSecondPrize == nil then
		RaffleH.SavedVariables.desiredSecondPrize = desiredSecondPrize
	else
		desiredSecondPrize = RaffleH.SavedVariables.desiredSecondPrize
	end

	if RaffleH.SavedVariables.desiredThirdPrize == nil then
		RaffleH.SavedVariables.desiredThirdPrize = desiredThirdPrize
	else
		desiredThirdPrize = RaffleH.SavedVariables.desiredThirdPrize
	end

	if RaffleH.SavedVariables.ranSeed == nil then
		RaffleH.SavedVariables.ranSeed = ranSeed
	else
		ranSeed = RaffleH.SavedVariables.ranSeed
	end

	if RaffleH.SavedVariables.last_winningTicket_1st == nil then
		RaffleH.SavedVariables.last_winningTicket_1st = last_winningTicket_1st
	else
		last_winningTicket_1st = RaffleH.SavedVariables.last_winningTicket_1st
	end

	if RaffleH.SavedVariables.last_winningTicket_2nd == nil then
		RaffleH.SavedVariables.last_winningTicket_2nd = last_winningTicket_2nd
	else
		last_winningTicket_2nd = RaffleH.SavedVariables.last_winningTicket_2nd
	end

	if RaffleH.SavedVariables.last_winningTicket_3rd == nil then
		RaffleH.SavedVariables.last_winningTicket_3rd = last_winningTicket_3rd
	else
		last_winningTicket_3rd = RaffleH.SavedVariables.last_winningTicket_3rd
	end

-- Addition 18/06	------------------------------------------------------------------------------
	if RaffleH.SavedVariables.bRunning == nil then
		RaffleH.SavedVariables.bRunning = false
	end

	if RaffleH.SavedVariables.bComplete == nil then
		RaffleH.SavedVariables.bComplete = false
	end

	RaffleH.TimeCheck()
	if RaffleH.SavedVariables.bComplete == true then
		d("Raffle is ready for the draw!!. Use /rh draw to perform the draw")
	end
-- Addition 18/06	------------------------------------------------------------------------------

	SLASH_COMMANDS["/rafflehelper"] = RaffleH.CommandHandler
	SLASH_COMMANDS["/rh"] = RaffleH.CommandHandler

    RaffleH.CreateSettingsMenu()
    RaffleH.RequestGuildBankData()

	-- Display successful startup
	d( "RaffleHelper Enabled!" )
end

function RaffleH.RequestGuildBankData()
	local nGuilds = GetNumGuilds()
	if nGuilds ~= 0 then
        for gIndex = 1, nGuilds, 1 do
            local guildId = GetGuildId(gIndex)
            local pageavail = RequestGuildHistoryCategoryNewest(guildId, GUILD_HISTORY_BANK)
        end
    end
end

function RaffleH.RequestMoreGuildBankData(gId)
    local bMoreDeposits = DoesGuildHistoryCategoryHaveMoreEvents(gId, GUILD_HISTORY_BANK)
    if bMoreDeposits == true then
        local bRequestMore = RequestGuildHistoryCategoryOlder(gId, GUILD_HISTORY_BANK)
        return bRequestMore
    else
        return false
    end
end

-- Init Hook --
EVENT_MANAGER:RegisterForEvent("RaffleH", EVENT_ADD_ON_LOADED, RaffleH.Initialize )
