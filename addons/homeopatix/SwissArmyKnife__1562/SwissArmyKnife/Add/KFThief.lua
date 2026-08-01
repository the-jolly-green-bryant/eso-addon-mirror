-- Thief Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function BountyCheck()

   local toPay = 0
   local heat, bountys, bountyGet, payoffReduce, payoffFull, infamymeter = GetInfoBounty()

   SAK.settings.totalNumberStolen, SAK.settings.totalValue = ItemStolenNumber()

    
   --d(SAK.stolenIcon .. " " .. SAK.settings.totalNumberStolen .. " " .. SAK.settings.totalValue .. " " .. SAK.GoldIcon)

   --d(string.format("H%s bo%s bog%s pr%s pf%s im%s", heat, bountys, bountyGet, payoffReduce, payoffFull, infamymeter))

   if(payoffReduce < payoffFull) then
	toPay = payoffReduce
   else
	toPay = payoffFull
   end

   if(bountys == 0) then
      	SAK.settings.bounty = 0
	SAK.settings.bounty_start = 0
	SAK.settings.bounty_timer = 0
	SAK.settings.bounty_display = 0
   else
      	SAK.settings.bounty_start = GetTimeStamp()
	--d("Your bounty is : ", toPay)
	SAK.settings.bounty = toPay
   end

   if(SAK.settings.bounty_start == 0) then return end

   local estimate = ((bountyGet / 10) * 180) - (GetTimeStamp() - SAK.settings.bounty_start)

   if(estimate > 0) then
      	local timestr =  fmt_time(estimate)
      	--d("Bounty will reset in ~", timestr)
	SAK.settings.bounty_timer = timestr
   end

    SAK.settings.TOTALSELL, SAK.settings.SELLUSED = GetFenceSellTransactionInfo()
    local totallaunder, launderused = GetFenceLaunderTransactionInfo()
    --d(string.format("%s %s %s %s", SAK.settings.totalsell, SAK.settings.sellused, totallaunder, launderused))
end

function fmt_time(t)
   local ss = t % 60
   local mm = (t % 3600) - ss
   local hh = (t % 86400) - mm
   local dd = t - hh

   mm = mm/60
   hh = hh/3600
   dd = dd/86400

   if(dd >= 1) then
      return string.format("%02dd %02dh", dd, hh)
   elseif(hh >= 1) then
      if(hh < 10) then
	return string.format("%01dh %02dm", hh, mm)
      else
	return string.format("%02dh %02dm", hh, mm)
      end
   else
      return string.format("%02dm %02ds", mm, ss)
   end
end

     

function GetInfoBounty()
        
        local heat, bounty = GetPlayerInfamyData()

        local bountyGet = GetBounty()
        local payoffReduce = GetReducedBountyPayoffAmount()
        local payoffFull = GetFullBountyPayoffAmount()
        local infamymeter = GetInfamyMeterSize()
        
	return heat, bounty, bountyGet, payoffReduce, payoffFull, infamymeter
end


function ItemStolenNumber()
	local bagsize = GetBagSize(BAG_BACKPACK)
	local slotIndex, numberStolen, totalNumberStolen, itemValue, totalValue = 0, 0, 0, 0, 0

	while (slotIndex <= bagsize) do
		if (IsItemStolen(BAG_BACKPACK, slotIndex)) == true then
			numberStolen = (GetSlotStackSize(BAG_BACKPACK, slotIndex))
			totalNumberStolen = totalNumberStolen + numberStolen
			
			    
        		local icon, stack, sellPrice = GetItemInfo(BAG_BACKPACK, slotIndex)

			if(sellPrice <= 1) then
				sellPrice = 0
			end

			
			--itemValue = GetItemSellValueWithBonuses(BAG_BACKPACK, slotIndex) * numberStolen
		 	totalValue = totalValue + (stack * sellPrice)
	 	end
	slotIndex = slotIndex + 1
	end

	return totalNumberStolen, totalValue
end

function DisplayBountyBar(NomCouper, bntyTmp, heat, RestToSold)
	if(SAK.settings.DISPLAY_THIEF == true) then
		if(SAK.settings.DISPLAY_WARNING == true) then
			SwissArmyKnifeContainerBackgroundLabel:SetText("!!! WANTED !!!")
			SwissArmyKnifeContainerBackgroundLabel2:SetText("")
		else
			SwissArmyKnifeContainerBackgroundLabel:SetText(NomCouper)
    			SwissArmyKnifeContainerBackgroundLabel2:SetText(NomCouper)
			SwissArmyKnifeContainerBackgroundLabel:SetColor(255, 255, 255, 255)
		end

		if(SAK.settings.DISPLAY_DAGGER == true) then
			if(bntyTmp > 330) then
			if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
				SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "3", SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
			else
				SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "3", SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
			end
		else
			if(bntyTmp > 160) then
				if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "2", SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				else
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "2", SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				end
			else
				if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "1", SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				else
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.daggerIconRed, "1", SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				end
			end
		end
		else
			if(bntyTmp > 330) then
			if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
				SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
			else
				SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
			end
		else
			if(bntyTmp > 160) then
				if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				else
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				end
			else
				if(heat > 0 and SAK.settings.DISPLAY_HEAT == true) then
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.heatIconWhite, bntyTmp, SAK.heatIcon, heat, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				else
					SwissArmyKnifeContainerBountyTimer:SetText(string.format("%s %s %s %s %s%s/%s %s%s", SAK.settings.bounty, SAK.GoldIcon, SAK.timerIcon, SAK.settings.bounty_timer, SAK.stolenIcon, SAK.settings.totalNumberStolen, RestToSold, SAK.settings.totalValue, SAK.GoldIcon))
				end
			end
		end
		end

		SwissArmyKnifeContainerBountyTimer:SetColor(255, 255, 255, 255)

		if(SAK.settings.DISPLAY_WARNING == true) then
			if(SAK.settings.bounty_display ~= 10) then
				SwissArmyKnifeContainerBackgroundLabel:SetColor(255, 0, 0, 255)
				SAK.settings.bounty_display = SAK.settings.bounty_display +1
			else
				SwissArmyKnifeContainerBackgroundLabel:SetColor(255, 0, 0, 0)
				SAK.settings.bounty_display = 0
			end
		end
	end
end
