-- Locker Addon File
-- @author    : Homeo
-- @lastModif : 23/09/2017
	



function LockItem()
	local ctrlMO=WINDOW_MANAGER:GetMouseOverControl()

	if (not ctrlMO.dataEntry) or (not ctrlMO.dataEntry.data)  or (not ctrlMO.dataEntry.data.slotIndex) then
    		return  
  	end

  	local slotIndex = ctrlMO.dataEntry.data.slotIndex
	local bagId = ctrlMO.dataEntry.data.bagId 
  
  	if not (slotIndex and bagId) then 
      		return 
   	end   
    
	if CanItemBePlayerLocked(bagId,slotIndex) then 
    		if IsItemPlayerLocked(bagId,slotIndex) then
			SetItemIsPlayerLocked(bagId,slotIndex, false)
			if(SAK.settings.DISPLAY_LOCKED == true) then 
				d(string.format("%s %s",GetItemLink(bagId,slotIndex), SAK.lang.KF_JUNK_15))
			end
		else
			SetItemIsPlayerLocked(bagId,slotIndex, true)
			if(SAK.settings.DISPLAY_LOCKED == true) then 
				d(string.format("%s %s",GetItemLink(bagId,slotIndex), SAK.lang.KF_JUNK_14))
			end
		end
  	end         
end

