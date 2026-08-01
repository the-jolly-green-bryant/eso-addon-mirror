LazyThief = {}

LazyThief.name = "LazyThief"
LazyThief.version = "0.3.1"

LazyThief.typeNames = {
		weapon_1 = "Weapon",
		armor_2 = "Armor",
		treasure_56 = "Treasure",
		styleMaterial_44 = "Style material",
		food_4 = "Food",
		drink_12 = "Drink",
		recipe_29 = "Recipe",
		tool_9 = "Tool",
		ingredient_10 = "Ingredient",
		potionBase_33 = "Potion base",
		motif_8 = "Motif",
		furnishing_61 = "Furnishing",
		potion_7 = "Potion",
		container_18 = "Container",
		trophy_5 = "Trophy",
		rawMaterial_17 = "Raw material",
		lure_16 = "Lure",
		weaponTrait_46 = "Weapon trait",
		soulGem_19 = "Soul gem",
}

LazyThief.ordonnedKeys = {
		"treasure_56",
		"recipe_29",
		"motif_8",
		"tool_9",
		"styleMaterial_44",
		"weaponTrait_46",
		"lure_16",
		"ingredient_10",
		"potionBase_33",
		"food_4",
		"drink_12",
		"potion_7",
		"weapon_1",
		"armor_2",
		"furnishing_61",
		"rawMaterial_17",
		"soulGem_19",
		"container_18",
		"trophy_5",
}

LazyThief.itemTypeConvertor = {
		[1]  = "weapon_1",
		[2]  = "armor_2",
		[56] = "treasure_56",
		[44] = "styleMaterial_44",
		[4]  = "food_4",
		[12] = "drink_12",
		[29] = "recipe_29",
		[9]  = "tool_9",
		[10] = "ingredient_10",
		[33] = "potionBase_33",
		[8]  = "motif_8",
		[61] = "furnishing_61",
		[7]  = "potion_7",
		[18] = "container_18",
		[5]  = "trophy_5",
		[17] = "rawMaterial_17",
		[16] = "lure_16",
		[46] = "weaponTrait_46",
		[19] = "soulGem_19",
}

LazyThief.defaults = {
	 LCITemMinimumQuality= {
		weapon_1 = 1,
		armor_2 = 1,
		treasure_56 = 1,
		styleMaterial_44 = 1,
		food_4 = 1,
		drink_12 = 1,
		recipe_29 = 1,
		tool_9 = 1,
		ingredient_10 = 1,
		potionBase_33 = 1,
		motif_8 = 1,
		furnishing_61 = 1,
		potion_7 = 1,
		container_18 = 1,
		trophy_5 = 1,
		rawMaterial_17 = 1,
		lure_16 = 1,
		weaponTrait_46 = 1,
		soulGem_19 = 1,
	},
	LCItemLootAction = {
		weapon_1 = 1,
		armor_2 = 1,
		treasure_56 = 1,
		styleMaterial_44 = 1,
		food_4 = 1,
		drink_12 = 1,
		recipe_29 = 1,
		tool_9 = 1,
		ingredient_10 = 1,
		potionBase_33 = 1,
		motif_8 = 1,
		furnishing_61 = 1,
		potion_7 = 1,
		container_18 = 1,
		trophy_5 = 1,
		rawMaterial_17 = 1,
		lure_16 = 1,
		weaponTrait_46 = 1,
		soulGem_19 = 1,
	},
	LCItemFenceAction = {
		weapon_1 = 1,
		armor_2 = 1,
		treasure_56 = 1,
		styleMaterial_44 = 1,
		food_4 = 1,
		drink_12 = 1,
		recipe_29 = 1,
		tool_9 = 1,
		ingredient_10 = 1,
		potionBase_33 = 1,
		motif_8 = 1,
		furnishing_61 = 1,
		potion_7 = 1,
		container_18 = 1,
		trophy_5 = 1,
		rawMaterial_17 = 1,
		lure_16 = 1,
		weaponTrait_46 = 1,
		soulGem_19 = 1,
	},
	LCAutoClose = true,
}


function LazyThief:Initialize()
	LazyThief.SavedVariables = ZO_SavedVars:New("LazyThief_SavedVariables", 1.0, nil, LazyThief.defaults)
	self.inStealth = 0
	self.lootOpen = false
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_UPDATED, self.OnLootOpen)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, self.OnItemLoot)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_LOOT_CLOSED, self.OnLootClose)
	EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_FENCE, self.OnFenceOpen)

	EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
	callOptions()
end
 
function LazyThief.OnAddOnLoaded(event, addonName)
	if addonName == LazyThief.name then
		LazyThief:Initialize()
	end
end
 
EVENT_MANAGER:RegisterForEvent(LazyThief.name, EVENT_ADD_ON_LOADED, LazyThief.OnAddOnLoaded)

function LazyThief.OnPlayerStealthState(event, arg, inStealth)
	if inStealth ~= LazyThief.inStealth then
		LazyThief.inStealth = inStealth
		trySteal()
	end
end

function LazyThief.OnLootOpen(event)
	LazyThief.lootOpen = true
	trySteal()
end

function LazyThief.OnItemLoot(eventCode,bagId,slotId,isNewItem,itemSoundCategory,inventoryUpdateReason,stackCountChange)
	if bagId == 0 or not IsItemStolen(bagId, slotId) or IsItemJunk(bagId, slotId) or not isNewItem then
		return
	end

	local itemDefaultType = GetItemType(bagId, slotId)	
	
	local itemAllowed = isItemAllowed(itemDefaultType, GetItemLinkQuality(GetItemLink(bagId, slotId, 0)))

	if(itemAllowed <= 1 or itemAllowed == 4) then
		return
	elseif itemAllowed == 2 then
		DestroyItem(1, slotId)
	else
		SetItemIsJunk(1, slotId, true)
	end
end

function LazyThief.OnFenceOpen(eventCode,allowSell,allowLaunder)
	checkAllStolen()
end

function isItemAllowed(itemType, itemQuality)--return 0 itemIgnored, 1 take item, 2 remove item, 3 take item to junk, 4 unknown item
	for key,value in pairs(LazyThief.SavedVariables.LCITemMinimumQuality) do
		if LazyThief.itemTypeConvertor[itemType] == key then
			if(value <= itemQuality) then
				return 1
			else
				if LazyThief.SavedVariables.LCItemLootAction[key] == 2 then 
					return 2
				elseif LazyThief.SavedVariables.LCItemLootAction[key] == 3 then
					return 3
				else
					return 0
				end
			end
		end
	end
	d("LazyThief : It's embarassing, that item type is unknown, please send that\n "..
	"<<Item type : "..itemType..">>"..
	"\n to me (@sulexa) i will correct that in the next patch")
	return 4
end

function LazyThief.OnLootClose(event)
	LazyThief.lootOpen = false
end

function trySteal()
	if (LazyThief.inStealth == 3 or LazyThief.inStealth == 5) and LazyThief.lootOpen then
		getLootItems()
	end
end


function getLootItems()
	LootMoney() 
	local empty = false
	local index = 1
	while not empty do
		lootId, name, icon, count, quality, value, isQuest, stolen, itemType = GetLootItemInfo(index)
		if lootId == 0 then --si il n'y a plus d'item a check
			empty = true
		else
			if stolen then
				itemDefaultType = GetItemLinkItemType(GetLootItemLink(lootId, 0))
				
				local itemAllowed = isItemAllowed(itemDefaultType, quality)

				if(itemAllowed >= 1) then
					LootItemById(lootId)
				end
			end
			index = index+1
		end
	end
	if LazyThief.SavedVariables.LCAutoClose then
		EndLooting()
	end
end

function StringToQuality(String)
	if String == "Normal" then return 1
	elseif String == "Fine" then return 2
	elseif String == "Superior" then return 3
	elseif String == "Epic" then return 4
	elseif String == "Legendary" then return 5
	else return 6
	end
end

function QualityToString(Quality)
	if Quality == 1 then return "Normal"
	elseif Quality == 2 then return "Fine"
	elseif Quality == 3 then return "Superior"
	elseif Quality == 4 then return "Epic"
	elseif Quality == 5 then return "Legendary"
	else return "None"
	end
end

function StringToItemTreatment(String)
	if String == "Do not take" then return 1
	elseif String == "Remove" then return 2
	else return 3
	end
end

function ItemTreatmentToString(ItemTreatment)
	if ItemTreatment == 1 then return "Do not take"
	elseif ItemTreatment == 2 then return "Remove"
	else return "Mark as junk"
	end
end

function StringToFenceMode(String)
	if String == "Nothing" then return 1
	elseif String == "Launder" then return 2
	else return 3
	end
end

function FenceModeToString(FenceMode)
	if FenceMode == 1 then return "Nothing"
	elseif FenceMode == 2 then return "Launder"
	else return "Sell"
	end
end

function checkAllStolen()
    local bagSize = GetBagSize(1)
    for i = 0, bagSize do
        if(IsItemStolen(1,i) ) then
			checkTypeAction(i)
        end
    end
end

function checkTypeAction(slotIndex)
	local _, itemQuantity, _, _, _, _, _, itemQuality = GetItemInfo(1, slotIndex)
	local itemType = GetItemType(1, slotIndex)
	--local itemQuality = GetItemLinkQuality(GetItemLink(1,slotIndex,0))
	if(isItemAllowed(itemType, itemQuality)) then
		if LazyThief.SavedVariables.LCItemFenceAction[LazyThief.itemTypeConvertor[itemType]] == 2 then
			local totalLaunders, laundersUsed = GetFenceLaunderTransactionInfo()
			laundersLeft = totalLaunders-laundersUsed;
			if laundersLeft == 0 then
				return
			end
			if laundersLeft < itemQuantity then
				LaunderItem(1, slotIndex, laundersLeft)
			else
				LaunderItem(1, slotIndex, itemQuantity)
			end
		elseif LazyThief.SavedVariables.LCItemFenceAction[LazyThief.itemTypeConvertor[itemType]] == 3 then
			local  totalSells, sellsUsed = GetFenceSellTransactionInfo()
			sellsLeft = totalSells-sellsUsed;
			if sellsLeft == 0 then
				return
			end
			if sellsLeft < itemQuantity then
				SellInventoryItem(1, slotIndex, sellsLeft)
			else
				SellInventoryItem(1, slotIndex, itemQuantity)
			end
		end
	end
end





LazyThief.optionsTable = {}
LazyThief.optionSelected = "treasure_56"
LazyThief.tabStartIndex = 1

function setItemBlock()
	LazyThief.optionsTable[LazyThief.tabStartIndex] = {
							type = "header",
							width = "full",	--or "half" (optional)
						}
	LazyThief.optionsTable[LazyThief.tabStartIndex+1] = 	{
							type = "dropdown",
							tooltip = "Only item of this quality or superior will get pick",
							choices = {"Normal", "Fine", "Superior", "Epic", "Legendary", "None"},
							width = "half",	--or "half" (optional)
						}
	LazyThief.optionsTable[LazyThief.tabStartIndex+2] = 	{
							type = "dropdown",
							tooltip = "What to do with unwanted items",
							choices = {"Do not take", "Remove", "Mark as junk"},
							width = "half",	--or "half" (optional)
						}
	LazyThief.optionsTable[LazyThief.tabStartIndex+3] = 	{
							type = "dropdown",
							tooltip = "What to do at fence",
							choices = {"Nothing", "Launder", "Sell"},
							width = "half",	--or "half" (optional)
						}
	updateItemBlock(LazyThief.optionSelected);
end

function updateItemBlock(itemType)
	local index = 3
	for key,value in ipairs(LazyThief.ordonnedKeys) do
		LazyThief.optionsTable[index].isSelected = LazyThief.optionSelected == value
		index = index + 1
	end
	LazyThief.optionsTable[LazyThief.tabStartIndex].name = LazyThief.typeNames[itemType].." parameters"

	LazyThief.optionsTable[LazyThief.tabStartIndex+1].name = "Minimum item quality"
	LazyThief.optionsTable[LazyThief.tabStartIndex+1].getFunc = function() return QualityToString(LazyThief.SavedVariables.LCITemMinimumQuality[itemType]) end
	LazyThief.optionsTable[LazyThief.tabStartIndex+1].setFunc = function(var) LazyThief.SavedVariables.LCITemMinimumQuality[itemType] = StringToQuality(var) end

	LazyThief.optionsTable[LazyThief.tabStartIndex+2].name = "Item management"
	LazyThief.optionsTable[LazyThief.tabStartIndex+2].getFunc = function() return ItemTreatmentToString(LazyThief.SavedVariables.LCItemLootAction[itemType]) end
	LazyThief.optionsTable[LazyThief.tabStartIndex+2].setFunc = function(var) LazyThief.SavedVariables.LCItemLootAction[itemType] = StringToItemTreatment(var) end

	LazyThief.optionsTable[LazyThief.tabStartIndex+3].name = "AutoFence"
	LazyThief.optionsTable[LazyThief.tabStartIndex+3].getFunc = function() return FenceModeToString(LazyThief.SavedVariables.LCItemFenceAction[itemType]) end
	LazyThief.optionsTable[LazyThief.tabStartIndex+3].setFunc = function(var) LazyThief.SavedVariables.LCItemFenceAction[itemType] = StringToFenceMode(var) end
end

function changeSelected(itemType)
	LazyThief.optionSelected = itemType
	updateItemBlock(itemType)
end

function callOptions()
	local panelData = {
			type = "panel",
			name = "LazyThief",
			displayName = "LazyThief",
			author = "Sulexa",
			version = LazyThief.version,
			--slashCommand = "/LazyThief",	--(optional) will register a keybind to open to this panel
			registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
			registerForDefaults = true,	--boolean (optional) (will set all options controls back to default values)
	}

	LazyThief.optionsTable[1] = {
			type = "header",
			name = "LazyThief global parameters",
			width = "full",	--or "half" (optional)
	}
	LazyThief.optionsTable[2] = {
			type = "checkbox",
			name = "AutoClose containers",
			tooltip = "If checked the addon will close automatically containers with unwanted items",
			getFunc = function() return LazyThief.SavedVariables.LCAutoClose end,
			setFunc = function(value) LazyThief.SavedVariables.LCAutoClose = value end,
			width = "full",	--or "half" (optional)
	}


	local index = 3
	for key,value in ipairs(LazyThief.ordonnedKeys) do
		LazyThief.optionsTable[index] = 	{
							type = "LZTab",
							name = LazyThief.typeNames[value].." management",
							func = function() changeSelected(value) end,
							isSelected = LazyThief.optionSelected == value,
							width = "half",	--or "half" (optional)
						}
		index = index + 1
	end

	LazyThief.tabStartIndex = index;
	setItemBlock()

	local LAM = LibStub("LibAddonMenu-2.0")

	LAM:RegisterAddonPanel("LazyThiefAddon", panelData)
	LAM:RegisterOptionControls("LazyThiefAddon", LazyThief.optionsTable)
end
