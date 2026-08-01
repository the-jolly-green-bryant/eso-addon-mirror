--
-- SalesCalc
--
SCalc = {}

ldebug = false
desiredGuildName 		= "Temple of Traders"
desiredGuildRankCutoff 	= 3							-- Note 1 = Grandmaster, 2 = Second-in-command, etc
desiredSalesCalcTimeGap = 604800					-- 7 days
desiredDepositLevel		= 1000						-- 1000g per point
lastRunTime_Sales		= GetTimeStamp() - desiredSalesCalcTimeGap - 1
lastRunTime_Deposit		= GetTimeStamp() - desiredSalesCalcTimeGap - 1

-- Setup Colours?
local colWhite     = "|cFFFFFF" -- white (c1)
local colYellow    = "|cFFFF00" -- yellow (c2)
local colGreen     = "|c00FF00" -- green (c3)
local colTeal      = "|c00FFFF" -- teal (c4)
local colRed       = "|cFF0000" -- Red


--- Calculate the sales
function SCalc.CalculateFromSales()
	local runSales = true

	--- Get local time and calculate elapsed time from last run
	local lTimeStamp = GetTimeStamp()
	timeDiff = lTimeStamp - lastRunTime_Sales

	--- Check time is ok
--	if timeDiff < desiredSalesCalcTimeGap then
--		d("Time too short for run")
--		runSales = false
--	end

	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 and runSales == true then
        local timeInDays = desiredSalesCalcTimeGap/86400
		d("Running sales calculations for "..desiredGuildName.." for sales in last "..timeInDays.." days")
		--- Need to find correct guild!!
		for gIndex = 1, numGuilds, 1 do
			guildId = GetGuildId(gIndex)
			guildName = GetGuildName(guildId)
			if guildName == desiredGuildName then
				--- Need to clear all previous names / totals
				--RequestHistoryCategoryNewest(guildId, GUILD_HISTORY_STORE_PURCHASES)

				--- Need to loop through the current sales history (one item at a time)
				numGuildSales = GetNumGuildEvents(guildId, GUILD_HISTORY_STORE)
				d("Sales "..numGuildSales)
				if numGuildSales ~= 0 then
					local memberNameList = {}
					local salesCount = {}
					local valueCount = {}
					local numberOfMembersInList = 0
					for salesIndex = 1 , numGuildSales , 1 do
						local eventType, secondsSinceSale, seller, buyer, quant, itemName, price, spare1 = GetGuildEventInfo(guildId, GUILD_HISTORY_STORE, salesIndex)
--						d("Sale:"..salesIndex.."Seconds"..secondsSinceSale.."seller:"..seller.."buyer:"..buyer.."quant:"..quant.."item:"..itemName.."price:"..price)

						local currentMemberName = seller
						local salevalue = price

                        if ldebug == true then
                            if currentMemberName == "Uraacil in Vulkhel Guard" then
                                d("eventType"..eventType)
                                d("seller "..seller)
                                d("buyer "..buyer)
                                d("quant "..quant)
                                d("itemName "..itemName)
                                d("price "..price)
                                d("spare1 "..spare1)
                            end
                        end
						-- Add a check for rank
						local rankIsTooHigh = SCalc.RankIsHigher(guildId, currentMemberName)

						--- If sale is time within time boundary (can be set), calculated from current time - saved time
						-- 15 is a valid sale
						if rankIsTooHigh == false and secondsSinceSale < desiredSalesCalcTimeGap and eventType == 15 then
							--- New list
							if numberOfMembersInList == 0 then
								memberNameList[1] = currentMemberName
								salesCount[1] = 1
								valueCount[1] = salevalue
								numberOfMembersInList = 1
							else
								local isNewMember = true
								for listOfSellersIndex = 1, numberOfMembersInList, 1 do
									if memberNameList[listOfSellersIndex] == currentMemberName then
										salesCount[listOfSellersIndex] = salesCount[listOfSellersIndex] + 1
										valueCount[listOfSellersIndex] = valueCount[listOfSellersIndex] + salevalue
										isNewMember = false
									end
								end
								if isNewMember == true then
									numberOfMembersInList = numberOfMembersInList + 1
									memberNameList[numberOfMembersInList] = currentMemberName
									salesCount[numberOfMembersInList] = 1
									valueCount[numberOfMembersInList] = salevalue
								end
							end
							if ldebug == true then
                                d("NumMembersInList "..numberOfMembersInList)
                                d("memberNameList "..memberNameList[numberOfMembersInList])
                                d("salesCount "..salesCount[numberOfMembersInList])
                                d("valueCount "..valueCount[numberOfMembersInList])
                            end
						end

					end
					if numberOfMembersInList ~= 0 then
						local numTopSales = 10
						local numTopValue = 2
						local topList_Sales = {}
						local topList_Value = {}

						if numberOfMembersInList < numTopSales then
							numTopSales = numberOfMembersInList
						end
						if numberOfMembersInList < numTopValue then
							numTopValue = numberOfMembersInList
						end

                        if ldebug == true then d("NumMembersInList "..numberOfMembersInList) end

						--- List top X (defined) by total number of sales (name, number, value)
						for listOfSellersIndex = 1, numberOfMembersInList, 1 do
							--- Fill top X by value
							if listOfSellersIndex <= numTopValue then
								topList_Value[listOfSellersIndex] = listOfSellersIndex
							else
								local replaceThisIndex = 0
								local replaceThisValue = 0
								--- Go through current list to determine which to replace (if any)
								for topListIndex = 1, numTopValue, 1 do
									--- If currentListValue less than next in main list
									local topValIndex = topList_Value[topListIndex]
									if ldebug == true then
                                        d("TopVal "..valueCount[topValIndex])
                                        d("SIndex "..listOfSellersIndex)
                                        d("Sellers ".. valueCount[listOfSellersIndex])
									end
									if valueCount[topValIndex] < valueCount[listOfSellersIndex] then
										if replaceThisIndex == 0 then
											replaceThisIndex = topListIndex
											replaceThisValue = valueCount[topValIndex]
										else
											if valueCount[topValIndex] < replaceThisValue then
												replaceThisIndex = topListIndex
												replaceThisValue = valueCount[topValIndex]
											end
										end
									end
								end
								if replaceThisIndex ~= 0 then
									topList_Value[replaceThisIndex] = listOfSellersIndex
								end
							end
							--- Fill top X by sales
							if listOfSellersIndex <= numTopSales then
								topList_Sales[listOfSellersIndex] = listOfSellersIndex
							else
								local replaceThisIndex = 0
								local replaceThisValue = 0
								--- Go through current list to determine which to replace (if any)
								for topListIndex = 1, numTopSales, 1 do
									--- If currentListValue less than next in main list
									local topSaleIndex = topList_Sales[topListIndex]
									if salesCount[topSaleIndex] < salesCount[listOfSellersIndex] then
										if replaceThisIndex == 0 then
											replaceThisIndex = topListIndex
											replaceThisValue = salesCount[topSaleIndex]
										else
											if salesCount[topSaleIndex] < replaceThisValue then
												replaceThisIndex = topListIndex
												replaceThisValue = salesCount[topSaleIndex]
											end
										end
									end
								end
								if replaceThisIndex ~= 0 then
									topList_Sales[replaceThisIndex] = listOfSellersIndex
								end
							end
						end

						d("Top Sales by volume:")
						for topListIndex = 1, numTopSales, 1 do
							local topSaleIndex = topList_Sales[topListIndex]
							d(memberNameList[topSaleIndex].. " ".. salesCount[topSaleIndex])
						end

						d("Top Sales by value:")
						for topListIndex2 = 1, numTopValue, 1 do
							local topValIndex = topList_Value[topListIndex2]
							d(memberNameList[topValIndex].. " ".. valueCount[topValIndex])
						end
					end
					-- Set last run time as now
--					SCalc.savedVariables.lastRunTime = GetTimeStamp()
--					lastRunTime = GetTimeStamp()
				end
				break
			end
		end
	end
end

--- Calculate the sales
function SCalc.CalculateFromDonation()
	local runDonationCalc = true

	--- Get local time and calculate elapsed time from last run
	local lTimeStamp = GetTimeStamp()
	timeDiff = lTimeStamp - lastRunTime_Deposit

	--- Check time is ok
--	if timeDiff < desiredSalesCalcTimeGap then
--		d("Time too short for run")
--		runDonationCalc = false
--	end

	--- Get number of guilds
	numGuilds = GetNumGuilds()
	if numGuilds ~= 0 and runDonationCalc == true then
        local timeInDays = desiredSalesCalcTimeGap/86400
		d("Running deposit calculations for "..desiredGuildName.." for sales in last "..timeInDays.." days")
		--- Need to find correct guild!!
		for gIndex = 1, numGuilds, 1 do
			guildId = GetGuildId(gIndex)
			guildName = GetGuildName(guildId)
			if guildName == desiredGuildName then
				--- Need to loop through the current bank deposit history
				--RequestHistoryCategoryNewest(guildId, GUILD_HISTORY_BANK_DEPOSITS)

				--- Need to loop through the current sales history (one item at a time)
				numGuildDeposits = GetNumGuildEvents(guildId, GUILD_HISTORY_BANK)
                d("numGuildDeposits"..numGuildDeposits)

				if numGuildDeposits ~= 0 then
					local memberNameList = {}
					local depositTotal = {}
					local pointsTotal = {}
					local numberOfMembersInList = 0
					for depositIndex = 1 , numGuildDeposits , 1 do
						local eventType, secondsSinceDeposit, depositerName, amount, param3, param4, param5, param6 = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, depositIndex)

                        if eventType == GUILD_EVENT_BANKGOLD_ADDED then
                            local currentMemberName = depositerName
                            local depositvalue = amount

                            -- Add a check for rank
                            local rankIsTooHigh = SCalc.RankIsHigher(guildId, currentMemberName)

                            --- If sale is time within time boundary (can be set), calculated from current time - saved time
                            if rankIsTooHigh == false and secondsSinceDeposit < desiredSalesCalcTimeGap then
                                --- New list
                                if numberOfMembersInList == 0 then
                                    memberNameList[1] = currentMemberName
                                    depositTotal[1] = depositvalue
                                    pointsTotal[1] = 0
                                    numberOfMembersInList = 1
                                else
                                    local isNewMember = true
                                    for listOfSellersIndex = 1, numberOfMembersInList, 1 do
                                        if memberNameList[listOfSellersIndex] == currentMemberName then
                                            depositTotal[listOfSellersIndex] = depositTotal[listOfSellersIndex] + depositvalue
                                            isNewMember = false
                                        end
                                    end
                                    if isNewMember == true then
                                        numberOfMembersInList = numberOfMembersInList + 1
                                        memberNameList[numberOfMembersInList] = currentMemberName
                                        depositTotal[numberOfMembersInList] = depositvalue
                                        pointsTotal[numberOfMembersInList] = 0
                                    end
                                end
                            end
                        end
					end
					if numberOfMembersInList ~= 0 then

						--- List top X (defined) by total number of sales (name, number, value)
						for listOfDonatorsIndex = 1, numberOfMembersInList, 1 do
							pointsTotal[listOfDonatorsIndex] = math.floor (depositTotal[listOfDonatorsIndex] / desiredDepositLevel)
							d(memberNameList[listOfDonatorsIndex].." gets "..pointsTotal[listOfDonatorsIndex].." points for donations of "..depositTotal[listOfDonatorsIndex])
--							print(memberNameList[listOfDonatorsIndex].." gets "..pointsTotal[listOfDonatorsIndex].." points for donations of "..depositTotal[listOfDonatorsIndex])
						end
					end
--					lastRunTime_Deposit = GetTimeStamp()
--					SCalc.savedVariables.lastRunTime_Deposit = lastRunTime_Deposit
				end
				break
			end
		end
	end
end

-- This returns true if rank is higher within the guild (i.e. Grandmaster always passes)
-- However code-wise the ranks are actually reversed (i.e. GM == 1)
function SCalc.RankIsHigher(guildId_in, gMemName)
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

function SCalc.Reset()
	lastRunTime_Sales		= GetTimeStamp() - desiredSalesCalcTimeGap - 1
	lastRunTime_Deposit		= GetTimeStamp() - desiredSalesCalcTimeGap - 1
end

-- The function to do nothing!
function SCalc.doNothing()
end

-- The update function doesn't need to do anything
function SCalc.Update()
  if SCalc.active then
		-- I don't think anything actually needs to happen here!!
		-- but we must have a function or get a compilation error
		function SCalc.doNothing()
		end
  end
end

-- Just cause a chain by itself is boring.
function SCalc.BallAndChain( object )

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


---## Start of function to handle commands
local function commandHandler(text)
	-- put everything in lowercase
	local input = string.lower(text)
	-- set up some variables
	local com = {}
	local index = 1

	-- separate arguments
	if text~=nil then
--		if ldebug==true then d(text.." "..input) end
		for value in string.gmatch(input,"%w+") do
			com[index] = value
	    	index = index + 1
		end
	end

	-- the check...
	if com[1]=="calcsales" then
  		d("Performing sales calculations")
		SCalc.CalculateFromSales()
	elseif com[1]=="calcdeposits" then
  		d("Performing deposits calculations")
		SCalc.CalculateFromDonation()
	elseif com[1]=="reset" then
  		d("Resetting times")
		SCalc.Reset()
	elseif com[1]=="list" then
		d("Sales Calc:"..colWhite.." current settings:")
		d(colWhite.."GuildName: "..colTeal..tostring(desiredGuildName)..colWhite.."")
		d(colWhite.."DepositLevel: "..colTeal..tostring(desiredDepositLevel)..colWhite.."g.")
		d(colWhite.."SalesTime: "..colTeal..tostring(desiredSalesCalcTimeGap)..colWhite.."s.")
		d(colWhite.."RankCuttOff: "..colTeal..tostring(desiredGuildRankCutoff)..colWhite.."")
	elseif com[1]=="set" then

		if com[2]=="guildname" then
			if com[3] ~= nil then
				local buildGuildName = com[3]
				for nameTextIndex = 1, index, 1 do
					if com[nameTextIndex+3] ~= nil then
						buildGuildName = buildGuildName + " " + tostring(com[nameTextIndex+3])
					end
				end
				desiredGuildName = buildGuildName
		        SCalc.SavedVariables.desiredGuildName = desiredGuildName
				d(colWhite.."GuildName set to"..colTeal..tostring(desiredGuildName)..colWhite..".")
			end
		elseif com[2]=="deposit" then
			if com[3] ~= nil then
				desiredDepositLevel = tonumber(com[3])
				SCalc.SavedVariables.desiredDepositLevel = desiredDepositLevel
				d(colWhite.."Deposit set to"..colTeal..tostring(desiredDepositLevel)..colWhite.."g per point.")
			end
		elseif com[2]=="salestime" then
			if com[3] ~= nil then
				desiredSalesCalcTimeGap = tonumber(com[3]) * 86400
				SCalc.SavedVariables.desiredSalesCalcTimeGap = desiredSalesCalcTimeGap
				d(colWhite.."Time between sales calcs set to"..colTeal..tostring(desiredSalesCalcTimeGap)..colWhite.." seconds.")
			end
		elseif com[2]=="rankcutoff" then
			if com[3] ~= nil then
				if tonumber(com[3])>=0 and tonumber(com[3])<=8 then
					desiredGuildRankCutoff = tonumber(com[3])
					SCalc.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
					d(colWhite.."Rank cutoff set to"..colTeal..tostring(desiredGuildRankCutoff)..colWhite..".")
				end
			end
		end
	else
		d("SalesCalc"..colWhite.." commands:")
		d(colTeal.."/salescalc or /sc")
		d(colTeal.."calcdeposits"..colWhite.." - Perform an deposit calculation.")
		d(colTeal.."calcsales"..colWhite.." - Perform a sales calculation.")
		d(colTeal.."set"..colWhite.." - To set guild, deposit, salestime, or rankcutoff")
		d(colTeal.."list"..colWhite.." - List the current settings")
	end
end
----### end of function

local function Initialize( self, addOnName )
	if addOnName ~= "SalesCalc" then return end

	-- Register keybindings
	ZO_CreateStringId("SI_BINDING_NAME_SC_CALCULATE_SALES", "Perform Sales Calculation")
	ZO_CreateStringId("SI_BINDING_NAME_SC_CALCULATE_DONATIONS", "Perform Deposits Calculation")

	SCalc.SavedVariables = ZO_SavedVars:NewAccountWide("SalesCalc_Save", 6, nil, {})

	-- Since we added some fields we have to add them here, or users will have to reconfigure.
	if SCalc.SavedVariables.desiredGuildName ~= nil then
		desiredGuildName = SCalc.SavedVariables.desiredGuildName
    else
        SCalc.SavedVariables.desiredGuildName = desiredGuildName
	end

	if SCalc.SavedVariables.desiredSalesCalcTimeGap ~= nil then
		desiredSalesCalcTimeGap = SCalc.SavedVariables.desiredSalesCalcTimeGap
    else
        SCalc.SavedVariables.desiredSalesCalcTimeGap = desiredSalesCalcTimeGap
	end

	if SCalc.SavedVariables.desiredGuildRankCutoff ~= nil then
		desiredGuildRankCutoff = SCalc.SavedVariables.desiredGuildRankCutoff
    else
        SCalc.SavedVariables.desiredGuildRankCutoff = desiredGuildRankCutoff
	end

	if SCalc.SavedVariables.desiredDepositLevel ~= nil then
		desiredDepositLevel = SCalc.SavedVariables.desiredDepositLevel
    else
        SCalc.SavedVariables.desiredDepositLevel = desiredDepositLevel
	end

	if SCalc.SavedVariables.lastRunTime_Sales ~= nil then
		lastRunTime_Sales = SCalc.SavedVariables.lastRunTime_Sales
    else
        SCalc.SavedVariables.lastRunTime_Sales = lastRunTime_Sales
	end

	if SCalc.SavedVariables.lastRunTime_Deposit ~= nil then
		lastRunTime_Deposit = SCalc.SavedVariables.lastRunTime_Deposit
    else
        SCalc.SavedVariables.lastRunTime_Deposit = lastRunTime_Deposit
	end

	SLASH_COMMANDS["/salescalc"] = commandHandler
	SLASH_COMMANDS["/sc"] = commandHandler

	--SCalc.AutoKick()

	-- Display successful startup
	d( "SalesCalc Enabled!" )
end


-- Init Hook --
EVENT_MANAGER:RegisterForEvent("SalesCalc", EVENT_ADD_ON_LOADED, Initialize )
