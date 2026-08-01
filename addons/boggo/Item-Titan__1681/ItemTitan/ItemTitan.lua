



local function loadItemTitan(eventCode, addOnName)

    if(addOnName == "ItemTitan") then


        local defaults =
        {
            a_characters = {},
            inventory = {},
            sets = {}
        }

        local savedVars = ZO_SavedVars:NewAccountWide("ItemTitan", 1, nil, defaults)
        local characterId = GetCurrentCharacterId()

        if(savedVars.a_characters == nil) then
            savedVars.a_caracters = {}
        end

        if(savedVars.inventory[characterId] == nil) then
            savedVars.inventory[characterId] = {}
        end
        
        local function exportInventory(bagSpace)
            local backPackSize = GetBagSize(bagSpace)
            local inventory = {}
            local sets = {}
			if(savedVars.sets == nil) then
            	savedVars.sets = {}
       	 	end
       	 	sets = savedVars.sets;
			
            for i=0, backPackSize+1, 1 do

                local itemName = GetItemName(bagSpace, i)
                if string.len(itemName) >= 1 then
                    local uniqueId = GetItemUniqueId(bagSpace, i)
                    local itemTrait = GetItemTrait(bagSpace, i)
                    local itemStatValue = GetItemStatValue(bagSpace, i)
                    local itemArmorType = GetItemArmorType(bagSpace, i)
                    local itemType = {GetItemType(bagSpace, i)}
                    local weaponType = GetItemWeaponType(bagSpace, i)
                    local itemLink = GetItemLink(bagSpace, i)
                    local itemInfo =  {GetItemInfo(bagSpace, i) }
                    local itemPlayerLocked = IsItemPlayerLocked(bagSpace, i)
                    local quality = GetItemLinkQuality(itemLink)
                    local setInfo =  {GetItemLinkSetInfo(itemLink, true) }
                    local enchantInfo = {GetItemLinkEnchantInfo(itemLink) }
                    local championPoints = GetItemRequiredChampionPoints(bagSpace, i)
                    local itemLevel = GetItemRequiredLevel(bagSpace, i)
                    local itemBound = IsItemBound(bagSpace, i)
					
					if string.len(setInfo[2]) >= 1 then
						local item = {
							itemName, -- Name
							itemTrait, -- Trait
							itemInfo[6], -- EquipType
							setInfo[2], -- SetName
							quality, -- Quality
							itemArmorType, -- Heavy/Medium/Light armor
							tostring(itemPlayerLocked), -- Locked?
							itemType[1], -- Itemtype /armor/jewelry/weapon etc
							championPoints, -- cp needed
							itemLevel, -- level neeeded
							weaponType, -- Weapontype axe/dagger/bow etc
							tostring(itemBound),
							"unused",
							itemStatValue,
							enchantInfo[2],
							"END"
						}
	
						inventory['BAG-' .. i] = "ITEM:"..table.concat(item, ';')
						
						if sets[setInfo[2]] == nil then
							local setBonus_1 =  {GetItemLinkSetBonusInfo(itemLink, true, 1) }
                    		local setBonus_2 =  {GetItemLinkSetBonusInfo(itemLink, true, 2) }
                    		local setBonus_3 =  {GetItemLinkSetBonusInfo(itemLink, true, 3) }
                    		local setBonus_4 =  {GetItemLinkSetBonusInfo(itemLink, true, 4) }
                    		local setBonus_5 =  {GetItemLinkSetBonusInfo(itemLink, true, 5) }
                    		local setBonus_6 =  {GetItemLinkSetBonusInfo(itemLink, true, 6) }
							local set = {
								setInfo[2],
								setBonus_1[2],
								setBonus_2[2],
								setBonus_3[2],
								setBonus_4[2],
								setBonus_5[2],
								setBonus_6[2],
								"END"
							}
							sets[setInfo[2]] = "SET:"..table.concat(set, ';')
						end
					end

                end
            end

            if(bagSpace == BAG_BANK) then
                savedVars.inventory['bank'] = {}
                savedVars.inventory['bank'] = inventory
            else
                savedVars.inventory[characterId][bagSpace] = inventory
            end
    	
    		savedVars.sets = sets
        end

        local function exportCharacter()
            if(savedVars.a_characters == nil) then
                savedVars.a_characters = {}
            end

            local name = GetUnitName('player')
           
            local characterDump = {
                characterId,
                name
            }

            savedVars.a_characters[characterId] = 'CHARACTER:'..table.concat(characterDump, ';')..';'
        end
        
        local function startExport()
            exportCharacter()
            exportInventory(BAG_BACKPACK)
            exportInventory(BAG_WORN)
            exportInventory(BAG_BANK)
        end

        EVENT_MANAGER:RegisterForEvent("ItemTitanStartExportLogout", EVENT_LOGOUT_DEFERRED, startExport)
		startExport()
		
    end
end

EVENT_MANAGER:RegisterForEvent("ItemTitanLoaded", EVENT_ADD_ON_LOADED, loadItemTitan)








