RAS = RAS or {}
RAS.name = "RaidAutoSkeleton"
RAS.version = "1.3.1"

function RAS.onZoneChange(_, _)
	
	local zone, x, y, z = GetUnitWorldPosition("player")
	
	if RAS.savedVariables.zones[tostring(zone)] ~= nil and RAS.savedVariables.zones[tostring(zone)] == true then
		-- one of the given zones
		-- equip things from settings
		if RAS.savedVariables.changePoly == true then
			if RAS.savedVariables.polyId == 0 then
				-- unequip any polymorph if player has one
				local poly = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH)
				if poly ~= 0 then
					UseCollectible(poly)
				end
			elseif not IsCollectibleActive(RAS.savedVariables.polyId) then
				-- equip right polymorph
				UseCollectible(RAS.savedVariables.polyId)
			end
		end
		
		if RAS.savedVariables.changeOutfit == true then
			if RAS.savedVariables.outfitId == nil or RAS.savedVariables.outfitId == 0 then
				UnequipOutfit()
			else
				EquipOutfit(RAS.savedVariables.outfitId)
			end
		end
		
	else
	
		if RAS.savedVariables.zones[tostring(RAS.savedVariables.lastZone)] ~= nil then
			-- not one of the given zones but last zone was
			-- restore old things
			if RAS.savedVariables.changePoly == true then
				if RAS.savedVariables.lastPoly == 0 then
					-- unequip any polymorph if player has one
					local poly = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH)
					if poly ~= 0 then
						UseCollectible(poly)
					end
				elseif not IsCollectibleActive(RAS.savedVariables.lastPoly) then
					-- equip right polymorph
					UseCollectible(RAS.savedVariables.lastPoly)
				end
			end
			
			if RAS.savedVariables.changeOutfit == true then
				if RAS.savedVariables.lastOutfit == nil or RAS.savedVariables.lastOutfit == 0 then
					UnequipOutfit()
				else
					EquipOutfit(RAS.savedVariables.lastOutfit)
				end
			end
		else
			-- not one of the given zones and last was not one either
			-- remember things
			RAS.savedVariables.lastPoly = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH)
			RAS.savedVariables.lastOutfit = GetEquippedOutfitIndex()
		end
		
	end

	RAS.savedVariables.lastZone = zone
end

function RAS.OnAddOnLoaded(_, addonName)
	if addonName ~= RAS.name then return end
	
	RAS.initializeSettingsMenu()
	EVENT_MANAGER:RegisterForEvent(RAS.name, EVENT_PLAYER_ACTIVATED, RAS.onZoneChange)
end

EVENT_MANAGER:RegisterForEvent(RAS.name, EVENT_ADD_ON_LOADED, RAS.OnAddOnLoaded)