local chat = LibChatMessage("Monster Set Shoulder Collector", "MSSC")


MonsterSetShoulderCollector = {
	dashedLines = "---------------------------------------",
	mysteryCofferMaj = "Maj's Mystery Coffer",
	mysteryCofferGlirion = "Glirion's Mystery Coffer",
	mysteryCofferUrgarlag = "Urgarlag's Mystery Coffer",
	mysteryCofferImperialCity = "Imperial City Mystery Coffer"
}

MonsterSetShoulderCollector.name = "MonsterSetShoulderCollector"

-- Accepts a number
-- Returns imported number truncated to 2 decimal places
function MonsterSetShoulderCollector.RoundToDecimalPoints(num, decPoints)
  return tonumber(string.format("%." .. (decPoints) .. "f", num))
end

-- Accepts set ID of an item
-- Generates a string that ESO interprets as a link for an item
function MonsterSetShoulderCollector.MakeItemLink(id)
	local itemLink = string.format("|H1:item:%d:364:50:0:0:0:0:0:0:0:0:0:0:0:0:ITEMSTYLE_NONE:0:0:0:10000:0|h|h", id)

	return(itemLink)
end

-- Accepts a coffer name, amount of shoulders in that coffer and the amount of shoulders collected from that coffer
-- Returns a string that will display the box name, amount of shoulders from that coffer collected as a fraction and the chance of unlocking a new piece from that coffer
function MonsterSetShoulderCollector.printBoxData(boxName, totalBoxShoulders, collectedBoxShoulders)
	output = boxName .. " - " ..  collectedBoxShoulders .. "/" .. totalBoxShoulders .. " collected - " .. 
		MonsterSetShoulderCollector.RoundToDecimalPoints(100 - collectedBoxShoulders / totalBoxShoulders * 100, 2) .. "% chance of unlocking a new piece"
	return output
end

-- Accepts a mystery coffer name, amount of shoulders in that coffer and the amount of shoulders collected from that coffer
-- If I've got X chance of unlocking a new piece from a mystery coffer, then i have 1 - (1-X)^Y chance of unlocking a new piece from Y mystery coffers  - Kyzeragon
-- Returns a string that will display the box name and the chance of getting at least 1 shoulder piece from spending 5 keys on that coffer
function MonsterSetShoulderCollector.printMysteryBox5KeyData(boxName, totalBoxShoulders, collectedBoxShoulders, mysteryBoxCost, mysteryBoxCurrency, mysteryCoffersPerNormalCofferCost)
	chanceofNewShoulder1Mystery = MonsterSetShoulderCollector.RoundToDecimalPoints(collectedBoxShoulders / totalBoxShoulders, 4)
	chanceofNewShoulderXMystery = MonsterSetShoulderCollector.RoundToDecimalPoints(100 - (chanceofNewShoulder1Mystery ^ mysteryCoffersPerNormalCofferCost * 100), 2)
	return (boxName .. " - Chance of getting at least one new piece from " .. mysteryBoxCost .. " " .. mysteryBoxCurrency .. " is " .. chanceofNewShoulderXMystery .. "%")
end

-- Accepts a subtable of a pledge giver and prints links for all the tables items and states if each piece is collected
-- Used only in early testing, probably should delete
function MonsterSetShoulderCollector.PrintLinksOfTable(inTable)
	d(inTable[7])
	for i = 1, #inTable - 1 do
		itemLink = MonsterSetShoulderCollector.MakeItemLink(inTable[i])
		d(itemLink)
		d(IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)))
	end
end

-- Accepts a subtable from data file of one of the pledge givers
-- Returns the amount of shoulders that are collected and name of dungeon group from table
function MonsterSetShoulderCollector.AmountOfShouldersInTableCollected(inTable, cofferTitleLocation)
	amountCollected = 0
	cofferGroup = inTable[cofferTitleLocation]
	
	for i = 1, #inTable - 1 do
		itemLink = MonsterSetShoulderCollector.MakeItemLink(inTable[i])
		if (IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)))
		then
			amountCollected = amountCollected + 1
		end
	end
	return amountCollected, cofferGroup
end

-- Accepts a group of tables (Maj/Glirion/Urgarlag) and name of pledge givers mystery coffer
-- Displays the amount of pieces collected from each coffer the pledge giver offers as well as the chance of getting a new piece from each coffer
-- Returns nothing
function MonsterSetShoulderCollector.ShowAllPledgeGiver(inTable, inMysteryCofferName)
	LibChatMessage:SetTagPrefixMode(2)		--Enables LibChatMessge preffix

	chat:Print(MonsterSetShoulderCollector.dashedLines)

	LibChatMessage:SetTagPrefixMode(1)		--Disables LibChatMessge preffix

	totalShoulders = 0
	collectedShoulders = 0
	shouldersPerCoffer = 6 --Pledge coffers each have 2 sets, giving 6 potential shoulders
	for k,v in pairs(inTable) do
		amountCollected, dungeonGroup = MonsterSetShoulderCollector.AmountOfShouldersInTableCollected(inTable[k], 7)
		output = MonsterSetShoulderCollector.printBoxData(dungeonGroup, 6, amountCollected)
		totalShoulders = totalShoulders + 6
		collectedShoulders = collectedShoulders + amountCollected
		chat:Print(output)
	end
	chat:Print(MonsterSetShoulderCollector.printBoxData(inMysteryCofferName, totalShoulders, collectedShoulders))
	chat:Print(MonsterSetShoulderCollector.printMysteryBox5KeyData(inMysteryCofferName, totalShoulders, collectedShoulders, 5, "keys", 5))
end

-- Accepts a group of tables (Imperial City) and name of associated mystery coffer
-- Displays the amount of pieces collected from each coffer from the mystery coffer as well as the chance of getting a new piece from each coffer
-- Returns nothing
function MonsterSetShoulderCollector.ShowImperialCity(inTable, inMysteryCofferName)
	LibChatMessage:SetTagPrefixMode(2)		--Enables LibChatMessge preffix
	
	chat:Print(MonsterSetShoulderCollector.dashedLines)
	
	LibChatMessage:SetTagPrefixMode(1)		--Disables LibChatMessge preffix
	
	totalShoulders = 0
	collectedShoulders = 0
	shouldersPerCoffer = 3 --Imperial City Coffers only contain one set, as opposed to the two that pledge coffers have
	for k,v in pairs(inTable) do
		amountCollected, dungeonGroup = MonsterSetShoulderCollector.AmountOfShouldersInTableCollected(inTable[k], 4)
		output = MonsterSetShoulderCollector.printBoxData(dungeonGroup, shouldersPerCoffer, amountCollected)
		totalShoulders = totalShoulders + shouldersPerCoffer
		collectedShoulders = collectedShoulders + amountCollected
		chat:Print(output)
	end
	chat:Print(MonsterSetShoulderCollector.printBoxData(inMysteryCofferName, totalShoulders, collectedShoulders))
	chat:Print(MonsterSetShoulderCollector.printMysteryBox5KeyData(inMysteryCofferName, totalShoulders, collectedShoulders, 20000,  "tel var", 2))
end

-- Accepts a group of tables (Maj/Glirion/Urgarlag)
-- Calculates the shoulder box with the highest chance of producing an uncollected shoulder per key
-- Returns name of most effficient box, the amount collected of the most efficient box, overall shoulders in table and overall collected shoulders in table
function MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(inTable, cofferTitleLocation)
	-- Values to store data for 1 key boxes
	totalShouldersAmount = 0
	totalCollectedShouldersAmount = 0
	
	mostEfficientBox = ""
	mostEfficientAmount = 100 -- Any value > 6 should do

	for k,v in pairs(inTable) do
		tempAmount, tempName = MonsterSetShoulderCollector.AmountOfShouldersInTableCollected(inTable[k], cofferTitleLocation)
		totalShouldersAmount = totalShouldersAmount + 6
		totalCollectedShouldersAmount = totalCollectedShouldersAmount + tempAmount
		if (tempAmount < mostEfficientAmount) then
			mostEfficientAmount = tempAmount
			mostEfficientBox = tempName
		end
	end
	return mostEfficientBox, mostEfficientAmount, totalShouldersAmount, totalCollectedShouldersAmount
end

-- Accepts nothing
-- Prints the most efficient 1 key and 5 key undaunted purchases to chat
-- Returns nothing
function MonsterSetShoulderCollector.CalculateMostEfficientKeyPurchases()
	mostEfficientBox, mostEfficientAmount, shouldersAmount, collectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Maj, 7)
	
	mostEfficientMysteryBox = "Maj's Mystery Coffer"
	
	tempMostEfficientBox, tempMostEfficientAmount, tempShouldersAmount, tempCollectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Glirion, 7)
	
	if (tempMostEfficientAmount < mostEfficientAmount) then
		mostEfficientAmount = tempMostEfficientAmount
		mostEfficientBox = tempMostEfficientBox
	end
	
	if (tempCollectedShouldersAmount / tempShouldersAmount < collectedShouldersAmount / shouldersAmount) then
		collectedShouldersAmount = tempCollectedShouldersAmount
		shouldersAmount = tempShouldersAmount
		mostEfficientMysteryBox = "Glirion's Mystery Coffer"
	end
		
	tempMostEfficientBox, tempMostEfficientAmount, tempShouldersAmount, tempCollectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Urgarlag, 7)
	
	if (tempMostEfficientAmount < mostEfficientAmount) then
		mostEfficientAmount = tempMostEfficientAmount
		mostEfficientBox = tempMostEfficientBox
	end
	
	if (tempCollectedShouldersAmount / tempShouldersAmount < collectedShouldersAmount / shouldersAmount) then
		collectedShouldersAmount = tempCollectedShouldersAmount
		shouldersAmount = tempShouldersAmount
		mostEfficientMysteryBox = "Urgarlag's Mystery Coffer"
	end
	
	fiveKeyOutputString = "Best 5 key purchase is " .. MonsterSetShoulderCollector.printBoxData(mostEfficientBox, 6, mostEfficientAmount)
	
	oneKeyOutputString = "Best 1 key purchase is " .. MonsterSetShoulderCollector.printBoxData(mostEfficientMysteryBox, shouldersAmount, collectedShouldersAmount)
	
	LibChatMessage:SetTagPrefixMode(2)		--Enables LibChatMessge preffix
	
	chat:Print(MonsterSetShoulderCollector.dashedLines)
	
	LibChatMessage:SetTagPrefixMode(1)		--Disables LibChatMessge preffix
	
	chat:Print(fiveKeyOutputString)
	chat:Print(oneKeyOutputString)

	chat:Print(MonsterSetShoulderCollector.printMysteryBox5KeyData(mostEfficientMysteryBox, shouldersAmount, collectedShouldersAmount,  5, "keys", 5))
end

-- Accepts nothing
-- Displays amount of pieces collected from all 1 key undaunted mystery coffers, in fraction and percentage formats
-- Returns nothing
function MonsterSetShoulderCollector.ShowAllMysteryCoffers()
	_, _, majMaxShouldersAmount, majCollectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Maj, 7)
	_, _, glirionMaxShouldersAmount, glirionCollectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Glirion, 7)
	_, _, urgarlagMaxShouldersAmount, urgarlagCollectedShouldersAmount 
		= MonsterSetShoulderCollector.MostEfficientBoxSetPerKey(MonsterSetShoulderCollectorData.Urgarlag, 7)
	
	majOutput1 = MonsterSetShoulderCollector.printBoxData(MonsterSetShoulderCollector.mysteryCofferMaj, majMaxShouldersAmount, majCollectedShouldersAmount)
	glirionOutput1 = MonsterSetShoulderCollector.printBoxData(MonsterSetShoulderCollector.mysteryCofferGlirion, glirionMaxShouldersAmount, glirionCollectedShouldersAmount)
	urgarlagOutput1 = MonsterSetShoulderCollector.printBoxData(MonsterSetShoulderCollector.mysteryCofferUrgarlag, urgarlagMaxShouldersAmount, urgarlagCollectedShouldersAmount)
	
	majOutput2 = MonsterSetShoulderCollector.printMysteryBox5KeyData(MonsterSetShoulderCollector.mysteryCofferMaj, majMaxShouldersAmount, majCollectedShouldersAmount, 5, "keys", 5)
	glirionOutput2 = MonsterSetShoulderCollector.printMysteryBox5KeyData(MonsterSetShoulderCollector.mysteryCofferGlirion, glirionMaxShouldersAmount, glirionCollectedShouldersAmount, 5, "keys", 5)
	urgarlagOutput2 = MonsterSetShoulderCollector.printMysteryBox5KeyData(MonsterSetShoulderCollector.mysteryCofferUrgarlag, urgarlagMaxShouldersAmount, urgarlagCollectedShouldersAmount, 5, "keys", 5)
	
	LibChatMessage:SetTagPrefixMode(2)		--Enables LibChatMessge preffix
	
	chat:Print(MonsterSetShoulderCollector.dashedLines)
	
	LibChatMessage:SetTagPrefixMode(1)		--Disables LibChatMessge preffix

	chat:Print(majOutput1)
	chat:Print(majOutput2)
	chat:Print(glirionOutput1)
	chat:Print(glirionOutput2)
	chat:Print(urgarlagOutput1)
	chat:Print(urgarlagOutput2)
end

-- Accepts nothing
-- Prints all commands along with a description of each command
-- Returns nothing
function MonsterSetShoulderCollector.PrintHelpMessages()
	LibChatMessage:SetTagPrefixMode(2)		--Enables LibChatMessge preffix
	
	chat:Print(MonsterSetShoulderCollector.dashedLines)
	
	LibChatMessage:SetTagPrefixMode(1)		--Disables LibChatMessge preffix
	
	chat:Print("List of commands  available in Undaunted Shoulder Collector")
	chat:Print("/mssc :  Displays most efficient 5 key and 1 key purchases along with the chance of unlocking a new set piece from each of those boxes")
	chat:Print("/msscmystery :  Displays collected amounts for each mystery coffer and the chance of unlocking a new piece from each one")
	chat:Print("/msscmaj :  Displays collected amounts for each coffer available from Maj and the chance of unlocking a new piece from each one")
	chat:Print("/mscglirion :  Displays collected amounts for each coffer available from Glirion and the chance of unlocking a new piece from each one")
	chat:Print("/msscurgarlag :  Displays collected amounts for each coffer available from Urgarlag and the chance of unlocking a new piece from each one")
	chat:Print("/msscimperial :  Displays collected amounts for each coffer available from Imperial City and the chance of unlocking a new piece from each one")
	chat:Print("/msschelp :  Displays help message to chatbox listing available commands")
end


SLASH_COMMANDS["/mssc"] = function() MonsterSetShoulderCollector.CalculateMostEfficientKeyPurchases() end
SLASH_COMMANDS["/msscmystery"] = function() MonsterSetShoulderCollector.ShowAllMysteryCoffers() end
SLASH_COMMANDS["/msscmaj"] = function() MonsterSetShoulderCollector.ShowAllPledgeGiver(MonsterSetShoulderCollectorData.Maj, MonsterSetShoulderCollector.mysteryCofferMaj) end
SLASH_COMMANDS["/msscglirion"] = function() MonsterSetShoulderCollector.ShowAllPledgeGiver(MonsterSetShoulderCollectorData.Glirion, MonsterSetShoulderCollector.mysteryCofferGlirion) end
SLASH_COMMANDS["/msscurgarlag"] = function() MonsterSetShoulderCollector.ShowAllPledgeGiver(MonsterSetShoulderCollectorData.Urgarlag, MonsterSetShoulderCollector.mysteryCofferUrgarlag) end
SLASH_COMMANDS["/msscimperial"] = function() MonsterSetShoulderCollector.ShowImperialCity(MonsterSetShoulderCollectorData.ImperialCity, MonsterSetShoulderCollector.mysteryCofferImperialCity) end
SLASH_COMMANDS["/msschelp"] = function() MonsterSetShoulderCollector.PrintHelpMessages() end