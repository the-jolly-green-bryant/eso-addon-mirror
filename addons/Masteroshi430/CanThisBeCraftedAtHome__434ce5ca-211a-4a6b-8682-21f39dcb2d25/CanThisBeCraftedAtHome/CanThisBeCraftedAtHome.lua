CanThisBeCraftedAtHome = {}
CanThisBeCraftedAtHome.name = "CanThisBeCraftedAtHome"
CanThisBeCraftedAtHome.savedVars = ZO_SavedVars:NewAccountWide("CanThisBeCraftedAtHome_Save",1)

function CanThisBeCraftedAtHome.go(craftSkill) 
    if not IsPlayerActivated() then return end
	
    local houseId =  GetCurrentZoneHouseId() 
	local houseZoneId =  GetZoneId(GetCurrentMapZoneIndex())
	local zoneId = GetHouseFoundInZoneId(houseId)
	local zoneName = GetZoneNameById(zoneId)
	local collectibleId = GetCollectibleIdForHouse(houseId)
	local collectibleName = GetCollectibleName(collectibleId)
	local collectibleNickname = GetCollectibleNickname(collectibleId)
	local owner = GetCurrentHouseOwner()

	
	CanThisBeCraftedAtHome.savedVars.dataTable = CanThisBeCraftedAtHome.savedVars.dataTable or {}
	
	for i = 1, GetNumConsolidatedSmithingSets() do
	    local itemSetId = GetConsolidatedSmithingItemSetIdByIndex(i)
		local unlocked = IsConsolidatedSmithingItemSetIdUnlocked(itemSetId)
		if unlocked then
		   CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill] = CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill] or {}
		   CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId] = CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId] or {}
           local table = {
		                   globalZoneId = zoneId,
						   zoneName = zoneName,
						   houseZoneId = houseZoneId,
		                   houseId = houseId,
						   houseName = collectibleName,
						   houseNickname = collectibleNickname,
						   owner = owner,
		                 }
			CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId][owner..houseId] = CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId][owner..houseId] or {}	
			CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId][owner..houseId] = table

			--d(itemSetId.." can be crafted at "..owner.."'s "..collectibleName.." in "..zoneName)
		end
	end

end

function CanThisBeCraftedAtHome.askForSetId(itemSetId, craftSkill)

    CanThisBeCraftedAtHome.savedVars = ZO_SavedVars:NewAccountWide("CanThisBeCraftedAtHome_Save",1)
	
    if not CanThisBeCraftedAtHome.savedVars.dataTable then
	    return
	end
    
	if not CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill] or not CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId] then
	    return false
	end
	
	if NonContiguousCount(CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId]) == 0 then
	    return false
	end
	
	local answerTable = {}
	
	for k,v in pairs(CanThisBeCraftedAtHome.savedVars.dataTable[craftSkill][itemSetId]) do
		answerTable[k] = v
	end
     
	return true, answerTable 
end


EVENT_MANAGER:RegisterForEvent("test", EVENT_CRAFTING_STATION_INTERACT , function(_, craftSkill, sameStation, craftMode) 
	if craftMode == CRAFTING_INTERACTION_MODE_CONSOLIDATED_STATION then
	   CanThisBeCraftedAtHome.go(craftSkill)
	end
end) 
