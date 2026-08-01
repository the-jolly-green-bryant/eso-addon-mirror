local GS = GetString
local cpcD = CarosPreCrafter.cpcD
local thisCharId = CarosPreCrafter.thisCharId
local allMyChars = CarosPreCrafter.allMyChars

-- CarosPreCrafter.isOnMainCrafter

local function makeItemLinkNotCrafted(itemLink)
	if not IsItemLinkCrafted(itemLink) then return itemLink end
	local startPos = string.find(itemLink, "[^:]+:[^:]+:[^:]+:[^:]+:[^:]+|h|h") 
	itemLink = string.format("%s0%s", string.sub(itemLink, 1, startPos-1), string.sub(itemLink, startPos + 1))
	return not IsItemLinkCrafted(itemLink) and itemLink or false
end
CarosPreCrafter.makeItemLinkNotCrafted = makeItemLinkNotCrafted

local function getRecipeFromLink(itemLink)
	for recipeListIndex=1, GetNumRecipeLists() do
		local _, numRecipes = GetRecipeListInfo(recipeListIndex)
		for recipeIndex=1, numRecipes do
			if GetItemLinkItemId(GetRecipeResultItemLink(recipeListIndex, recipeIndex)) == GetItemLinkItemId(itemLink) then 
				local known = GetRecipeInfo(recipeListIndex, recipeIndex)
				return recipeListIndex, recipeIndex, known
			end
		end
	end
end

CarosPreCrafter.getRecipeFromLink = getRecipeFromLink

local function getAlchemyReagents()
	local reagentSlots = {}
	local reagentsFound = {}
	if HasCraftBagAccess() then
		local slotIndex = GetNextVirtualBagSlotId()
		while slotIndex do
			if GetItemType(BAG_VIRTUAL, slotIndex) == ITEMTYPE_REAGENT then 
				table.insert(reagentSlots, {BAG_VIRTUAL, slotIndex})
				reagentsFound[slotIndex] = true
			end
			slotIndex = GetNextVirtualBagSlotId(slotIndex)
		end
	end
	local bagIds = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	for _, bagId in pairs(bagIds) do
		for slotIndex=0, GetBagSize(bagId) do
			if GetItemType(bagId, slotIndex) == ITEMTYPE_REAGENT then 
				local itemId = GetItemId(bagId, slotIndex)
				if not reagentsFound[itemId] then
					table.insert(reagentSlots, {bagId, slotIndex})
					reagentsFound[itemId] = true
				end
			end
		end
	end
	CarosPreCrafter.reagentSlots = reagentSlots
	return reagentSlots
end

local function getSolventFromLink(itemLink)
	local linkedItemType = GetItemLinkItemType(itemLink)
	local solventType = linkedItemType == ITEMTYPE_POISON and ITEMTYPE_POISON_BASE or linkedItemType == ITEMTYPE_POTION and ITEMTYPE_POTION_BASE or false
	if not solventType then return false end
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	if HasCraftBagAccess() then
		local slotIndex = GetNextVirtualBagSlotId()
		while slotIndex do
			local _, itemType, _, resLevel, resCP = GetItemCraftingInfo(BAG_VIRTUAL, slotIndex)
			if itemType == solventType and resLevel == reqLevel and resCP == reqCP then return BAG_VIRTUAL, slotIndex end
			slotIndex = GetNextVirtualBagSlotId(slotIndex)
		end
	end
	local bagIds = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	for _, bagId in pairs(bagIds) do
		for slotIndex=0, GetBagSize(bagId) do
			local _, itemType, _, resLevel, resCP = GetItemCraftingInfo(bagId, slotIndex)
			if itemType == solventType and resLevel == reqLevel and resCP == reqCP then return bagId, slotIndex end
		end
	end
end

local function getPossibleCombinationsFromLink(itemLink)
	itemLink = makeItemLinkNotCrafted(itemLink)
	if not itemLink then return false end
	local linkStyle = tonumber(string.match(itemLink, "|H(%d):"))
	local possibleCombinations = {}
	local solventBag, solventSlot = getSolventFromLink(itemLink)
	if not solventBag then return false end
	--d("Solvent: " .. solventBag .. " - " .. solventSlot)
	local reagentSlots = getAlchemyReagents()
	if #reagentSlots == 0 then return false end
	for i=1, #reagentSlots do
		local reagent1Bag, reagent1Slot = reagentSlots[i][1], reagentSlots[i][2]
		for j=i+1, #reagentSlots do
			local reagent2Bag, reagent2Slot = reagentSlots[j][1], reagentSlots[j][2]
			local resultingLink2 = GetAlchemyResultingItemLink(solventBag, solventSlot, reagent1Bag, reagent1Slot, reagent2Bag, reagent2Slot, nil, nil, linkStyle)
			if  resultingLink2 == itemLink then
				table.insert(possibleCombinations, 
							{solvent = {bagId = solventBag, slotIndex = solventSlot}, 
							reagent1 = {bagId = reagent1Bag, slotIndex = reagent1Slot}, 
							reagent2 = {bagId = reagent2Bag, slotIndex = reagent2Slot},
							reagent3 = {}})
			else
				for k=j+1, #reagentSlots do
					local reagent3Bag, reagent3Slot = reagentSlots[k][1], reagentSlots[k][2]
					local resultingLink = GetAlchemyResultingItemLink(solventBag, solventSlot, reagent1Bag, reagent1Slot, reagent2Bag, reagent2Slot, reagent3Bag, reagent3Slot, linkStyle)
					if  resultingLink == itemLink then
						table.insert(possibleCombinations, 
							{solvent = {bagId = solventBag, slotIndex = solventSlot}, 
							reagent1 = {bagId = reagent1Bag, slotIndex = reagent1Slot}, 
							reagent2 = {bagId = reagent2Bag, slotIndex = reagent2Slot}, 
							reagent3 = {bagId = reagent3Bag, slotIndex = reagent3Slot}})
					end
				end	
			end
		end
	end
	return #possibleCombinations > 0 and possibleCombinations or false
end

CarosPreCrafter.getPossibleCombinationsFromLink = getPossibleCombinationsFromLink

function CarosPreCrafter.getBestAlchemyCombination(itemLink)
	if not LibPrice then return false end
	local combinations = getPossibleCombinationsFromLink(itemLink)
	if not combinations then return false end
	local price = false
	local myCombination = false
	for i, combination in pairs(combinations) do
		local combiPrice = 0
		for j, ingredient in pairs(combination) do
			local ingPrice, ingPriceSource = LibPrice.ItemLinkToPriceGold(GetItemLink(ingredient.bagId, ingredient.slotIndex))
			if not ingPrice or ingPriceSource == "npc" then return false end
			combiPrice = combiPrice + ingPrice
		end
		if not price or combiPrice < price then 
			price = combiPrice
			myCombination = combination
		end
	end
	return myCombination
end

function CarosPreCrafter.getRecipeOrCombination(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	local recipe, combination = false, false
	if itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON then
		combination = getPossibleCombinationsFromLink(itemLink)
	elseif itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
		recipe = {getRecipeFromLink(itemLink)}
	end
	return recipe, combination
end


