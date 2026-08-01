local MailerDemon = MailerDemon
local MD = MailerDemon
local craftData = {

	["Cloth"] = {

		["Weapons"] = 	{},
		["Armor"] = 	{ARMORTYPE_LIGHT,
						ARMORTYPE_MEDIUM, },
		["Material"] = 	{ITEMTYPE_CLOTHIER_MATERIAL,	},
		["Raw"] = 		{ITEMTYPE_CLOTHIER_RAW_MATERIAL, },
		["Booster"] = 	{ITEMTYPE_CLOTHIER_BOOSTER,	},
	},
	["Metal"] = {

		["Weapons"] = 	{WEAPONTYPE_AXE,
						WEAPONTYPE_DAGGER,
						WEAPONTYPE_SWORD,
						WEAPONTYPE_TWO_HANDED_AXE,
						WEAPONTYPE_TWO_HANDED_HAMMER,
						WEAPONTYPE_TWO_HANDED_SWORD,
						WEAPONTYPE_HAMMER, },
		["Armor"] = {	ARMORTYPE_HEAVY, },

		["Material"] = 	{ITEMTYPE_BLACKSMITHING_MATERIAL},
		["Raw"] = 		{ITEMTYPE_BLACKSMITHING_RAW_MATERIAL},
		["Booster"] = 	{ITEMTYPE_BLACKSMITHING_BOOSTER},

	},

	["Wood"] = {

		["Weapons"] = 	{WEAPONTYPE_BOW,
						WEAPONTYPE_LIGHTNING_STAFF,
						WEAPONTYPE_FIRE_STAFF,
						WEAPONTYPE_FROST_STAFF,
						WEAPONTYPE_HEALING_STAFF,
						WEAPONTYPE_SHIELD, },
		["Armor"] = 	{},

		["Material"] = 	{ITEMTYPE_WOODWORKING_MATERIAL},
		["Raw"] = 		{ITEMTYPE_WOODWORKING_RAW_MATERIAL},
		["Booster"] =	{ITEMTYPE_WOODWORKING_BOOSTER},
	},

	["Glyph"] = {

		["Weapons"] = 	{ITEMTYPE_GLYPH_JEWELRY,
						ITEMTYPE_GLYPH_WEAPON,},
		["Armor"] = 	{ITEMTYPE_GLYPH_ARMOR},

		["Material"] = {ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
						ITEMTYPE_ENCHANTING_RUNE_POTENCY,},

		["Raw"] = 		{ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
						ITEMTYPE_ENCHANTING_RUNE_POTENCY,},
		["Booster"] = 	{ITEMTYPE_ENCHANTMENT_BOOSTER,
						ITEMTYPE_ENCHANTING_RUNE_ASPECT,},

	},

	["Food"] = {
		["Weapons"] = 	{},
		["Armor"] = 	{},

		["Material"] = 	{ITEMTYPE_INGREDIENT,
						},
		["Raw"] = 		{},
		["Booster"] = 	{ITEMTYPE_RECIPE, },
	},

	["Alchemy"] = {

		["Weapons"] = 	{},
		["Armor"] = 	{},

		["Material"] = 	{ITEMTYPE_REAGENT,
						ITEMTYPE_ALCHEMY_BASE,},
		["Raw"] = 		{},
		["Booster"] = 	{},

	},

	["Bait"] = {

		["Weapons"] = 	{},
		["Armor"] = 	{},
		["Material"] = 	{ITEMTYPE_LURE,},
		["Raw"] = 		{},
		["Booster"] = 	{},
	},

	["Consumables"] = {
		["Food"] = 		{ITEMTYPE_DRINK,
						ITEMTYPE_FOOD,
						},
		["Alchemy"] = 	{ITEMTYPE_POTION,
						ITEMTYPE_POISON,
						},

	}

}


-- those are set in MD.CheckSendItem
local armorType = 0
local weaponType = 0
local itemType = 0
local itemLink = nil
local equipType = 0
local usedInCraftingType = -1
local currConfig = nil
local taskRunning = nil
local bagSlot = 0

function checkifQualityKeepsie()


	local minQuality = currConfig.MinQuality or 1
	local maxQuality = currConfig.MaxQuality or 1
	-- check if the itemType is within the config arrays
	-- if not, check if the equipType is within the config arrays
	local _, _, _, _, _, equipType, _, quality = GetItemInfo(BAG_BACKPACK, bagSlot)
	-- if not quality then quality = 5 end
	-- d('checking quality for ' .. GetItemLink(BAG_BACKPACK, bagSlot) .. ": minQuality: " .. minQuality .. ", maxQuality: " .. maxQuality .. "itemQuality: " .. quality .. ", result will be: " .. tostring((minQuality <= quality) and (maxQuality >= quality) ))
	return (not ((minQuality <= quality) and (maxQuality >= quality)))



end

function MD.IsOrnate()

	local itemTrait = GetItemTrait(BAG_BACKPACK, bagSlot)
	return (itemTrait == ITEM_TRAIT_TYPE_ARMOR_ORNATE)
		or (itemTrait ==  ITEM_TRAIT_TYPE_JEWELRY_ORNATE)
		or (itemTrait ==  ITEM_TRAIT_TYPE_WEAPON_ORNATE)
		or  (GetItemType(BAG_BACKPACK, bagSlot) == TEMTYPE_ALCHEMY_BASE) -- mark solvents as ornate, just to make sure
end

function MD.IsEndProduct()

	local ret = false

	if not (taskRunning == "Food" or
		taskRunning == "Bait")
	then


		--d("taskRunning: " .. taskRunning .. ", item: " .. itemLink .. " weapon: " .. tostring(weaponType) .. ", armour: " .. tostring(armorType) .. ", item: " .. tostring(itemType))

		if weaponType and tonumber(weaponType) > 0 then
			ret = MD.FindInList(weaponType,craftData[taskRunning]["Weapons"])
		elseif armorType and tonumber(armorType) > 0 then
			ret = MD.FindInList(armorType,craftData[taskRunning]["Armor"])
		end

		if taskRunning == "Glyph" then
			ret = MD.FindInList(itemType,craftData.Glyph.Armor) or MD.FindInList(itemType,craftData.Glyph.Weapon)
		end
	end

	--  d("checking on " .. taskRunning .. ": " .. itemLink .. ", itemType " .. itemType)
	return ret

end

function checkForJewellery()
	return (itemType == 2)
end

function checkForBouncie()

	local itemLink = GetItemLink(BAG_BACKPACK, bagSlot)
	local taskRunning = currConfig.Name
	local taskData =craftData[taskRunning]
	local ret, armorType, weaponType, itemType, rawMatch, matMatch, boostMatch = false

	-- yes, we don't need all these - unless we do, for debug purposes!

	armorType = GetItemArmorType(BAG_BACKPACK, bagSlot)
	weaponType = GetItemWeaponType(BAG_BACKPACK, bagSlot)
	itemType = GetItemType(BAG_BACKPACK, bagSlot)

	-- d("checking for bouncie: " .. itemLink .. ", aT: " .. tostring(armorType) .. ", wT: " .. tostring(weaponType) .. ", iT: " .. tostring(itemType))
	local ret = false

	-- checking for gear
	if currConfig.Send then

		ret = ret 	or ( 
						( armorType ~= 0 and weaponType ~= 0 and (
							(currConfig.SendBlacksmithing and MD.IsEndProduct(bagSlot, "Metal"))
							or (currConfig.SendClothing and MD.IsEndProduct(bagSlot, "Cloth"))
							or (currConfig.SendWoodworking and MD.IsEndProduct(bagSlot, "Wood")) 
						))
						or (currConfig.SendEnchanting and MD.IsEndProduct(bagSlot, "Glyph"))
					)
	end

	if currConfig.SendRaw then

		ret = ret 	or (armorType == 0 and weaponType == 0 and (
							(currConfig.SendBlacksmithing and MD.FindInList(itemType,craftData.Metal.Raw))
							or (currConfig.SendClothing and MD.FindInList(itemType,craftData.Cloth.Raw))
							or (currConfig.SendWoodworking and MD.FindInList(itemType,craftData.Wood.Raw))
							or (currConfig.SendEnchanting and MD.FindInList(itemType,craftData.Glyph.Raw))
							or (currConfig.SendAlchemy and MD.FindInList(itemType,craftData.Alchemy.Raw))
						)
					)
	end

	if currConfig.SendMaterials then

		ret = ret 	or armorType == 0 and weaponType == 0 and  ((currConfig.SendBlacksmithing and MD.FindInList(itemType,craftData.Metal.Material))
					or (currConfig.SendClothing and MD.FindInList(itemType,craftData.Cloth.Material))
					or (currConfig.SendWoodworking and MD.FindInList(itemType,craftData.Wood.Material))
					or (currConfig.SendEnchanting and MD.FindInList(itemType,craftData.Glyph.Material))
					or (currConfig.SendAlchemy and MD.FindInList(itemType,craftData.Alchemy.Material))
					or (currConfig.SendFood and MD.FindInList(itemType,craftData.Food.Material))
					or (currConfig.SendFood and currConfig.SendBoosters and MD.FindInList(itemType,craftData.Food.Booster)))

	end

	if currConfig.SendBoosters then

		ret = ret 	or ( armorType == 0 and weaponType == 0 and (
						(currConfig.SendBlacksmithing and MD.FindInList(itemType,craftData.Metal.Booster))
						or (currConfig.SendClothing and MD.FindInList(itemType,craftData.Cloth.Booster))
						or (currConfig.SendWoodworking and MD.FindInList(itemType,craftData.Wood.Booster))
						or (currConfig.SendEnchanting and MD.FindInList(itemType,craftData.Glyph.Booster))
						or (currConfig.SendAlchemy and MD.FindInList(itemType,craftData.Alchemy.Booster))
						or (currConfig.SendFood and MD.FindInList(itemType,craftData.Food.Booster)))
					)
	end

	if currConfig.SendConsumables then

		ret = ret 	or ( armorType == 0 and weaponType == 0 and ( 
						(currConfig.SendAlchemy and MD.FindInList(itemType,craftData.Consumables.Alchemy))
						or (currConfig.SendFood and MD.FindInList(itemType,craftData.Consumables.Food)))
					)
	end

	if currConfig.SendBait then
		ret = ret or (  armorType == 0 and weaponType == 0 and MD.FindInList(itemType,craftData.Bait.Material))
	end

	return ret

end

function checkIfMaxLevelKeepsie()

	if not currConfig.KeepMaxLevel then return false end
	
	local ret = (GetItemRequiredVeteranRank(BAG_BACKPACK, bagSlot) <= 16)

	local textureName, _, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, bagSlot)

	-- check for crafting materials
	if string.match(textureName, "crafting_woodworking_rough_ruby_ash") 		-- rough ruby ash
	or string.match(textureName, "crafting_wood_ruddy_ash") 					-- refined ruby ash
	or string.match(textureName, "crafting_light_armor_standard_f_005") 		-- raw ancestor silk
	or string.match(textureName, "crafting_cloth_base_harvestersilk")			-- ancestor silk
	or string.match(textureName, "crafting_jewelry_base_ruby_r1")				-- rubedite ore
	or string.match(textureName, "crafting_colossus_iron")						-- rubedite
	or string.match(textureName, "crafting_daedric_skin")						-- ruby leather scraps
	or string.match(textureName, "leather_ambergris")							-- ruby leather
	or string.match(textureName, "crafting_components_runestones_053")			--
	or string.match(textureName, "crafting_components_runestones_054")			--
	or string.match(textureName, "crafting_components_runestones_055")			--
	or string.match(textureName, "crafting_components_runestones_056")			--
	then ret = true end


	-- d(tostring(ret) .. " for " .. tostring(textureName))
	return ret

end

function checkForBait()
	
	local armorType, weaponType, itemType, itemLink = nil

	armorType = GetItemArmorType(BAG_BACKPACK, bagSlot)
	weaponType = GetItemWeaponType(BAG_BACKPACK, bagSlot)
	itemType = GetItemType(BAG_BACKPACK, bagSlot)
	
	-- d(GetItemLink(BAG_BACKPACK, bagSlot) .. ": AT/WT/IT " .. tostring(armorType) .. " / " .. tostring(weaponType)  .. " / " .. tostring(itemType) ) 

	return (armorType == 0) and (weaponType == 0) and MD.FindInList(itemType,craftData.Bait.Material)

end

function checkForRefineable()

	if (usedInCraftingType == 0) then return false end

	local ret = currConfig.SendBlacksmithing and MD.FindInList(itemType,craftData.Metal.Raw)
	ret = ret or (currConfig.SendClothing and MD.FindInList(itemType,craftData.Cloth.Raw))
	ret = ret or (currConfig.SendWoodworking and MD.FindInList(itemType,craftData.Wood.Raw))

	return ret
end

function checkForMaterial()
	
	if (usedInCraftingType == 0) then return false end

	local ret = false
	
	local dataList = craftData	
	
    	
	local isBlacksmithing, isClothing, isWoodworking, isEnchanting, isAlchemy, isFood = false
	
		
	if  currConfig.SendBlacksmithing then
		isBlacksmithing = MD.FindInList(itemType, dataList["Metal"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Metal"]["Booster"]))
	end
	if currConfig.SendClothing then
		isClothing = MD.FindInList(itemType,craftData["Cloth"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Cloth"]["Booster"]))
	end
	if  currConfig.SendWoodworking then
		isWoodworking = MD.FindInList(itemType,craftData["Wood"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Wood"]["Booster"]))
	end
	if currConfig.SendEnchanting then
		isEnchanting = MD.FindInList(itemType,craftData["Glyph"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Glyph"]["Booster"]))
	end
	if currConfig.SendAlchemy then
		isAlchemy = MD.FindInList(itemType,craftData["Alchemy"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Alchemy"]["Booster"]))
	end
	if currConfig.SendFood then
		isFood = MD.FindInList(itemType,craftData["Food"]["Material"])
		or (currConfig.SendBoosters and MD.FindInList(itemType,craftData["Food"]["Booster"]))
	end

		
	return (isBlacksmithing or isClothing or isWoodworking or isEnchanting or isAlchemy or isFood)
end

function checkForConsumable()

	if not IsItemUsable(BAG_BACKPACK, bagSlot)	then return false end
	local ret = 	(( currConfig.SendAlchemy and MD.FindInList(itemType,craftData.Consumables["Alchemy"]))
				or  ( currConfig.SendFood and MD.FindInList(itemType,craftData.Consumables["Food"])))

	return ret
end

function checkForDeconstructable()

	local ret = false

	if weaponType > 0 then

		-- we have a weapon! Will we deconstruct weapons?
		ret = ret or (currConfig.SendBlacksmithing and MD.FindInList(weaponType,craftData["Metal"]["Weapons"]))
		ret = ret or (currConfig.SendClothing and MD.FindInList(weaponType,craftData["Cloth"]["Weapons"]))
		ret = ret or (currConfig.SendWoodworking and MD.FindInList(weaponType,craftData["Wood"]["Weapons"]))
		
		-- d("item: " .. itemLink .. " weapon: " .. tostring(weaponType) ..", item: " .. tostring(itemType) .. ", ret: " .. tostring(ret))
		
	elseif armorType > 0 then

		-- we have armour! Will we deconstruct armour?
		ret = ret or (currConfig.SendBlacksmithing and MD.FindInList(armorType,craftData["Metal"]["Armor"]))
		ret = ret or (currConfig.SendClothing and MD.FindInList(armorType,craftData["Cloth"]["Armor"]))
		ret = ret or (currConfig.SendWoodworking and MD.FindInList(armorType,craftData["Wood"]["Armor"]))
		
	elseif ((itemType == ITEMTYPE_GLYPH_JEWELRY) or (itemType == ITEMTYPE_GLYPH_ARMOR) or (itemType == ITEMTYPE_GLYPH_WEAPON)) then -- A glyph?
		-- d("found glyph deconstructable: " .. itemLink)
		if currConfig.SendEnchanting then
			ret = ret
			or  MD.FindInList(itemType,craftData["Glyph"]["Weapons"])
			or  MD.FindInList(itemType,craftData["Glyph"]["Armor"])
		end
	end

	--  d(taskRunning .. ": " .. itemLink .. ", itemType " .. itemType)
	return ret

end

function MD.CheckSendItem(checkBagSlot, currentConfig, taskRunning)
	
	bagSlot = checkBagSlot
	currConfig = currentConfig
	
	itemType = GetItemType(BAG_BACKPACK, bagSlot)
	if itemType == 0 then return false end
	
	local ret = false

	if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
		armorType = GetItemArmorType(BAG_BACKPACK, bagSlot)
		weaponType = GetItemWeaponType(BAG_BACKPACK, bagSlot)
		usedInCraftingType = 0
	else
		armorType = 0
		weaponType = 0
		usedInCraftingType = GetItemCraftingInfo(BAG_BACKPACK, bagSlot)
	end
	itemLink = GetItemLink(BAG_BACKPACK, bagSlot)
	
	
	taskRunning = currConfig['Name']

	local ret = false

	
	
	-- d("checkSendItem called with " .. itemLink .. ", usedInCraftingType is: " .. tostring(usedInCraftingType))
	-- if not itemLink or ('' == itemLink) or MD.IsItemSaved(bagSlot) then return false end
	

	-- we don't want to send jewellery, really not.
	isJewellery 	= checkForJewellery(bagSlot, currConfig)
	
	local ret = (taskRunning:match("Bounce") and checkForBouncie())
	ret	= ret or (taskRunning:match("Ref") and usedInCraftingType ~= 0 and checkForRefineable())
	ret	= ret or (taskRunning:match("Material") and (not isRefineable) 	and checkForMaterial())
	ret	= ret or (taskRunning:match("Consumables") and not isMaterial and usedInCraftingType ~= 0 and checkForConsumable())
	ret	= ret or (taskRunning:match("Decon") and (not isConsumable) and checkForDeconstructable())
	ret	= ret or (taskRunning:match("Bait") and (not isDecon) and (armorType == 0 ) and (weaponType == 0) and checkForBait())
	
	if checkifQualityKeepsie() then return false end
	if checkIfMaxLevelKeepsie() then return false end
	
	return ret

end
