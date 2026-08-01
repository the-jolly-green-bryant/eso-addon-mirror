function CalculateProfit(stuff)
	local options = mysplit(stuff, "%s")	
	local chat = LibChatMessage("ProfitCalculator")
	
	if (#options == 0 or options[1] == "help") then
		chat:Print("Usage: /profit buyPrice sellPrice count(optional)")
	else 
		local buyPrice = tonumber(options[1])
		local sellPrice = tonumber(options[2])
		
		local count = 1
		
		if (options[3] ~= nil) then
			count = tonumber(options[3])
		end
		
		if(count ~= 0) then
			local profit = ((sellPrice * 0.92) - buyPrice) * count
				
			chat:Printf("%sProfit: %s|r, BuyPrice: %s, SellPrice: %s, Count: %s", getProfitColor(profit), profit, buyPrice, sellPrice, count)
		else
			chat:Print("Can't get profit outta thin air...")
		end
		
	end
	
end

SLASH_COMMANDS["/profit"] = CalculateProfit

function mysplit (inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

function getProfitColor(profit)
	local profitColor = "|c00FF00"
	
	if(profit < 0) then
		profitColor = "|cFF0000"
	end
	if(profit == 0) then
		profitColor = "|cFFFF00"
	end
	
	return profitColor
end
