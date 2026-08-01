CarosPreCrafter = {
	name = "CarosPreCrafter",
	allMyChars = {},
	mayPrecraftResearchItems = false,
	isOnMainCrafter = false,
	thisCharId = GetCurrentCharacterId(),
	hasCraftedWritItemsToDeposit = false,
	researchDeposit = {},
	researchRetrieve = {},
}

local CPC = CarosPreCrafter
local GS = GetString
local allMyChars = CarosPreCrafter.allMyChars
local carosAlchemyQueue
local carosProvisioningQueue
local strIL = "|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local craftedLink = "|H1:item:%s:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"
local craftedLink1 = "|H1:item:%s:3:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:0|h|h"
local warnAlchemy = false
local warnProvision = false

local wm = WINDOW_MANAGER
local cpcDebug = false

local alchemyStringMaxLevel = "|H1:item:%s:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:%s|h|h"
local alchemyStringLevel1 = "|H1:item:%s:30:3:0:0:0:0:0:0:0:0:0:0:0:0:36:1:0:0:0:%s|h|h"

local craftsToPreCraftResearch = {
	[CRAFTING_TYPE_BLACKSMITHING] = true,
	[CRAFTING_TYPE_CLOTHIER] = true,
	[CRAFTING_TYPE_WOODWORKING] = true,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = true,
}
CarosPreCrafter.craftsToPreCraftResearch = craftsToPreCraftResearch

local potionOptions = { -- all the ingredient options (besides the solvent). the keys are the resulting item ids.
	[54340] = { -- essence of magicka 
		{30158, 30160},	{30158, 30164},	{30158, 150670}, {30158, 150671},
		{30160, 30161}, {30160, 150670}, {30160, 150671}, {30161, 30164},
		{30161, 150671}, {30164, 150670}, {30164, 150671}, {150670, 150671},},
	[54341] = { -- essence of stamina
		{ 30157, 30163}, { 30157, 30164}, { 30157, 150669}, { 30157, 150731},
		{ 30162, 30163}, { 30162, 30164}, { 30162, 150669}, { 30162, 150731},
		{ 30163, 150669}, { 30163, 150731}, { 30164, 150669}, { 30164, 150731},
		{ 150669, 150731},},
	[54339] = { -- Health
		{30148, 30155}, {30148, 30163}, {30148, 30164}, {30148, 30166},
		{30148, 77585}, {30155, 30160}, {30155, 30164}, {30155, 30166},
		{30155, 77585}, {30160, 30163}, {30160, 30164}, {30160, 30166},
		{30160, 77585}, {30163, 30164}, {30163, 30166}, {30163, 77585},
		{30164, 30166}, {30164, 77585}, {30166, 77585},},
	[44812] = {-- Essence of health savage
		{30149, 30151}, {30149, 30152}, {30149, 30157}, {30149, 30161},
		{30149, 30165}, {30149, 77590}, {30149, 150670}, {30151, 30152},
		{30151, 30157}, {30151, 30161}, {30151, 30165}, {30151, 77590},
		{30151, 150670}, {30152, 30157}, {30152, 30161}, {30152, 30165},
		{30152, 77590}, {30152, 150670}, {30157, 30161}, {30157, 30165},
		{30157, 77590}, {30157, 150670}, {30161, 30165}, {30161, 77590},
		{30161, 150670}, {30165, 77590}, {30165, 150670}, {77590, 150670},},
	[44809] = {-- Stamina savage (only level1)
		{30155, 77587},	{30151, 77587},	{30151, 30155},	{30149, 30155},
		{30149, 77587}, {30149, 30156}, {30156, 77587}, {30151, 30156},
		{30155, 30156},},

}

local poisonOptions = {
	[76829] = { -- poison magicka 
		{30148, 30151}, {30148, 30152}, {30148, 30154}, {30148, 77589},
		{30148, 150669}, {30151, 30154}, {30151, 77589}, {30151, 150669},
		{30152, 30154}, {30152, 77589}, {30152, 150669}, {30154, 77589},
		{30154, 150669}, {77589, 150669},},
	[76831] = { -- Poison stamina
		{30149, 30155}, {30149, 30156}, {30149, 77587}, {30151, 30155},
		{30151, 30156}, {30151, 77587}, {30155, 30156}, {30155, 77587},
		{30156, 77587},},
	[76827] = {-- poison health  
		{30149, 30151}, {30149, 30152}, {30149, 30157}, {30149, 30161},
		{30149, 30165}, {30149, 77590}, {30149, 150670}, {30151, 30152},
		{30151, 30157}, {30151, 30161}, {30151, 30165}, {30151, 77590},
		{30151, 150670}, {30152, 30157}, {30152, 30161}, {30152, 30165},
		{30152, 77590}, {30152, 150670}, {30157, 30161}, {30157, 30165},
		{30157, 77590}, {30157, 150670}, {30161, 30165}, {30161, 77590},
		{30161, 150670}, {30165, 77590}, {30165, 150670}, {77590, 150670},},
	[76826] = { -- poison health drain
		{30148, 30155}, {30148, 30163}, {30148, 30164}, {30148, 30166},
		{30148, 77585}, {30155, 30160}, {30155, 30164}, {30155, 30166},
		{30155, 77585}, {30160, 30163}, {30160, 30164}, {30160, 30166},
		{30160, 77585}, {30163, 30164}, {30163, 30166}, {30163, 77585},
		{30164, 30166}, {30164, 77585}, {30166, 77585}},
}

local alchemyAlternatives = { -- Different itemlinks that all work for the daily writs
	[44812] = {132608, 134400, 131840, 137472, 132096, 133888, 131072}, -- health savage
	--[44815] = {262144, 265216,}, -- magicka savage (if ever needed)
	[54339] = {66304,65536,66816,}, -- health
	[76827] = {131072,132608,134400,131840,137472,132096,133888,}, --poison helath
	[76829] = {262144,265216,}, -- poison magicka
	[76831] = {393216,396800,}, -- poison stamina
	[76826] = {65536,66816,}, -- poison health drain
	[54340] = {196608}, -- magicka
	[54341] = {327680}, -- stamina
	[44809] = {393216, 396800}, --savage stamina (level 1)
}

--local potWritsLevMax = {54341,44812, 54340, 54339} --not needed
--local potWritLev1 = {54341, 54340, 54339, 44809}

local writPotion = { -- maxlevel. the values will be replaced by the choosen alternative combinations
	[54341] = {64501, 30162, 30163},  -- Essence of Stamina
	--[44809] = {64501, 77587, 30155}, -- Essence of Stamina savage 
	[44812] = {64501, 30157, 30165}, -- Essence of health savage
	[54340] = {64501, 30164, 30158}, -- Magicka
	--[44815] = {64501, 30148, 30151}, -- Magicka savage
	[54339] = {64501, 30163, 30166}, -- Health
}

local writPotion1 = { -- level 1 base 
	[54341] = {883, 30162, 30163},  -- Stamina
	[44809] = {883, 77587, 30155}, -- Stamina savage 
	[54340] = {883, 30164, 30158}, -- Magicka
	[54339] = {883, 30163, 30166}, -- Health
}
local writPoison = {
	[76831] = {75365, 30155, 77587}, -- Poison stamina
	[76827] = {75365, 30151, 30157}, -- poison health  
	[76829] = {75365, 30148, 30154}, -- poison magicka 
	[76826] = {75365, 30163, 30148}, -- poison health drain
}
local nonCraftedLink = "|H1:item:%s:309:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local nonCraftedLink1 = "|H1:item:%s:3:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"

-- Firsthold Fruit and Cheese Plate & Muthsera's Remorse
-- Hearty Garlic Corn Chowder & Markarth Mead
-- Lilmoth Garlic Hagfish & Hagraven's Tonic

local writFood = {
	[68236] = 68192, -- Firsthold Fruit and Cheese Plate 68192
	[68239] = 68195, -- Hearty Garlic Corn Chowder 68195
	[68257] = 68213, -- Markarth Mead 68213
	[68260] = 68216, -- Muthsera's Remorse 68216
	[68235] = 68191, -- Lilmoth Garlic Hagfish 68191
	[68263] = 68219, -- Hagraven's Tonic "68219
}

local writFoodLev1AD = {
	[28354] = {45912, 1}, -- Baked Potato	
	[33600] = {45980, 1}, -- Red Rye Beer
	[28281] = {45913, 1}, -- Banana Surprise	
	[33612] = {45982, 10}, -- Four-Eye Grog
	--[28358] = 45911, -- ROAST PIG 	
	[33819] = {45935, 1}, -- Chicken Breast	
	[33606] = {45981, 5}, -- Mazte
}

local writFoodLev1DC = {
	[33837] = {45889, 1}, -- Baked Apples 
	[33945] = {45990, 10}, -- Lemon Flower Mazte
	[28321] = {45887, 1}, -- Carrot Soup 	
	[33933] = {45988, 1}, -- Golden Lager
	[33526] = {45888, 1}, -- Fishy Stick 		
	[33939] = {45989, 5}, -- Surilie Syrah Wine
}

local writFoodLev1EP = {
	[33819] = {45935, 1}, -- Chicken Breast	
	[28405] = {45971, 5}, -- Bog-Iron Ale
	[33825] = {45936, 1}, -- Grape Preserves	 
	[28409] = {45972, 10} , -- Clarified Syrah Wine
	[33813] = {45934, 1}, -- Roast Corn	
	[28401] = {45970, 1}, -- Nut Brown Ale
}

function CarosPreCrafter.getAlchProvTables()
	return potionOptions, poisonOptions, alchemyAlternatives, writPotion, writPotion1, writPoison, writFood, writFoodLev1AD, writFoodLev1DC, writFoodLev1EP
end

function CarosPreCrafter.getItemLinkStrings()
	return strIL, craftedLink, craftedLink1, alchemyStringMaxLevel, alchemyStringLevel1, nonCraftedLink, nonCraftedLink1
end

local function ingredientsToChat()
	local potionOrder = {54340, 54341, 54339, 44812}
	local poisonOrder = {76829, 76831, 76827, 76826}
	for _, i in pairs(potionOrder) do
		local v = writPotion[i]
		d(string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])..": "..string.format(strIL, v[2]).." + "..string.format(strIL, v[3]))
	end
	local v = writPotion1[44809]
	d(string.format(alchemyStringLevel1, 44809, alchemyAlternatives[44809][1])..": "..string.format(strIL, v[2]).." + "..string.format(strIL, v[3]))
	for _, i in pairs(poisonOrder) do
		local v = writPoison[i]
		d(string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])..": "..string.format(strIL, v[2]).." + "..string.format(strIL, v[3]))
	end
end

local function cpcD(myText, myLevel)
	if not cpcDebug then return end
	if not myLevel or myLevel <= cpcDebug then d(myText) end
end

CarosPreCrafter.cpcD = cpcD

function CarosPreCrafter.debug(arg)
	if cpcDebug and not arg or arg == 0 then 
		cpcDebug = false
	elseif not arg then
		cpcDebug = 1
	else
		cpcDebug = arg
	end
	d("Debug mode:")
	d(cpcDebug)
end

local function refreshCustomPoisons() 
	if not CarosPreCrafter.sV.poisOptions then return end
	for i, v in pairs(CarosPreCrafter.sV.poisOptions) do
		if v ~= 0 then
			writPoison[i] = {75365, v[1], v[2]}
		end
	end
end

local function refreshCustomPotions()
	if not CarosPreCrafter.sV.potOptions then return end
	for i, v in pairs(CarosPreCrafter.sV.potOptions) do
		if v ~= 0 then
			if writPotion[i] then writPotion[i] = {64501, v[1], v[2]} end
			if writPotion1[i] then writPotion1[i] = {883, v[1], v[2]} end
		end		
	end
end

function CarosPreCrafter.test1()
	for i,v in pairs(potionOptions) do
		local theLink = string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])
		d("All the combinations for "..theLink..":")
		for j, w in pairs(v) do
			local myRes = GetAlchemyResultingItemLink(5, 64501, 5, w[1], 5, w[2])
			d(myRes)
		end
	end
	for i,v in pairs(poisonOptions) do
		local theLink = string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])
		d("All the combinations for "..theLink..":")
		for j, w in pairs(v) do
			local myRes = GetAlchemyResultingItemLink(5, 75365, 5, w[1], 5, w[2])
			d(myRes)
		end
	end
end

function CarosPreCrafter.test2()
	d("All the max-level food:")
	for i,v in pairs(writFood) do
		d(string.format(craftedLink, i).." - "..string.format(strIL, v)) -- i = food, v = recipe
	end
	d("All the level-1 food for AD")	
	for i,v in pairs(writFoodLev1AD) do
		d(string.format(craftedLink1, i, v[2]).." - "..string.format(strIL, v[1]))
	end
	d("All the level-1 food for DC")	
	for i,v in pairs(writFoodLev1DC) do
		d(string.format(craftedLink1, i, v[2]).." - "..string.format(strIL, v[1]))
	end
	d("All the level-1 food for EP")	
	for i,v in pairs(writFoodLev1EP) do
		d(string.format(craftedLink1, i, v[2]).." - "..string.format(strIL, v[1]))
	end
end

function CarosPreCrafter.test3()
	d("Potions:")
	for i,v in pairs(writPotion) do
		d(GetAlchemyResultingItemLink(5, v[1], 5, v[2], 5, v[3]))
	end
	d("Potions level 1:")
	for i,v in pairs(writPotion1) do
		d(GetAlchemyResultingItemLink(5, v[1], 5, v[2], 5, v[3]))
	end
	d("Poisons:")
	for i,v in pairs(writPoison) do
		d(GetAlchemyResultingItemLink(5, v[1], 5, v[2], 5, v[3]))
	end	
end

function CarosPreCrafter.test42() 
	for i,v in pairs(potionOptions) do
		local theLink = string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])
		d(theLink..":")
		for j, w in pairs(v) do
			local myRes = GetAlchemyResultingItemLink(5, 64501, 5, w[1], 5, w[2])
			if zo_strformat("<<C:1>>", GetItemLinkName(myRes)) ~= zo_strformat("<<C:1>>", GetItemLinkName(theLink)) then
				d(" - Problem: "..myRes.." = "..string.format(strIL, w[1]).." + "..string.format(strIL, w[2]))
			end
		end
	end
	for i,v in pairs(poisonOptions) do
		local theLink = string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])
		d(theLink..":")
		for j, w in pairs(v) do
			local myRes = GetAlchemyResultingItemLink(5, 75365, 5, w[1], 5, w[2])
			if zo_strformat("<<C:1>>", GetItemLinkName(myRes)) ~= zo_strformat("<<C:1>>", GetItemLinkName(theLink)) then
				d(" - Problem: "..myRes.." = "..string.format(strIL, w[1]).." + "..string.format(strIL, w[2]))
			end
		end
	end
end


local function getTotalCount(myLink)
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(myLink)
	return bagCount + bankCount + craftBagCount
end

CarosPreCrafter.getTotalCount = getTotalCount

local function caroCheckPreCrafting()
	-- Checks precrafting state for writ items
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterPlayerReady", EVENT_PLAYER_ACTIVATED)
	warnAlchemy = false
	warnProvision = false
	if CarosPreCrafter.sV.desiredPot > 0 then
		for i, v in pairs( writPotion) do
			local myCount = 0
			for j, w in pairs(alchemyAlternatives[i]) do
				local myLink = string.format(alchemyStringMaxLevel, i, w)
				myCount = myCount + getTotalCount(myLink)
			end
			if myCount < 8 then warnAlchemy = true break end
		end
	end
	if not warnAlchemy and CarosPreCrafter.sV.desiredPot1 > 0 then	
		for i, v in pairs( writPotion1) do
			local myCount = 0
			for j, w in pairs(alchemyAlternatives[i]) do
				local myLink = string.format(alchemyStringLevel1, i, w)
				myCount = myCount + getTotalCount(myLink)
			end
			if myCount < 8 then warnAlchemy = true break end
		end
	end
	if not warnAlchemy and CarosPreCrafter.sV.desiredPois > 0 then 
		for i, v in pairs( writPoison) do
			local myCount = 0
			for j, w in pairs(alchemyAlternatives[i]) do
				local myLink = string.format(alchemyStringMaxLevel, i, w)
				myCount = myCount + getTotalCount(myLink)
			end
			if myCount < 8 then warnAlchemy = true break end
		end
	end
	
	if CarosPreCrafter.sV.desiredProv > 0 then
		for i, v in pairs( writFood) do
			if getTotalCount(string.format(craftedLink, i)) < 8 then warnProvision = true break end
		end
	end
	if not warnProvision and CarosPreCrafter.sV.desiredProv1ad > 0 then
		for i, v in pairs( writFoodLev1AD) do
			if getTotalCount(string.format(craftedLink1, i, v[2])) < 8 then warnProvision = true break end
		end
	end
	if not warnProvision and CarosPreCrafter.sV.desiredProv1dc > 0 then
		for i, v in pairs( writFoodLev1DC) do
			if getTotalCount(string.format(craftedLink1, i, v[2])) < 8 then warnProvision = true break end
		end
	end
	if not warnProvision and CarosPreCrafter.sV.desiredProv1ep > 0 then
		for i, v in pairs( writFoodLev1EP) do
			if getTotalCount(string.format(craftedLink1, i, v[2])) < 8 then warnProvision = true break end
		end
	end
	
	
	local myMessage = {}
	local myIcon = ""
	if warnAlchemy then 
		table.insert(myMessage, GS(CPC_WarnAlchemy))
		myIcon = "esoui/art/crafting/alchemy_tabicon_solvent_down.dds"
	end
	if warnProvision then 
		table.insert(myMessage, GS(CPC_WarnProv)) 
		myIcon = "esoui/art/crafting/provisioner_indexicon_meat_down.dds"
	end
	if #myMessage > 0 then
		myMessage = table.concat(myMessage, "\n")
		if warnAlchemy and warnProvision then myIcon = "esoui/art/crafting/formulae_tabicon_down.dds" end
		CENTER_SCREEN_ANNOUNCE:AddMessage(0, CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED, "|c9e0911Caro|r`s Pre Crafter:", myMessage, myIcon, "esoui/art/crafting/crafting_alchemy_badslot.dds", nil, nil, 5000)
		d(myMessage)
	end
end

local function stopInteraction()
	carosAlchemyQueue = {}
	carosProvisioningQueue = {}
	ALCHEMY_SCENE:RemoveFragment(CarosPreCrafter.fragment)
	PROVISIONER_SCENE:RemoveFragment(CarosPreCrafter.fragment)
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterCompleted", EVENT_CRAFT_COMPLETED)
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterEndInteract", EVENT_END_CRAFTING_STATION_INTERACT)
end

local function caroItemFinder(itemID)
	-- Checking the craftbag first
	if GetItemId(BAG_VIRTUAL, itemID) ~=0 then return {bagId = BAG_VIRTUAL, slotIndex = itemID} end
	
	-- Then iterating over inventory and bank
	local myBags = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	for j, v in pairs(myBags) do
		for i=0, GetBagSize(v) do
			if GetItemId(v,i)==itemID then return {bagId = v, slotIndex = i} end
		end
	end

	return {bagId = nil, slotIndex = itemID}
end

local function nextAlchemy()
	if GetCraftingInteractionType() ~= CRAFTING_TYPE_ALCHEMY then stopInteraction() return end
	table.remove(carosAlchemyQueue, 1)
	if #carosAlchemyQueue == 0 then stopInteraction() return end
	if CarosPreCrafter.window and CarosPreCrafter.window.btn1.refreshTT then
		CarosPreCrafter.window.btn1.refreshTT()
	end
	local nextItem = carosAlchemyQueue[1]
	local myCount = nextItem.count

	local myCombination = {}
	
	if nextItem.custom then
		myCombination = CarosPreCrafter.getBestAlchemyCombination(nextItem.link)
		if not myCombination then
			d(string.format(GS(CPC_CustomNoCombi), nextItem.link))
			nextAlchemy()
			return
		end
	else
		local ingredients = {nextItem.solvent, nextItem.reagent1, nextItem.reagent2}
		for _, ingredient in pairs(ingredients) do
			local ingCount = getTotalCount(string.format(strIL, ingredient))
			if ingCount == 0 then
				d(string.format(GS(CPC_MissingMatsMovingOn), string.format(strIL, ingredient), nextItem.link))
				nextAlchemy()
				return
			end
			if ingCount < myCount then myCount = ingCount end
		end
		myCombination.solvent = caroItemFinder(nextItem.solvent)
		myCombination.reagent1 = caroItemFinder(nextItem.reagent1)
		myCombination.reagent2 = caroItemFinder(nextItem.reagent2)
		myCombination.reagent3 = {}
	end
	
	local myCountDoable = myCount
	local ingLinks = {}
	for key, ingredient in pairs(myCombination) do
		if ingredient.bagId and ingredient.slotIndex then
			local ingSlotCount =  GetSlotStackSize(ingredient.bagId, ingredient.slotIndex)
			if key == "solvent" then 
				table.insert(ingLinks, 1, GetItemLink(ingredient.bagId, ingredient.slotIndex))
			else
				table.insert(ingLinks, GetItemLink(ingredient.bagId, ingredient.slotIndex))
			end
			if ingSlotCount < myCountDoable then myCountDoable = ingSlotCount end
		end
	end
	if myCountDoable < myCount then
		table.insert(carosAlchemyQueue, 2, {solvent = nextItem.solvent, reagent1 = nextItem.reagent1, reagent2 = nextItem.reagent2, custom = nextItem.custom, count = myCount - myCountDoable, link = nextItem.link})
		myCount = myCountDoable
	end
	
	if nextItem.custom then d(string.format(GS(CPC_CustomCraftCombi), myCount, nextItem.link, table.concat(ingLinks, " + "))) end
	
	CarosPreCrafter.hasCraftedWritItemsToDeposit = true 
	CraftAlchemyItem(myCombination.solvent.bagId, myCombination.solvent.slotIndex, 
		myCombination.reagent1.bagId, myCombination.reagent1.slotIndex, 
		myCombination.reagent2.bagId, myCombination.reagent2.slotIndex,
		myCombination.reagent3.bagId, myCombination.reagent3.slotIndex, 
		myCount)
end

local function nextProvisioning()
	if GetCraftingInteractionType() ~= CRAFTING_TYPE_PROVISIONING then stopInteraction() return end
	table.remove(carosProvisioningQueue, 1)
	if #carosProvisioningQueue == 0 then 
		stopInteraction() 
		return 
	end
	if CarosPreCrafter.window and CarosPreCrafter.window.btn1.refreshTT then
		CarosPreCrafter.window.btn1.refreshTT()
	end
	local nextItem = carosProvisioningQueue[1]
	local myCount = nextItem.count
	local recipeLink = nextItem.recipeLink
	local resultLink = nextItem.link
	
	local ingredients = {}
	
	if nextItem.custom then
		local recipeListIndex, recipeIndex, known = CarosPreCrafter.getRecipeFromLink(nextItem.link)
		nextItem.recipeListIndex = recipeListIndex
		nextItem.recipeIndex = recipeIndex
		if known then
			local _, _, numIngredients = GetRecipeInfo(recipeListIndex, recipeIndex)
			for ingredientIndex=1, numIngredients do
				local _, _, requiredQuantity = GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex)
				local ingredientLink = GetRecipeIngredientItemLink(recipeListIndex, recipeIndex, ingredientIndex)
				local ingCount = getTotalCount(ingredientLink)
				if ingredientLink and ingredientLink ~= "" then 
					table.insert(ingredients, {requiredQuantity = requiredQuantity, count = ingCount, link = ingredientLink})
				end
			end
		else
			d(string.format(GS(CPC_Custom_RecipeUnknown), nextItem.link))
		end
	else
		for i=1, 2 do
			local _, ingCount, ingReq = GetItemLinkRecipeIngredientInfo(recipeLink, i)
			local ingLink = GetItemLinkRecipeIngredientItemLink(recipeLink, i, 1) 
			table.insert(ingredients, {requiredQuantity = ingReq, count = ingCount, link = ingLink})
		end
	end
	
	local countDoable = myCount
	local missingIngredients = {}
	for _, ingredient in pairs(ingredients) do
		if ingredient.requiredQuantity * countDoable < ingredient.count then
			if ingredient.count < ingredient.requiredQuantity then table.insert(missingIngredients, ingredient.link) end
			countDoable = math.floor(ingredient.count / ingredient.requiredQuantity)
		end
	end
	
	if countDoable < myCount then 
		d(GS(CPC_RecipeNotEnoughIngredients), myCount, nextItem.link, countDoable)
		myCount = countDoable 
	end
	
	if myCount == 0 then
		if #missingIngredients > 0 then
			d(string.format(GS(CPC_MissingMatsMovingOn), ZO_GenerateCommaSeparatedList(missingIngredients), resultLink))
		end
		nextProvisioning()
	else
		CarosPreCrafter.hasCraftedWritItemsToDeposit = true
		CraftProvisionerItem(nextItem.recipeListIndex, nextItem.recipeIndex, myCount)
	end
end

local function buildAlchemyItemLinks(noBrackets)
	local myAlchemyString, myAlchemyString1 = alchemyStringMaxLevel, alchemyStringLevel1
	if noBrackets then
		myAlchemyString = string.gsub(myAlchemyString, "|H1", "|H0")
		myAlchemyString1 = string.gsub(myAlchemyString1, "|H1", "|H0")
	end
	local booleanLinks, potionLinks, poisonLinks, potion1Links = {}, {}, {}, {}
	for i, v in pairs( writPotion) do
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(myAlchemyString, i, w)
			table.insert(potionLinks, myLink)
			booleanLinks[myLink]= true
		end
	end
	for i, v in pairs(writPotion1) do
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(myAlchemyString1, i, w)
			table.insert(potion1Links, myLink)
			booleanLinks[myLink]= true
		end
	end
	for i, v in pairs( writPoison) do
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(myAlchemyString, i, w)
			table.insert(poisonLinks, myLink)
			booleanLinks[myLink]= true
		end
	end
	return booleanLinks, potionLinks, poisonLinks, potion1Links
end

local function buildAlchemyQueue()
	carosAlchemyQueue = {"nil"}
	CarosPreCrafter.alchemyQueue = carosAlchemyQueue
	local myQueueText = {}
	for i, v in pairs(writPotion) do
		local thisLink = false
		local myCount = 0
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(alchemyStringMaxLevel, i, w)
			thisLink = thisLink or myLink
			myCount = myCount + getTotalCount(myLink)
		end
		
		local missingCount = CarosPreCrafter.sV.desiredPot - myCount
		if missingCount > 3 then
			table.insert(myQueueText, missingCount.."x "..string.format(craftedLink, i).." ("..string.format(strIL, v[2]).." + "..string.format(strIL, v[3])..")")
			table.insert(carosAlchemyQueue, {solvent = v[1], reagent1= v[2], reagent2 = v[3], custom = false, count = math.floor(missingCount/4), link = thisLink})
		end
	end
	for i, v in pairs(writPotion1) do
		local thisLink = false
		local myCount = 0
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(alchemyStringLevel1, i, w)
			thisLink = thisLink or myLink
			myCount = myCount + getTotalCount(myLink)
		end
		
		local missingCount = CarosPreCrafter.sV.desiredPot1 - myCount
		if missingCount > 3 then
			table.insert(myQueueText, missingCount.."x "..string.format(craftedLink1, i, 3).." ("..string.format(strIL, v[2]).." + "..string.format(strIL, v[3])..")")
			table.insert(carosAlchemyQueue, {solvent = v[1], reagent1 = v[2], reagent2 = v[3], custom = false, count = math.floor(missingCount/4), link = thisLink})
		end
	end
	for i, v in pairs( writPoison) do
		local thisLink = false
		local myCount = 0
		for j, w in pairs(alchemyAlternatives[i]) do
			local myLink = string.format(alchemyStringMaxLevel, i, w)
			thisLink = thisLink or myLink
			myCount = myCount + getTotalCount(myLink)
		end
		
		local missingCount = CarosPreCrafter.sV.desiredPois - myCount
		if missingCount > 15 then
			table.insert(myQueueText, missingCount.."x "..string.format(craftedLink, i).." ("..string.format(strIL, v[2]).." + "..string.format(strIL, v[3])..")")
			table.insert(carosAlchemyQueue, {solvent = v[1], reagent1 = v[2], reagent2 = v[3], count = math.floor(missingCount/16), link = thisLink})
		end
	end
	
	for itemLink, desCount in pairs(CarosPreCrafter.sV.customItems) do
		local itemType = GetItemLinkItemType(itemLink)
		if itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION then
			local missingCount = desCount - getTotalCount(itemLink)
			if itemType == ITEMTYPE_POTION and missingCount > 3 then
				table.insert(myQueueText, missingCount.."x "..itemLink)
				table.insert(carosAlchemyQueue, {custom = true, count = math.floor(missingCount/4), link = itemLink})
			elseif itemType == ITEMTYPE_POISON and missingCount > 15 then
				table.insert(myQueueText, missingCount.."x "..itemLink)
				table.insert(carosAlchemyQueue, {custom = true, count = math.floor(missingCount/16), link = itemLink})
			end
		end
	end
	return myQueueText
end

local function checkPassives(myFunc, myPassives)
	local thePassives = {}
	for i, v in pairs(myPassives) do
		local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(v)
		local passiveName, passiveIcon, _, _, _, purchased, _, rank = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)         
		if not purchased or GetNumPassiveSkillRanks( skillType, skillLineIndex, skillIndex) > rank then
			table.insert(thePassives, {name = passiveName, icon = passiveIcon})
		end
	end
	if #thePassives > 0 then
		local myText = {}
		for i, v in pairs(thePassives) do
			table.insert(myText, zo_strformat(GS(CPC_Ask_CraftingPassive), v.icon, v.name))
		end
		
		table.insert(myText, GS(CPC_Ask_CraftingAnyway))
		
		ESO_Dialogs["CPCCraftConfirmDiag"] = {
			canQueue = true,
			uniqueIdentifier = "CPCCraftConfirmDiag",
			title = {text = "|c9e0911Caro's Pre-Crafter|r"},
			mainText = {text = table.concat(myText, "\n")},
			buttons = {
				[1] = {
					text = SI_DIALOG_YES,
					callback = function() myFunc(true) end,
				},
				[2] = {
					text = SI_DIALOG_NO,
					callback = function() end,
				},
			},
			setup = function() end,
		}
		ZO_Dialogs_ShowDialog("CPCCraftConfirmDiag")
	else
		myFunc(true)
	end
end

local function preCraftAlchemy(ignorePassives)
	
	if not ignorePassives then checkPassives(preCraftAlchemy, {45579}) return end
	
	local myQueueText = buildAlchemyQueue()
	
	if #myQueueText > 0 then
		d(GS(CPC_AutoCrafting))
		for i, v in pairs( myQueueText) do
			d(v)
		end
	end
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterCompleted", EVENT_CRAFT_COMPLETED)
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterEndInteract", EVENT_END_CRAFTING_STATION_INTERACT)
	if #carosAlchemyQueue == 1 then return end
	EVENT_MANAGER:RegisterForEvent("CarosPreCrafterCompleted", EVENT_CRAFT_COMPLETED, nextAlchemy)
	EVENT_MANAGER:RegisterForEvent("CarosPreCrafterEndInteract", EVENT_END_CRAFTING_STATION_INTERACT, nextAlchemy)
	nextAlchemy()
end

local function buildWritFoodLinks(noBracketsAndInverse)
	local foodOtherLinks = {}
	local myOtherLink = nonCraftedLink
	local myOtherLink1 = nonCraftedLink1
	if noBracketsAndInverse then
		myOtherLink = string.gsub(craftedLink, "|H1", "|H0")
		myOtherLink1 = string.gsub(craftedLink1, "|H1", "|H0")
	end
	for i, v in pairs(writFood) do
		foodOtherLinks[i] = string.format(myOtherLink, i)
	end
	for j, w in pairs({writFoodLev1AD, writFoodLev1DC, writFoodLev1EP}) do
		for i, v in pairs(w) do
			foodOtherLinks[i] = string.format(myOtherLink1, i, v[2])
		end
	end
	if not noBracketsAndInverse then
		return foodOtherLinks
	else
		local foodBooleans = {} 
		for i, v in pairs(foodOtherLinks) do
			foodBooleans[v] = true
		end
		return foodBooleans
	end
end

local function buildProvisioningQueue()
	local foodOtherLinks = buildWritFoodLinks()
	-- extra function because also used in LAM
	local foodList = {}
	
	for j=1, GetNumRecipeLists() do
		local _, numRep = GetRecipeListInfo(j)
		for k=1, numRep do
			for i, v in pairs(foodOtherLinks) do
				if GetRecipeResultItemLink(j, k, 1) == v then 
					foodList[i] = {j, k}
					break
				end
			end
		end
	end
	
	carosProvisioningQueue = {"nil"}
	local myQueueText = {}
	local noRecipeText = {}
	local writTables = {
		[writFood] = CarosPreCrafter.sV.desiredProv,
		[writFoodLev1AD] = CarosPreCrafter.sV.desiredProv1ad,
		[writFoodLev1EP] = CarosPreCrafter.sV.desiredProv1ep,
		[writFoodLev1DC] = CarosPreCrafter.sV.desiredProv1dc,
	}
	for writList, desiredAmount in pairs(writTables) do
		for itemId, v in pairs( writList) do
			local recipeId = type(v) == "table" and v[1] or v
			local resultLink = foodOtherLinks[itemId]
			local missingCount = desiredAmount - getTotalCount(resultLink)
			if missingCount > 3 then
				
				if foodList[itemId] then 
					table.insert(myQueueText, missingCount.."x "..resultLink)
					table.insert(carosProvisioningQueue, {
						recipeListIndex = foodList[itemId][1], recipeIndex = foodList[itemId][2], 
						count = math.floor(missingCount/4), recipeLink = string.format(strIL, recipeId), 
						link = resultLink})
				else
					table.insert(noRecipeText, missingCount.."x "..resultLink)
				end
			end
		end
	end
		
	for itemLink, desCount in pairs(CarosPreCrafter.sV.customItems) do
		local itemType = GetItemLinkItemType(itemLink)
		if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
			local missingCount = desCount - getTotalCount(itemLink)
			if missingCount > 3 then
				table.insert(myQueueText, missingCount.."x "..itemLink)
				table.insert(carosProvisioningQueue, {custom = true, count = math.floor(missingCount/4), link = itemLink})
			end
		end
	end
	
	return myQueueText,  noRecipeText
end

local function preCraftProvisioning(ignorePassives)
	
	if not ignorePassives then checkPassives(preCraftProvisioning, {44616, 44620}) return end

	local myQueueText,  noRecipeText = buildProvisioningQueue()
	
	if #myQueueText > 0 then
		d(GS(CPC_AutoCrafting))
		for i, v in pairs( myQueueText) do
			d(v)
		end
	end
	
	if #noRecipeText > 0 then
		d(GS(CPC_RecipesNotFound))
		for i, v in pairs( noRecipeText) do
			d(v)
		end
	end
	
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterCompleted", EVENT_CRAFT_COMPLETED)
	EVENT_MANAGER:UnregisterForEvent("CarosPreCrafterEndInteract", EVENT_END_CRAFTING_STATION_INTERACT)
	if #carosProvisioningQueue == 1 then return end	
	EVENT_MANAGER:RegisterForEvent("CarosPreCrafterCompleted", EVENT_CRAFT_COMPLETED, nextProvisioning)
	EVENT_MANAGER:RegisterForEvent("CarosPreCrafterEndInteract", EVENT_END_CRAFTING_STATION_INTERACT, nextProvisioning)
	nextProvisioning()
end


function CarosPreCrafter.preCraftQueque()
	local craft = GetCraftingInteractionType()
	if craft == CRAFTING_TYPE_ALCHEMY then 
		preCraftAlchemy()
	elseif craft == CRAFTING_TYPE_PROVISIONING then
		preCraftProvisioning()
	elseif craftsToPreCraftResearch[craft] then   
		if CarosPreCrafter.isOnMainCrafter then
			CarosPreCrafter.startResearchCrafting(craft)
		else
			CarosPreCrafter.startResearching(craft)
		end
	elseif GetInteractionType() == INTERACTION_BANK then
		if CarosPreCrafter.isOnMainCrafter then CarosPreCrafter.checkResearchItemsOnMainCrafter() end
		CarosPreCrafter.depositWritItems()
	else
		d(GS(CPC_NoFittingStation))
	end
end

local function autoSelectingredients()
	if not LibPrice then d(GS(CPC_NoLibPrice)) return end
	local npAlerts = {}
	local function checkPrices(v)
		local myCombination = false
		local myPrice = false
		for j, w in pairs(v) do
			local link1 = string.format(strIL, w[1])
			local link2 = string.format(strIL, w[2])
			local price1, price1Source = LibPrice.ItemLinkToPriceGold(link1)
			local price2, price2Source = LibPrice.ItemLinkToPriceGold(link2)
			
			if price1 and price2 and price1Source ~= "npc" and price2Source ~= "npc"then 
				if not myPrice or myPrice > price1 + price2 then
					myPrice = price1 + price2
					myCombination = w
				end
			else
				if (not price1 or price1Source == "npc") and not npAlerts[w[1]] then
					d(string.format(GS(CPC_NoPriceMovingOn), link1))
				end
				if (not price2 or price2Source == "npc") and not npAlerts[w[2]] then
					d(string.format(GS(CPC_NoPriceMovingOn), link2))
				end
			end
		end
		return myPrice, myCombination
	end
	CarosPreCrafter.sV.potOptions = CarosPreCrafter.sV.potOptions or {}
	CarosPreCrafter.sV.poisOptions = CarosPreCrafter.sV.poisOptions or {}
	for i, v in pairs(potionOptions) do
		local myPrice, myCombination = checkPrices(v)
		if myPrice and myCombination then
			d(string.format(GS(CPC_UsingXandY), string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1]), string.format(strIL, myCombination[1]), string.format(strIL, myCombination[2]), math.floor(myPrice+0.5)))
			CarosPreCrafter.sV.potOptions[i] = myCombination
		end
	end	
	for i, v in pairs(poisonOptions) do 
		local myPrice, myCombination = checkPrices(v)
		if myPrice and myCombination then
			d(string.format(GS(CPC_UsingXandY), string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1]), string.format(strIL, myCombination[1]), string.format(strIL, myCombination[2]), math.floor(myPrice+0.5)))
			CarosPreCrafter.sV.poisOptions[i] = myCombination
		end
	end
	refreshCustomPoisons()
	refreshCustomPotions()
end

local function setBtnIcons(control, iconPath)
	control:SetNormalTexture(string.format("%s_up.dds", iconPath))
	control:SetPressedTexture(string.format("%s_down.dds", iconPath))
	control:SetMouseOverTexture(string.format("%s_over.dds", iconPath))
	control:SetDisabledTexture(string.format("%s_disabled.dds", iconPath))
end

function CarosPreCrafter.OnBankBtn1Click()
	CarosPreCrafter.retrieveResearchItems()
end

function CarosPreCrafter.OnBankBtn2Click()
	CarosPreCrafter.depositWritItems()
end

function CarosPreCrafter.saveButton1Pos(x, y)
	local craft = GetCraftingInteractionType()
	if craft == CRAFTING_TYPE_ALCHEMY then
		CarosPreCrafter.sV.windowLeftAlch = x
		CarosPreCrafter.sV.windowTopAlch = y
	elseif craft == CRAFTING_TYPE_PROVISIONING then
		CarosPreCrafter.sV.windowLeftProv = x
		CarosPreCrafter.sV.windowTopProv = y
	else
		CarosPreCrafter.sV.windowLeft = x
		CarosPreCrafter.sV.windowTop = y
	end
end

function CarosPreCrafter.showButton()

	local window = CarosPreCrafter.window
	local fragment = CarosPreCrafter.fragment
	local window2 = CarosPreCrafter.window2
	local fragment2 = CarosPreCrafter.fragment2
	
	if CarosPreCrafter.sV.showBtnAlchProv or CarosPreCrafter.sV.showBtnSmithing then
		if not window then
			window = wm:GetControlByName("CPC_BTNWIN1")
			setBtnIcons(window.btn1, "esoui/art/crafting/smithing_tabicon_creation")
			setBtnIcons(window.btn2, "esoui/art/crafting/smithing_tabicon_research")
			
			fragment = ZO_FadeSceneFragment:New(window) -- , nil, 0)
			
			CarosPreCrafter.fragment = fragment
			CarosPreCrafter.window = window
			
			--textureFile="esoui/art/crafting/smithing_tabicon_creation"
			--textureFile="esoui/art/crafting/smithing_tabicon_research"
			--textureFile="esoui/art/crafting/enchantment_tabicon_deconstruction"
		end
		if CarosPreCrafter.sV.showBtnAlchProv then 
			ALCHEMY_SCENE:AddFragment(CarosPreCrafter.fragment)
			PROVISIONER_SCENE:AddFragment(CarosPreCrafter.fragment)
		end
		if CarosPreCrafter.sV.showBtnSmithing and CarosPreCrafter.mayPrecraftResearchItems then
			SMITHING_SCENE:AddFragment(CarosPreCrafter.fragment)
		end
	else
		if window then
			SMITHING_SCENE:RemoveFragment(CarosPreCrafter.fragment)
			ALCHEMY_SCENE:RemoveFragment(CarosPreCrafter.fragment)
			PROVISIONER_SCENE:RemoveFragment(CarosPreCrafter.fragment)
		end
	end
	if CarosPreCrafter.sV.showBtnBank then
		if not window2 then
			window2 = wm:GetControlByName("CPC_BTNWIN2")
			setBtnIcons(window2.btn1, "esoui/art/bank/bank_tabicon_withdraw")
			setBtnIcons(window2.btn2, "esoui/art/bank/bank_tabicon_deposit")
			window2:SetDimensions(window2.title:GetWidth() + 20 + 25 + 32 + 32, 42)	
			
			fragment2 = ZO_FadeSceneFragment:New(window2) -- , nil, 0)
			
			CarosPreCrafter.fragment2 = fragment2
			CarosPreCrafter.window2 = window2
		end
		window2 = CarosPreCrafter.window2
		if CarosPreCrafter.sV.window2Left then
			window2:ClearAnchors()
			window2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CarosPreCrafter.sV.window2Left, CarosPreCrafter.sV.window2Top)
		else
			window2:ClearAnchors()
			window2:SetAnchor(RIGHT, ZO_PlayerBankMenuBarLabel, LEFT, -15, 0)
		end
		SCENE_MANAGER:GetScene("bank"):AddFragment(CarosPreCrafter.fragment2)
	else
		if window2 then
			SCENE_MANAGER:GetScene("bank"):RemoveFragment(CarosPreCrafter.fragment2)
		end
	end
end


local function onCraftingInteraction(_, craft)
	if craft == CRAFTING_TYPE_ALCHEMY and warnAlchemy then d(GS(CPC_WarnAlchemyNow)) warnAlchemy = false end
	if craft == CRAFTING_TYPE_PROVISIONING and warnProvision then d(GS(CPC_WarnProvNow)) warnProvision = false end
	if not CarosPreCrafter.sV.showBtnSmithing and not CarosPreCrafter.sV.showBtnAlchProv then return end
	local window = CarosPreCrafter.window
	if not window then return end
	if craftsToPreCraftResearch[craft] and CarosPreCrafter.mayPrecraftResearchItems then
		GetControl(window, "bgAlt"):SetHidden(true)
		GetControl(window, "bg"):SetHidden(false)
		window:ClearAnchors()
		if CarosPreCrafter.sV.windowLeft then
			window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CarosPreCrafter.sV.windowLeft, CarosPreCrafter.sV.windowTop)
		else
			window:SetAnchor(TOPLEFT, ZO_SmithingTopLevelDeconstructionPanelSlotContainer, TOPRIGHT, 0, 0)
		end
		if CarosPreCrafter.sV.showBtnSmithing then
			if CarosPreCrafter.isOnMainCrafter then
				window.btn2:SetHidden(true)
				
				CarosPreCrafter.buildInternalLLCQueue(craft)
				
				if CarosPreCrafter.checkInternalLLCQueues(craft) then
					window.btn1:SetHidden(false)
					setBtnIcons(window.btn1, "esoui/art/crafting/smithing_tabicon_creation")
					window.btn1:SetHandler("OnMouseEnter", function(self) CarosPreCrafter.showTTResearchCrafting(self, craft) end)
					window.btn1:SetHandler("OnClicked", function() CarosPreCrafter.startResearchCrafting(craft) end)
					window.btn1.flash:SetHidden(false)
					window.btn1.flash:SetColor(0,0.8,0)
					SMITHING_SCENE:AddFragment(CarosPreCrafter.fragment)
				else
					SMITHING_SCENE:RemoveFragment(CarosPreCrafter.fragment)
				end
			else
				window.btn2:SetHidden(true)
				local myItems, svItems, openSpots = CarosPreCrafter.checkResearchItems(craft)
				if openSpots > 0 and #myItems > 0 then 
					window.btn1:SetHidden(false)
					setBtnIcons(window.btn1, "esoui/art/crafting/smithing_tabicon_research")
					window.btn1:SetHandler("OnMouseEnter", function(self) CarosPreCrafter.showResearchBtnTT(self) end)
					
					window.btn1:SetHandler("OnClicked", function() CarosPreCrafter.startResearching(craft) end)
					window.btn1.flash:SetHidden(false)
					window.btn1.flash:SetColor(0,0,0)
					SMITHING_SCENE:AddFragment(CarosPreCrafter.fragment)
				else
					SMITHING_SCENE:RemoveFragment(CarosPreCrafter.fragment)
				end	
			end			
		end
	elseif craft == CRAFTING_TYPE_ALCHEMY and CarosPreCrafter.sV.showBtnAlchProv  then
		buildAlchemyQueue()
		if #carosAlchemyQueue == 1 then
			ALCHEMY_SCENE:RemoveFragment(CarosPreCrafter.fragment)
			return
		end
		ALCHEMY_SCENE:AddFragment(CarosPreCrafter.fragment)
		GetControl(window, "bgAlt"):SetHidden(true)
		GetControl(window, "bg"):SetHidden(false)
		window:ClearAnchors()
		if CarosPreCrafter.sV.windowLeftAlch then
			window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CarosPreCrafter.sV.windowLeftAlch, CarosPreCrafter.sV.windowTopAlch)
		else
			window:SetAnchor(TOPLEFT, ZO_AlchemyTopLevelSlotContainer, TOPRIGHT, -42, 0)
		end
		window.btn1.flash:SetHidden(not CarosPreCrafter.isOnMainCrafter)
		window.btn1.flash:SetColor(0,0.8,0)
		window.btn2:SetHidden(true)
		window.btn1:SetHidden(false)
		window.btn1.refreshTT = function()
			if WINDOW_MANAGER:GetMouseOverControl() ~= CarosPreCrafter.window.btn1 then return end
			InitializeTooltip(InformationTooltip, window.btn1, LEFT)
			InformationTooltip:AddLine(GS(CPC_PrecraftAlch), "ZoFontGame")
			ZO_Tooltip_AddDivider(InformationTooltip)
			for i, v in pairs(carosAlchemyQueue) do
				if type(v) == "table" and v.link and v.count then
					local myCount = v.count * 4
					if GetItemLinkItemType(v.link) == ITEMTYPE_POISON then myCount = myCount * 4 end
					InformationTooltip:AddLine(string.format("%s (%sx)", v.link, myCount), "ZoFontGame")
				end
			end
		end
		window.btn1:SetHandler("OnMouseEnter", 
			function(self) 
				buildAlchemyQueue()
				window.btn1.refreshTT()
		end)
		window.btn1:SetHandler("OnClicked", function() preCraftAlchemy() end)
	elseif craft == CRAFTING_TYPE_PROVISIONING and CarosPreCrafter.sV.showBtnAlchProv then
		buildProvisioningQueue()
		if #carosProvisioningQueue == 1 then
			PROVISIONER_SCENE:RemoveFragment(CarosPreCrafter.fragment)
			return
		end
		PROVISIONER_SCENE:AddFragment(CarosPreCrafter.fragment)
		window:ClearAnchors()
		local CS = CraftStoreFixedAndImprovedLongClassName -- CraftStoreFixedAndImprovedLongClassName.Account.options.usecook
		local useCsCook = CS and CS.Account.options.usecook and CS.Account and CS.Account.options and CS.Account.options.usecook or false
		if CarosPreCrafter.sV.windowLeftProv then
			window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CarosPreCrafter.sV.windowLeftProv, CarosPreCrafter.sV.windowTopProv)
		else
			if useCsCook then
				window:SetAnchor(BOTTOMRIGHT, CraftStoreFixed_Cook, BOTTOMLEFT, 0, 290)
			else
				window:SetAnchor(TOPLEFT, ZO_ProvisionerTopLevelMultiCraftContainer, TOPRIGHT, -10, 0)
			end
		end
		GetControl(window, "bgAlt"):SetHidden(not useCsCook)
		GetControl(window, "bg"):SetHidden(useCsCook)

		window.btn1.flash:SetHidden(not CarosPreCrafter.isOnMainCrafter)
		window.btn1.flash:SetColor(0,0.8,0)
		window.btn2:SetHidden(true)
		window.btn1:SetHidden(false)
		window.btn1.refreshTT = function()
			InitializeTooltip(InformationTooltip, window.btn1, LEFT)
			InformationTooltip:AddLine(GS(CPC_PrecraftProv), "ZoFontGame")
			ZO_Tooltip_AddDivider(InformationTooltip)
			for i, v in pairs(carosProvisioningQueue) do
				if type(v) == "table" and v.link and v.count then
					local myCount = v.count * 4
					InformationTooltip:AddLine(string.format("%s (%sx)", v.link, myCount), "ZoFontGame")
				end
			end
		end
		window.btn1:SetHandler("OnMouseEnter", function(self)
				buildProvisioningQueue()
				window.btn1.refreshTT()
			end)
		window.btn1:SetHandler("OnClicked", function() preCraftProvisioning() end)
	end
end

function CarosPreCrafter:Initialize()
	-- Setup the SavedVars
	CarosPreCrafter.sV = ZO_SavedVars:NewAccountWide("CarosPreCrafterSavedVariables", 1, nil, {}) -- account wide
	local sV = CarosPreCrafter.sV
	-- Setup SavedVars for Alchemy/Provisioning Writ-Precrafting
	sV.desiredProv = sV.desiredProv or 100
	sV.desiredPot = sV.desiredPot or 100
	sV.desiredPois = sV.desiredPois or 200
	sV.desiredProv1ad = CarosPreCrafter.sV.desiredProv1ad or 0
	sV.desiredProv1ep = sV.desiredProv1ep or 0
	sV.desiredProv1dc = sV.desiredProv1dc or 0
	sV.desiredPot1 = sV.desiredPot1 or 0
	sV.bank = sV.bank or false
	sV.customItems = sV.customItems or {}
	
	-- Setup the main crafter and if the user wants to be reminded
	sV.theChar = sV.theChar or 0
	if sV.warnMe == nil and  sV.theChar ~= 0 then  sV.warnMe = true end
	if sV.theChar == 0 then sV.warnMe = false end
	refreshCustomPoisons()
	refreshCustomPotions()
	local panelName = "Caro's Pre-Crafter"
	local panelData = {
		type = "panel",
		name = panelName,
		displayName = "|c9e0911Caro|r's  Pre-Crafter",
		author = "|c1d6dadIrniben|r",
		registerForRefresh = true,
    }
	
	local charNames = {GS(CPC_LAM_NotSet)}
	local charIds = {0}
	for i=1, GetNumCharacters() do
		local myName, _, _, _, _, _, charId = GetCharacterInfo(i)
		myName = zo_strformat("<<C:1>>", myName)
		table.insert(charNames, myName)
		table.insert(charIds, charId)
		CarosPreCrafter.allMyChars[charId] = myName
	end
	
	local epTT = {zo_strformat(GS(CPC_MaxNumAllianceLev1), GetAllianceName(ALLIANCE_EBONHEART_PACT))}
	local dcTT = {zo_strformat(GS(CPC_MaxNumAllianceLev1), GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT))}
	local adTT = {zo_strformat(GS(CPC_MaxNumAllianceLev1), GetAllianceName(ALLIANCE_ALDMERI_DOMINION))}
	
	for i, v in pairs ( writFoodLev1AD) do
		table.insert(adTT, zo_strformat("<<C:1>>", GetItemLinkName(string.format(craftedLink, i))))
	end
	for i, v in pairs ( writFoodLev1EP) do
		table.insert(epTT, zo_strformat("<<C:1>>", GetItemLinkName(string.format(craftedLink, i))))
	end
	for i, v in pairs ( writFoodLev1DC) do
		table.insert(dcTT, zo_strformat("<<C:1>>", GetItemLinkName(string.format(craftedLink, i))))
	end
	adTT = table.concat(adTT, "\n")
	dcTT = table.concat(dcTT, "\n")
	epTT = table.concat(epTT, "\n")
	local optionsData = {
		{
			type = "description",
			text = GS(CPC_LAM_GeneralDescr), 
			width = "full", 
			
		},
		{
			type = "dropdown",
			name = GS(CPC_LAM_MainCrafter),
			width = "full",
			choices = charNames,
			choicesValues = charIds,
			sort = "name-up",
			default = false,
			getFunc = function() return sV.theChar end,
			setFunc = function(value) sV.theChar = value end,
		},
		{
			type = "checkbox",
			name = GS(CPC_LAM_WarnOnLogin),
			width = "full",
			default = false,
			getFunc = function() return sV.warnMe end,
			setFunc = function(value) sV.warnMe = value end,
			disabled = function() return  sV.theChar == 0 end,
		},
		{
			type = "divider",
			width = "full",
		},
		{
			type = "submenu",
			name = GS(CPC_LAM_ShowButtonHeading),
			icon = "esoui/art/crafting/smithing_tabicon_creation_up.dds",
			controls = {
				{
					type = "checkbox",
					name = GS(CPC_LAM_ShowButtonAlchProv),
					tooltip = GS(CPC_LAM_ButtonsOnlyShowWhenNeeded),
					width = "full",
					getFunc = function() return sV.showBtnAlchProv or false end,
					setFunc = function(value) sV.showBtnAlchProv = value CarosPreCrafter.showButton() end,
				},
				{
					type = "checkbox",
					name = GS(CPC_LAM_ShowButtonSmithing),
					tooltip = GS(CPC_LAM_ButtonsOnlyShowWhenNeeded),
					width = "full",
					getFunc = function() return sV.showBtnSmithing or false end,
					setFunc = function(value) sV.showBtnSmithing = value CarosPreCrafter.showButton() end,
				},
				{
					type = "checkbox",
					name = GS(CPC_LAM_ShowButtonBank),
					tooltip = GS(CPC_LAM_ButtonsOnlyShowWhenNeeded),
					width = "full",
					getFunc = function() return sV.showBtnBank or false end,
					setFunc = function(value) sV.showBtnBank = value CarosPreCrafter.showButton() end,
				},
				{
					type = "button",
					name = GS(CPC_LAM_ResetButtonPos),
					width = "full",
					func = function() 
						sV.windowLeft = false 
						sV.windowLeftAlch = false 
						sV.windowLeftProv = false 
						sV.window2Left = false   
						sV.window3Left = false
						CarosPreCrafter.showButton()
					end,
				},
			}	
		},		
		{
			type = "divider",
			width = "full",
		},
		{
			type = "submenu",
			name = string.format(GS(CPC_LAM_SubMenu_WritPreCraftingMaxLevel), GS(CPC_LAM_MaxLevel)),
			icon = "esoui/art/compass/repeatablequest_available_icon.dds",
			controls = {
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizeProvItemsMaxLevel), GS(CPC_LAM_MaxLevel), ""),
				tooltip = GS(CPC_LAM_MaxNumEach),
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 100,
				getFunc = function() return sV.desiredProv end,
				setFunc = function(value) sV.desiredProv = value end,
			},
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizePotionsMaxLevel), GS(CPC_LAM_MaxLevel)),
				tooltip = GS(CPC_LAM_MaxNumEach),
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 200,
				getFunc = function() return sV.desiredPot end,
				setFunc = function(value) sV.desiredPot = value end,
			},
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizePoisonsMaxLevel), GS(CPC_LAM_MaxLevel)),
				tooltip = GS(CPC_LAM_MaxNumEach),
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 200,
				getFunc = function() return sV.desiredPois end,
				setFunc = function(value) sV.desiredPois = value end,
			},}
		},
		{
			type = "submenu",
			name = string.format(GS(CPC_LAM_SubMenu_WritPreCraftingMaxLevel), GS(CPC_LAM_Level1)),
			icon = "esoui/art/compass/repeatablequest_available_icon.dds",
			controls = {
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizeProvItemsMaxLevel), GS(CPC_LAM_Level1), ", EP"),
				tooltip = epTT,
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 100,
				getFunc = function() return sV.desiredProv1ep end,
				setFunc = function(value) sV.desiredProv1ep = value end,
			},
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizeProvItemsMaxLevel), GS(CPC_LAM_Level1), ", DC"),
				tooltip = dcTT,
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 100,
				getFunc = function() return sV.desiredProv1dc end,
				setFunc = function(value) sV.desiredProv1dc = value end,
			},
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizeProvItemsMaxLevel), GS(CPC_LAM_Level1), ", AD"),
				tooltip = adTT,
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 100,
				getFunc = function() return sV.desiredProv1ad end,
				setFunc = function(value) sV.desiredProv1ad = value end,
			},
			{
				type = "slider",
				name = string.format(GS(CPC_LAM_StackSizePotionsMaxLevel), GS(CPC_LAM_Level1)),
				tooltip = GS(CPC_LAM_MaxNumEach),
				min = 0,
				max = 1000,
				step = 4, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 200,
				getFunc = function() return sV.desiredPot1 end,
				setFunc = function(value) sV.desiredPot1 = value end,
			},}
		}	
    }
	
	local subMenuCustom = {
		type = "submenu",
		name = GS(CPC_LAM_SubMenu_Custom), 
		icon = "esoui/art/crafting/alchemy_tabicon_reagent_up.dds",
		width = "full", 
		controls = {}
	}
	
	for i,v in pairs(potionOptions) do
		local potionChoices = {}
		local potionChoiceValues = {}
		local myName = zo_strformat("<<C:1>>", GetItemLinkName(string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])))
		if i == 44809 then myName = zo_strformat("<<C:1>>", GetItemLinkName(string.format(alchemyStringLevel1, i, alchemyAlternatives[i][1]))) end
		for j, w in pairs(v) do
			table.insert(potionChoices, zo_strformat("<<C:1>> + <<C:2>>", GetItemLinkName(string.format(strIL, w[1])), GetItemLinkName(string.format(strIL, w[2]))))
			table.insert(potionChoiceValues, table.concat(w, ";"))
		end
		local myEntry = {
			type = "dropdown",
			name = myName,
			width = "full",
			choices = potionChoices,
			choicesValues = potionChoiceValues,
			sort = "name-up",
			default = GS(CPC_LAM_Standard),
			default = false,
			getFunc = function() if sV.potOptions and sV.potOptions[i] then return table.concat(sV.potOptions[i], ";") else return GS(CPC_LAM_Standard) end end,
			setFunc = function(value) sV.potOptions = sV.potOptions or {} local myValues = {SplitString(";", value)} sV.potOptions[i] = {tonumber(myValues[1]), tonumber(myValues[2])} refreshCustomPotions()  end,
		}
		table.insert(subMenuCustom.controls, myEntry)
	end
	
	for i,v in pairs(poisonOptions) do
		local poisonChoices = {}
		local poisonChoiceValues = {}
		local myName = zo_strformat("<<C:1>>", GetItemLinkName(string.format(alchemyStringMaxLevel, i, alchemyAlternatives[i][1])))
		for j, w in pairs(v) do
			table.insert(poisonChoices, zo_strformat("<<C:1>> + <<C:2>>", GetItemLinkName(string.format(strIL, w[1])), GetItemLinkName(string.format(strIL, w[2]))))
			table.insert(poisonChoiceValues, table.concat(w, ";"))
		end
		local myEntry = {
			type = "dropdown",
			name = myName,
			width = "full",
			choices = poisonChoices,
			choicesValues = poisonChoiceValues,
			sort = "name-up",
			default = GS(CPC_LAM_Standard),
			getFunc = function() if sV.poisOptions and sV.poisOptions[i] then return table.concat(sV.poisOptions[i], ";") else return nil end end,
			setFunc = function(value) sV.poisOptions = sV.poisOptions or {} local myValues = {SplitString(";", value)} sV.poisOptions[i] = {tonumber(myValues[1]), tonumber(myValues[2])} refreshCustomPoisons() end,
		}
		table.insert(subMenuCustom.controls, myEntry)
	end
	
	table.insert(subMenuCustom.controls, {
		type = "button",
		name = GS(CPC_LAM_IngridientsToChat), 
		func = ingredientsToChat,
		width = "half",
	})
	
	table.insert(subMenuCustom.controls, {
		type = "button",
		name = GS(CPC_LAM_AutoSelect), 
		func = autoSelectingredients,
		width = "half",
	})
	
	table.insert(optionsData, subMenuCustom)
	
	if LibPrice then
		local currentCustomItem = false
		local customItems = {}
		local customItemNames = {}
		local setPanelSize = true
		local function getCustomItems(buildNew)
			if not buildNew then return customItems end
			customItems = {}
			customItemNames = {}
			for i, v in pairs(sV.customItems) do
				table.insert(customItems, i)
				table.insert(customItemNames, zo_strformat("<<C:1>>", GetItemLinkName(i)))
			end
			return customItemNames
		end
		local function getCurrentItemDescription()
			if setPanelSize and CPCLAMCustomItemIcon and CPCLAMCustomItemCurrentHead then
				CPCLAMCustomItemIcon:SetDimensionConstraints(100,26,100,104)
				CPCLAMCustomItemCurrentHead:SetDimensionConstraints(420,26,420,104)
				CPCLAMCustomItemCurrentHead.desc:SetDimensionConstraints(420,26,420,104)
				setPanelSize = false
			end
			if not currentCustomItem then 
				if CPCLAMCustomItemCurrentHead then
					CPCLAMCustomItemCurrentHead.desc:SetHandler("OnMouseEnter", function() end)
				end
				if CPCLAMCustomItemIcon then 
					CPCLAMCustomItemIcon.texture:SetHandler("OnMouseEnter", function() end)
					CPCLAMCustomItemIcon.texture:SetTexture("esoui/art/crafting/crafting_enchanting_glyphslot_empty.dds") 
				end
				return "" 
			end
			local reqLevel = GetItemLinkRequiredLevel(currentCustomItem)
			local reqCP = GetItemLinkRequiredChampionPoints(currentCustomItem)
			local myText = {}
			if reqCP and reqCP > 0 then reqLevel = string.format("|t28:28:esoui/art/champion/champion_icon_32.dds|t %s", reqCP) end
			
			table.insert(myText, string.format(GS(CPC_LAM_CustomItemLevelAndCount), currentCustomItem, reqLevel, getTotalCount(currentCustomItem)))
			
			local recipe, combinations = CarosPreCrafter.getRecipeOrCombination(currentCustomItem)
			if (not recipe or not recipe[3]) and not combinations then
				table.insert(myText, ZO_ERROR_COLOR:Colorize(GS(CPC_LAM_CustomKnowledgeNot)))
			else
				local itemType = GetItemLinkItemType(currentCustomItem)
				if (itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION) and combinations then
					table.insert(myText, ZO_SUCCEEDED_TEXT:Colorize(zo_strformat(GS(CPC_LAM_CustomKnowledgeCombinations), #combinations)))
				elseif (itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD) and recipe then
					table.insert(myText, ZO_SUCCEEDED_TEXT:Colorize(GS(CPC_LAM_CustomKnowledgeRecipe)))
				end
			end
			local function showCustomIconTooltip()
			-- InformationTooltip:AddLine("bla", "", 1, 1, 1, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, SET_TO_FULL_SIZE)
				InitializeTooltip(InformationTooltip, CPCLAMCustomItemCurrentHead, LEFT)
				local _, _, onUseText = GetItemLinkOnUseAbilityInfo(currentCustomItem)
				local r,g,b =  ZO_NORMAL_TEXT:UnpackRGB()
				if onUseText and onUseText ~= "" then 
					InformationTooltip:AddLine(onUseText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
				end
				for i=1, 10 do
					local hasAb, abText = GetItemLinkTraitOnUseAbilityInfo(currentCustomItem, i)
					if not hasAb then break end
					if abText and abText ~= "" then 
						InformationTooltip:AddLine(abText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
					else 
						break
					end
				end
			end
			if CPCLAMCustomItemIcon then 
				CPCLAMCustomItemIcon.texture:SetTexture(GetItemLinkIcon(currentCustomItem)) 
				CPCLAMCustomItemIcon.texture:SetHandler("OnMouseEnter", showCustomIconTooltip)
				CPCLAMCustomItemIcon.texture:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
				CPCLAMCustomItemIcon.texture:SetMouseEnabled(true)
			end
			if CPCLAMCustomItemCurrentHead then 
				CPCLAMCustomItemCurrentHead.desc:SetHandler("OnMouseEnter", showCustomIconTooltip)
				CPCLAMCustomItemCurrentHead.desc:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
				CPCLAMCustomItemCurrentHead.desc:SetMouseEnabled(true)
			end
			return table.concat(myText, "\n")
		end
		local function updateInvCraftedItemsDropdown()
			if not CPCLAMCustomItemInventoryDropdown then return end
			local itemNames, itemLinks, itemsDone = {}, {}, {}
			local myBags = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
			local writFoodLinks = buildWritFoodLinks(true)
			local writAlchLinks = buildAlchemyItemLinks(true)
			for _, bagId in pairs(myBags) do
				for slotIndex = 0, GetBagSize(bagId) do
					local itemLink = GetItemLink(bagId, slotIndex, 0)
					local itemType = GetItemType(bagId, slotIndex)
					if IsItemLinkCrafted(itemLink) and not itemsDone[itemLink] and not writFoodLinks[itemLink] and 
						not writAlchLinks[itemLink] and not sV.customItems[itemLink] and
						(itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_POTION or 
						itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK) then
						table.insert(itemLinks, itemLink)
						table.insert(itemNames, zo_strformat("<<C:1>>", GetItemLinkName(itemLink)))
						itemsDone[itemLink] = true
					end
				end
			end
			CPCLAMCustomItemInventoryDropdown:UpdateChoices(itemNames, itemLinks)
		end
		local subMenuCustomItems = {
			type = "submenu",
			name = GS(CPC_LAM_SubMenu_CustomItems), 
			icon = "esoui/art/inventory/inventory_tabicon_consumables_up.dds",
			width = "full", 
			controls = {
				{
					type = "divider",
					width = "full",
				},
				{
					type = "description",
					text = GS(CPC_LAM_CustomItemsDescr),
					width = "full",
				},
				{
					type = "divider",
					width = "full",
				},
				{
					type = "dropdown",
					name = GS(CPC_LAM_CustomItem),
					width = "full",
					choices = getCustomItems(true),
					choicesValues = getCustomItems(),
					sort = "name-up",
					default = GS(CPC_LAM_NotSet),
					getFunc = function() return currentCustomItem end,
					setFunc = function(value) currentCustomItem = value end,
					reference = "CPCLAMCustomItemsDropdown",
				},
				{
					type = "texture",
					imageWidth = 64,
					imageHeight = 64,
					image = "esoui/art/crafting/crafting_enchanting_glyphslot_empty.dds",
					width = "half",
					reference = "CPCLAMCustomItemIcon",
				},
				{
					type = "description",
					text = function() return getCurrentItemDescription() end,
					width = "half",
					reference =  "CPCLAMCustomItemCurrentHead",
				},
				{
					type = "slider",
					name = GS(CPC_LAM_CustomAmount),
					tooltip = GS(CPC_LAM_CustomAmount),
					min = 0,
					max = 1000,
					step = 4, --(optional)
					clampInput = true, 
					clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
					decimals = 0, 
					autoSelect = true,
					width = "half",
					default = 200,
					getFunc = function() return currentCustomItem and sV.customItems[currentCustomItem] or 0 end,
					setFunc = function(value) 
						sV.customItems[currentCustomItem] = value 
						CPCLAMCustomItemsDropdown:UpdateChoices(getCustomItems(true), getCustomItems())
						CPCLAMCustomItemsDropdown.dropdown:SetSelectedItemText(currentCustomItem or "")
					end,
					disabled = function() return currentCustomItem == false end,
				},
				{
					type = "button",
					name = GS(SI_MAIL_READ_DELETE),
					width = "half",
					func = function() 
						sV.customItems[currentCustomItem] = nil 
						currentCustomItem = false 
						CPCLAMCustomItemsDropdown:UpdateChoices(getCustomItems(true), getCustomItems())
					end,
					disabled = function() return currentCustomItem == false end,
				},
				{
					type = "divider",
					width = "full",
				},
				{
					type = "dropdown",
					name = GS(CPC_LAM_CustomAddFromInventory),
					width = "full",
					choices = {},
					choicesValues = {},
					sort = "name-up",
					default = GS(CPC_LAM_NotSet),
					getFunc = function() end,
					setFunc = function(value) 
						currentCustomItem = value 
						CPCLAMCustomItemsDropdown.dropdown:SetSelectedItemText(value or "")
					end,
					disabled = function() updateInvCraftedItemsDropdown() return false end,
					reference = "CPCLAMCustomItemInventoryDropdown",
				},
			}
		}
		table.insert(optionsData, subMenuCustomItems)
	end
	
	if CraftStoreFixedAndImprovedLongClassName and LibLazyCrafting then
		-- Create options and functions for analysis only when all libs are there (optional depends on)
		CarosPreCrafter.mayPrecraftResearchItems = true
		
		-- Setup callback to rebuild research list on leaving settings menu (will be activated on option change)
		local function cpcOnMenuHiding(oldState, newState)
			if newState == "hiding" then 
				SCENE_MANAGER:GetScene('gameMenuInGame'):UnregisterCallback("StateChange", cpcOnMenuHiding)
				cpcD("hiding menu => rebuilding lists") 
				CarosPreCrafter.setupResearchCrafting()
			end	
		end
		
		local subMenuResearchPrecraft = {
			type = "submenu",
			name = GS(CPC_LAM_SubMenu_PreCraftResearchItems),
			icon = "esoui/art/crafting/smithing_tabicon_research_up.dds",
			width = "full",
			controls = {
				{
					type = "description",
					text = GS(CPC_LAM_PreCraftResearchDescr),
					width = "full",
				},
				{
					type = "slider",
					name = GS(CPC_LAM_PreCraftResearchNoPerCraftPerToon),
					min = 0,
					max = 4,
					step = 1, --(optional)
					clampInput = true, 
					clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 100,
					getFunc = function() return sV.researchItemsToPrecraft or 0 end,
					setFunc = function(value) sV.researchItemsToPrecraft = value SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding) end,
				},
				-- TODO ?: add options to precraft nirnhoned and or jewelry -- still haven't figured out if this option would actually be useful for anyone
				{
					type = "header",
					name = GS(CPC_LAM_PreCraftResearchActivateFor),
					width = "full",
				},
			}
		}
		sV.researchChars = sV.researchChars or {}
		
		local changedAnyCharToActive = false
		local generalCraftsSubMenu = {}
		local nirnSubMenu = {		
				{
					type = "slider",
					name = string.format(GS(CPC_LAM_PreCraftResearchKeepNirn), string.format(strIL, 56862), string.format(strIL, 56863)),
					tooltip = string.format(GS(CPC_LAM_PreCraftResearchKeepNirn), string.format(strIL, 56862), string.format(strIL, 56863)),
					min = 0,
					max = 50,
					step = 1, --(optional)
					clampInput = false, 
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 5,
					getFunc = function() return sV.keepNirnMats or 10 end,
					setFunc = function(value) 
						sV.keepNirnMats = value 
						SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding) 
					end,
				},
		}
		local jewelrySubMenu = {}
		local jewelryTraitSubMenu = {		
				{
					type = "slider",
					name = GS(CPC_LAM_PreCraftResearchKeepTraitItems),
					tooltip = GS(CPC_LAM_PreCraftResearchKeepTraitItems),
					min = 0,
					max = 200,
					step = 10, --(optional)
					clampInput = false, 
					decimals = 0, 
					autoSelect = true,
					width = "full",
					default = 10,
					getFunc = function() return sV.keepJewelryTraitMats or 10 end,
					setFunc = function(value) 
						sV.keepJewelryTraitMats = value 
						SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding) 
					end,
				},
		}
		
		
		sV.researchJewelryTraits = sV.researchJewelryTraits or {true, true, true}
		sV.keepNirnMats  = sV.keepNirnMats or 10
		sV.keepJewelryTraitMats = sV.keepJewelryTraitMats or 10
		local _, _, numJewelryTraits = GetSmithingResearchLineInfo(CRAFTING_TYPE_JEWELRYCRAFTING, 1)
		for i=1, numJewelryTraits do
			table.insert(jewelryTraitSubMenu,
					{
						type = "checkbox",
						name = GS("SI_ITEMTRAITTYPE", GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_JEWELRYCRAFTING, 1, i)),
						tooltip = 
							function()
								local traitId, traitDescr = GetSmithingResearchLineTraitInfo(CRAFTING_TYPE_JEWELRYCRAFTING, 1, i)
								local matLink = GetSmithingTraitItemLink(traitId + 1)
								local stackBagpack,stackBank,stackCraftbag = GetItemLinkStacks(matLink)
								local myTooltip = string.format("|t20:20:%s|t %s\n (|t20:20:esoui/art/tooltips/icon_bag.dds:inheritcolor|t %s / |t20:20:esoui/art/tooltips/icon_bank.dds:inheritcolor|t %s / |t20:20:esoui/art/tooltips/icon_craft_bag.dds:inheritcolor|t %s)", GetItemLinkIcon(matLink), matLink, stackBagpack, stackBank, stackCraftbag)
								if stackBagpack + stackBank + stackCraftbag < sV.keepJewelryTraitMats then 
									myTooltip = ZO_ERROR_COLOR:Colorize(myTooltip)
								end
								myTooltip = string.format("%s\n%s", myTooltip, traitDescr)
								if LibPrice then 
									local price, priceSource = LibPrice.ItemLinkToPriceGold(matLink)
									if price and priceSource ~= "npc" then 
										myTooltip = string.format("%s\n ~ %s|t20:20:esoui/art/loot/icon_goldcoin_pressed.dds|t", myTooltip, 
										ZO_FastFormatDecimalNumber(ZO_LocalizeDecimalNumber((math.floor(price * 100 + 0.5) / 100))))
									end
								end
								return myTooltip
							end,
						width = "full",
						default = false,
						getFunc = function() return sV.researchJewelryTraits[i] or false end,
						setFunc = 
							function(value) 
								sV.researchJewelryTraits[i] = value 
								SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding)
							end,
					})
		end
		for i=2, #charIds do
			local myToonId = charIds[i]
			sV.researchChars[myToonId] = sV.researchChars[myToonId] or {}
			sV.researchChars[myToonId].name = charNames[i]
			if not sV.researchChars[myToonId].isALittleKnowItAll and myToonId ~= sV.theChar then
				table.insert(generalCraftsSubMenu,
					{
						type = "checkbox",
						name = charNames[i],
						width = "full",
						default = false,
						getFunc = function() return sV.researchChars[myToonId].active or false end,
						setFunc = 
							function(value) 
								sV.researchChars[myToonId].active = value 
								SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding)
							end,
						disabled = function() return sV.theChar == myToonId end,
					}
				)
			end
			if not sV.researchChars[myToonId].finishedNirn and myToonId ~= sV.theChar then
				table.insert(nirnSubMenu,
					{
						type = "checkbox",
						name = charNames[i],
						width = "full",
						default = false,
						getFunc = function() return sV.researchChars[myToonId].doNirn or false end,
						setFunc = 
							function(value) 
								sV.researchChars[myToonId].doNirn = value 
								SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding)
							end,
						disabled = function() return sV.theChar == myToonId end,
					}
				)
			end
			if not sV.researchChars[myToonId].finishedJewelry and myToonId ~= sV.theChar then
				table.insert(jewelrySubMenu,
					{
						type = "checkbox",
						name = charNames[i],
						width = "full",
						default = false,
						getFunc = function() return sV.researchChars[myToonId].doJewelry or false end,
						setFunc = 
							function(value) 
								sV.researchChars[myToonId].doJewelry = value 
								SCENE_MANAGER:GetScene('gameMenuInGame'):RegisterCallback("StateChange", cpcOnMenuHiding)
							end,
						disabled = function() return tonumber(sV.theChar) == myToonId end,
					}
				)
			end
		end
		table.insert(subMenuResearchPrecraft.controls, {
				type = "submenu",
				name = string.format("%s/%s/%s", GS(SI_TRADESKILLTYPE1), GS(SI_TRADESKILLTYPE2), GS(SI_TRADESKILLTYPE6)),
				icon = "esoui/art/crafting/smithing_tabicon_research_up.dds",
				width = "full",
				controls = generalCraftsSubMenu
			})
		table.insert(subMenuResearchPrecraft.controls, {
				type = "submenu",
				name = GS(SI_ITEMTRAITTYPE25),
				icon = "esoui/art/icons/crafting_potent_nirncrux_stone.dds",
				width = "full",
				controls = nirnSubMenu
			})
		table.insert(subMenuResearchPrecraft.controls, {
				type = "submenu",
				name = GS(SI_ITEMTYPEDISPLAYCATEGORY13),
				icon = "esoui/art/crafting/jewelry_tabicon_icon_up.dds",
				width = "full",
				controls = jewelrySubMenu
			})
		table.insert(subMenuResearchPrecraft.controls, {
				type = "submenu",
				name = GS(SI_ITEMTYPE66),
				icon = "esoui/art/crafting/jewelry_tabicon_icon_up.dds",
				width = "full",
				controls = jewelryTraitSubMenu
			})
		table.insert(optionsData, subMenuResearchPrecraft)
	else
		table.insert(optionsData, {
			type = "description",
			text = GS(CPC_LAM_PreCraftResearchNotPossibleDescr),
			width = "full", 
		})
	end
	local function showOrHideInventoryFragment(showNow)
		local menuScene = SCENE_MANAGER:GetScene('gameMenuInGame')
		if showNow and sV.restockShowMenu then
			--menuScene:AddFragment(CRAFT_BAG_FRAGMENT)
			menuScene:AddFragment(RIGHT_PANEL_BG_FRAGMENT)
			menuScene:AddFragment(INVENTORY_MENU_FRAGMENT)
			menuScene:AddFragment(INVENTORY_WINDOW_SOUNDS)
		else
			menuScene:RemoveFragment(CRAFT_BAG_FRAGMENT)
			menuScene:RemoveFragment(INVENTORY_FRAGMENT)
			menuScene:RemoveFragment(WALLET_FRAGMENT)
			menuScene:RemoveFragment(QUEST_ITEMS_FRAGMENT)
			menuScene:RemoveFragment(KEYBOARD_QUICKSLOT_FRAGMENT)
			menuScene:RemoveFragment(KEYBOARD_QUICKSLOT_CIRCLE_FRAGMENT)
			menuScene:RemoveFragment(RIGHT_PANEL_BG_FRAGMENT)
			menuScene:RemoveFragment(INVENTORY_MENU_FRAGMENT)
			menuScene:RemoveFragment(INVENTORY_WINDOW_SOUNDS)
		end
	end

	local restockItemToEdit = false
	sV.restockGuildStoreItems = sV.restockGuildStoreItems or {}
	
	local function getRestockItemList()
		local restockGuildStoreItems = {}
		for i, v in pairs(sV.restockGuildStoreItems) do
			table.insert(restockGuildStoreItems, i)
		end
		table.sort(restockGuildStoreItems, function(a,b) return GetItemLinkName(a) < GetItemLinkName(b) end)
		return restockGuildStoreItems
	end
	
	local restockGuildStoreItems = getRestockItemList()
	
	local subMenuRestock = {
		type = "submenu",
		name = GS(CPC_LAM_RestockHeader),
		icon = "esoui/art/vendor/vendor_tabicon_buy_up.dds",
		width = "full",
		reference = "CPCLAMSubMenuRestock",
		controls = {
			{
				type = "description",
				text = GS(CPC_LAM_RestockDescr),
				width = "full",
			},
			{
				type = "slider",
				name = GS(SI_ITEMTYPE44), -- style mats
				min = 0,
				max = 200,
				step = 1, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 0,
				getFunc = function() return sV.restockStyleMats or 0 end,
				setFunc = function(value) sV.restockStyleMats = value ~= 0 and value or false end,
			},
			{
				type = "slider",
				name = GS(SI_ITEMTYPE51), -- potency runes
				min = 0,
				max = 200,
				step = 1, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 0,
				getFunc = function() return sV.restockRunes or 0 end,
				setFunc = function(value) sV.restockRunes = value ~= 0 and value or false end,
			},
			{
				type = "slider",
				name = GS(CPCLamRestockGoldToKeep), 
				tooltip = GS(CPCLamRestockGoldToKeepTT),
				min = 0,
				max = 10000,
				step = 100, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 0,
				getFunc = function() return sV.restockGoldToKeep or 0 end,
				setFunc = function(value) sV.restockGoldToKeep = value ~= 0 and value or false end,
			},
			
			{
				type = "divider",
				width = "full",
			},
			
			{
				type = "description",
				text = GS(CPC_LAM_RestockGuildDescr),
				width = "full",
			},
			{
				type = "checkbox",
				name = GS(CPC_LAM_RestockGuildShowMenu),
				tooltip = GS(CPC_LAM_RestockGuildShowMenu),
				width = "full",
				default = false,
				getFunc = function() return sV.restockShowMenu or false end,
				setFunc = function(value) sV.restockShowMenu = value showOrHideInventoryFragment(true) end,
			},
			{
				type = "dropdown",
				name = GS(CPC_LAM_CustomItem),
				width = "full",
				choices = restockGuildStoreItems,
				choicesValues = restockGuildStoreItems,
				default = GS(CPC_LAM_NotSet),
				getFunc = function() return restockItemToEdit end,
				setFunc = function(value) restockItemToEdit = value	end,
				reference = "CPCLAMRestockItemsDropdown",
			},		
			{
				type = "button",
				name = GS(SI_ITEM_ACTION_ADD_TO_CRAFT),
				width = "half",
				func = function() CPC.restockShowAddItemsMenu() end,
			},	
			{
				type = "button",
				name = GS(SI_MAIL_READ_DELETE),
				width = "half",
				func = function() 
					sV.restockGuildStoreItems[restockItemToEdit] = nil 
					restockItemToEdit = false 
					CPCLAMRestockItemsDropdown.updateItems()
				end,
				disabled = function() return not restockItemToEdit end,
			},
			{
				type = "slider",
				name = GS(CPC_LAM_RestockMinStock), 
				tooltip = GS(CPC_LAM_RestockMinStockTT), 
				min = 0,
				max = 1000,
				step = 10, --(optional)
				clampInput = true, 
				clampFunction = function(value, min, max) return math.max(math.min(value, max), min) end,
				decimals = 0, 
				autoSelect = true,
				width = "full",
				default = 0,
				getFunc = function() return restockItemToEdit and sV.restockGuildStoreItems[restockItemToEdit] or 0 end,
				setFunc = function(value) if not restockItemToEdit then return end sV.restockGuildStoreItems[restockItemToEdit] = value end,
				disabled = function() return not restockItemToEdit end,
			},
		}
	}
	
	table.insert(optionsData, subMenuRestock)
	local LAM = LibAddonMenu2
    local myPanel = LAM:RegisterAddonPanel("CarosPreCrafterOptions", panelData)
	LAM:RegisterOptionControls("CarosPreCrafterOptions", optionsData)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel ~= myPanel then return end
		CPCLAMSubMenuRestock.label:SetHandler("OnMouseUp", function(_, button, upInside) 
			if not upInside or button ~= 1 then return end
			showOrHideInventoryFragment(CPCLAMSubMenuRestock.open)
		end, "CPC_InvHandler")
		
		CPCLAMRestockItemsDropdown.updateItems = function() CPCLAMRestockItemsDropdown:UpdateChoices(getRestockItemList(), getRestockItemList()) end
		CPCLAMRestockItemsDropdown.updateItems()
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= myPanel then return end
		if CPCLAMSubMenuRestock and CPCLAMSubMenuRestock.open then showOrHideInventoryFragment(true) end
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel ~= myPanel then return end
		showOrHideInventoryFragment(false)
	end)
	if sV.theChar and  CarosPreCrafter.thisCharId == sV.theChar then  
		CarosPreCrafter.isOnMainCrafter = true
	end
	if CarosPreCrafter.isOnMainCrafter and sV.warnMe then
		EVENT_MANAGER:RegisterForEvent("CarosPreCrafterPlayerReady", EVENT_PLAYER_ACTIVATED, function() zo_callLater(caroCheckPreCrafting, 4200) end)
	end
	
	sV.researchItemsToPrecraft = sV.researchItemsToPrecraft or 0
	if CarosPreCrafter.mayPrecraftResearchItems and sV.researchItemsToPrecraft > 0 then 
		CarosPreCrafter.setupResearchCrafting() 
	end
	
	CarosPreCrafter.showButton()
	CarosPreCrafter.initRestock()
	
	EVENT_MANAGER:UnregisterForEvent(CarosPreCrafter.name.."OnLoad", EVENT_ADD_ON_LOADED)
end

function CarosPreCrafter.OnAddonLoaded(event, addonName)
  if addonName == CarosPreCrafter.name then
    CarosPreCrafter:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(CarosPreCrafter.name.."OnLoad", EVENT_ADD_ON_LOADED, CarosPreCrafter.OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(CarosPreCrafter.name.."OnCraftInteract", EVENT_CRAFTING_STATION_INTERACT, onCraftingInteraction)
EVENT_MANAGER:RegisterForEvent(CarosPreCrafter.name.."OnBankInteract", EVENT_OPEN_BANK , function(_, bagId) if bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then CarosPreCrafter.onBankInteraction() end end)

SLASH_COMMANDS["/cpc"] = CarosPreCrafter.preCraftQueque