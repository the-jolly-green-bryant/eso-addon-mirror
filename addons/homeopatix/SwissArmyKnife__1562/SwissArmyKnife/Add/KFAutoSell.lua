-- AutoSell Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017


function AutoJunkSell()
	if HasAnyJunk(BAG_BACKPACK, true) then	
		local itemPrice, stackTotal = CostJunk()
		SellAllJunk()
		d(string.format("%s %s pour %s %s", stackTotal, SAK.lang.KF_JUNK_1, itemPrice, SAK.GoldIcon))
	end
end


function SetJunk()
	local slotIndex = 0
	local bagsize = GetBagSize(BAG_BACKPACK)

	while (slotIndex <= bagsize) do
		local itemQuality = GetItemQuality(BAG_BACKPACK, slotIndex)
		
		if(itemQuality == 0) then
			SetItemIsJunk(BAG_BACKPACK, slotIndex, true)	
		end
		slotIndex = slotIndex + 1
	end
end

function CostJunk()
	itemJunk = 0
	slotIndex = 0
	stackTotal = 0
	itemPrice = 0
	local bagsize = GetBagSize(BAG_BACKPACK)

	while (slotIndex <= bagsize) do 
		local _, stack, sellPrice = GetItemInfo(BAG_BACKPACK, slotIndex)
		
		if (IsItemJunk(BAG_BACKPACK, slotIndex)) == true then
			itemJunk = itemJunk + 1
			itemPrice = itemPrice + (sellPrice * stack)
			stackTotal = stackTotal + stack
		end
		slotIndex = slotIndex + 1
	end
	return itemPrice, stackTotal, itemJunk
end

function JunkItem() 
		local ctrlMO=WINDOW_MANAGER:GetMouseOverControl()

		if (not ctrlMO.dataEntry) or (not ctrlMO.dataEntry.data)  or (not ctrlMO.dataEntry.data.slotIndex) then
    			return  
  		end

  		local slotIndex = ctrlMO.dataEntry.data.slotIndex
		local bagId = ctrlMO.dataEntry.data.bagId 
  
  	if not (slotIndex and bagId) then 
      		return 
    	end       
  
  	if CanItemBeMarkedAsJunk(bagId,slotIndex) then 
    		if(IsItemJunk(bagId,slotIndex)) then
			if(SAK.settings.DISPLAY_JUNKED == true) then
				d(string.format("%s %s",GetItemLink(bagId,slotIndex), SAK.lang.KF_JUNK_12))
			end
			SetItemIsJunk(bagId,slotIndex,false)
		else
			if(SAK.settings.DISPLAY_JUNKED == true) then
				d(string.format("%s %s",GetItemLink(bagId,slotIndex), SAK.lang.KF_JUNK_13))
			end
			SetItemIsJunk(bagId,slotIndex,true)
		end
  	end         
end
