local CPC = CarosPreCrafter
local GS = GetString
local cpcD = CarosPreCrafter.cpcD
local lastSearchedItemLink = false
local AGS = AwesomeGuildStore
local strIL = "|H0:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
local lastSpinnerValue = false
	
local itemsInList = {}
local itemsActive = {}

local function onOpenStore()
--/script d(GetItemLinkStacks(GetStoreItemLink(40)))
	if not CPC.sV.restockStyleMats and not CPC.sV.restockRunes then return end
	local numToBuy, itemPrices, storeEntries = {}, {}, {}
	local totalCost = 0
	for storeEntryIndex = 1, GetNumStoreItems() do
		local itemLink = GetStoreItemLink(storeEntryIndex)
		local itemType = GetItemLinkItemType(itemLink)
		local _, _, _, price,_, _, _, _, _, curtType1, curtQuant1, curtType2, curtQuant2 = GetStoreEntryInfo(storeEntryIndex)
		if curtType1 == 0 and curtType2 == 0 and not numToBuy[itemLink] then
			local x1,x2,x3 = GetItemLinkStacks(itemLink)
			local itemStacks = x1+x2+x3
			if itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY and CPC.sV.restockRunes and itemStacks < CPC.sV.restockRunes then
				numToBuy[itemLink] = CPC.sV.restockRunes - itemStacks
				itemPrices[itemLink] = price
				storeEntries[itemLink] = storeEntryIndex
				totalCost = totalCost + price * numToBuy[itemLink]
			elseif itemType == ITEMTYPE_STYLE_MATERIAL and CPC.sV.restockStyleMats and itemStacks < CPC.sV.restockStyleMats then
				numToBuy[itemLink] = CPC.sV.restockStyleMats - itemStacks
				itemPrices[itemLink] = price
				totalCost = totalCost + price * numToBuy[itemLink]
				storeEntries[itemLink] = storeEntryIndex
			end
		end
	end
	local currentBalance = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
	if CPC.sV.restockGoldToKeep and CPC.sV.restockGoldToKeep > 0 then currentBalance = currentBalance - CPC.sV.restockGoldToKeep end
	if currentBalance <= 0 then return end
	
	while totalCost > currentBalance do
		for itemLink, toBuy in pairs(numToBuy) do
			numToBuy[itemLink] = numToBuy[itemLink] - 1
			if numToBuy[itemLink] <= 0 then numToBuy[itemLink] = nil end
			totalCost = totalCost - itemPrices[itemLink]
			if totalCost <= currentBalance then break end
		end
	end
	for itemLink, toBuy in pairs(numToBuy) do
		d(toBuy.."x "..itemLink) 
		BuyStoreItem(storeEntries[itemLink], toBuy)
	end
end


local function refreshGuildStoreItems()
	for i, v in pairs(itemsInList) do
		itemsActive[i] = nil
	end
	 for itemLink, minStock in pairs(CPC.sV.restockGuildStoreItems) do
		local x1,x2,x3 = GetItemLinkStacks(itemLink)
		if x1+x2+x3 < minStock then
			itemsInList[itemLink] = true
			itemsActive[itemLink] = true
		end
	 end
end

local function getNextGuildStoreItemLink(singleSearch)
	refreshGuildStoreItems()
	local sortedItemList = {}
	local activeItemIds = {}
	for i, v in pairs(itemsInList) do
		table.insert(sortedItemList, i)
		if itemsActive[i] then table.insert(activeItemIds, GetItemLinkItemId(i)) end
	end
	if #sortedItemList == 0 then return false end
	if not singleSearch then return #activeItemIds > 0, activeItemIds end
	table.sort(sortedItemList)
	local oldTableIndex = false
	for i, v in pairs(sortedItemList) do
		if v == lastSearchedItemLink then oldTableIndex = i break end
	end
	oldTableIndex = oldTableIndex or 0
	cpcD("Old index: "..oldTableIndex)
	local newItemLink = false
	local newTableIndex = oldTableIndex
	newTableIndex = newTableIndex%#sortedItemList
	newTableIndex = newTableIndex + 1
	while oldTableIndex ~= newTableIndex do
		if itemsActive[sortedItemList[newTableIndex]] then newItemLink = sortedItemList[newTableIndex] break end
		newTableIndex = newTableIndex%#sortedItemList
		newTableIndex = newTableIndex + 1
	end
	cpcD("New index: "..newTableIndex)
	if not newItemLink then return false end
	cpcD(newItemLink)
	lastSearchedItemLink = newItemLink
	return newItemLink, activeItemIds
end

local function setActiveSearchToCPC()
	local mySM = AGS.internal.tradingHouse.searchManager
	if mySM:GetActiveSearch().label == "CPC Restock" then return end

	for i, v in pairs(mySM.searches) do
		if v.label == "CPC Restock" then 
			mySM:SetActiveSearch(v) 
			cpcD("Found search")
			return
		end
	end
	
	local mySearch = mySM:AddSearch()
	mySearch.label = "CPC Restock"
	mySM:SetActiveSearch(mySearch)
	cpcD("Created new search")
end

function CarosPreCrafter.restockBtnClick(singleSearch)
	if not AGS and not singleSearch then return end
	local mySM = AGS and AGS.internal.tradingHouse.searchManager
	if AGS then setActiveSearchToCPC() end
	if AGS and mySM:GetActiveSearch().label ~= "CPC Restock" then return end
	local myFilter = AGS and mySM:GetFilter(AGS.data.FILTER_ID.TEXT_FILTER)
	 
	 local newItemLink, activeItemIds = getNextGuildStoreItemLink(singleSearch)
	 if not newItemLink then return end
	 
	 newItemLink = singleSearch and ZO_TradingHouseNameSearchFeature_Shared.MakeExactSearchText(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(newItemLink)))
	 if singleSearch then 
		if AGS then 
			myFilter:SetText(newItemLink) 
		else
			TRADING_HOUSE.features.nameSearchFeature.nameSearchEdit:SetText(newItemLink)
			TRADING_HOUSE_SEARCH:DoSearch()
		end
		return 
	end
	 myFilter:SetValues(singleSearch and newItemLink or table.concat(activeItemIds, "+"))

end
					
function CarosPreCrafter.showRestockBtnTT(control)
	
end

local function reanchorRestockGSWin()
	if not CarosPreCrafter.sV.restockShowMenu then return end
	if CarosPreCrafter.sV.window3Left then
		CPC_BTNWIN3:ClearAnchors()
		CPC_BTNWIN3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CarosPreCrafter.sV.window3Left, CarosPreCrafter.sV.window3Top)
	elseif AwesomeGuildStoreSearchListContainer then
		CPC_BTNWIN3:ClearAnchors()
		CPC_BTNWIN3:SetAnchor(TOPRIGHT, AwesomeGuildStoreSearchListContainer, TOPLEFT, -10, 10)
	else
		CPC_BTNWIN3:ClearAnchors()
		CPC_BTNWIN3:SetAnchor(TOPRIGHT, ZO_TradingHouse, TOPLEFT, -10, 18)
	end
end

function CPC.initRestock()
	EVENT_MANAGER:RegisterForEvent(CPC.name.."OpenStore", EVENT_OPEN_STORE, onOpenStore)
	
	ZO_PreHook(TRADING_HOUSE, "SetCurrentMode", function(_, mode) 
		if mode == ZO_TRADING_HOUSE_MODE_BROWSE and CarosPreCrafter.sV.restockShowMenu then
			reanchorRestockGSWin()
			CPC_BTNWIN3.btn2:SetHidden(not AGS)
			CPC_BTNWIN3:SetHidden(false)
		else
			CPC_BTNWIN3:SetHidden(true)
		end
	end)
	
	LibCustomMenu:RegisterContextMenu(function(inventorySlot)
		if not CPC.sV.restockShowMenu then return end
		local itemLink = GetItemLink(inventorySlot.bagId, inventorySlot.slotIndex)
		if CPC.sV.restockGuildStoreItems[itemLink] then
			AddCustomMenuItem(GS(CPC_Restock_RemoveFromList), function() CPC.sV.restockGuildStoreItems[itemLink] = nil if CPCLAMRestockItemsDropdown then CPCLAMRestockItemsDropdown.updateItems() end end)
		else
			AddCustomMenuItem(GS(CPC_Restock_AddToList), function() ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLink) end)
		end
	end)
end

function CPC.restockShowAddItemsMenu() 
	ClearMenu()
	
	local writItems = {
		[CPC_LAM_Level1] = 
			{
				30161, -- Corn Flower
				883, -- Natural Water
				30157, -- Blessed Thistle
				30159, -- Wormwood
			},
		[CPC_LAM_MaxLevel] = 
			{ 
				64501, -- Lorkhan's Tears
				75365, -- Alkahest
				30165, -- Nirnroot
				77591, -- Mudcrab Chitin
				30156, -- Imp Stool
				77590, -- Nightshade
				77584, -- Spider Egg
				30152, -- Violet Coprinus
			}
		}
	
	local _, _, _, writPotion, writPotion1, writPoison, writFood, writFoodLev1AD, writFoodLev1DC, writFoodLev1EP = CPC.getAlchProvTables()
	
	local function getItemLinksFromList(myList, itemLinks)
		local linksDone = {}
		itemLinks = itemLinks or {}
		for i, v in pairs(itemLinks) do linksDone[v] = true end
		for _, idList in pairs(myList) do
			for _, itemId in pairs(idList) do
				local itemLink = string.format(strIL, itemId)
				if not linksDone[itemLink] then
					linksDone[itemLink] = true
					table.insert(itemLinks, itemLink)
				end
			end
		end
		return itemLinks
	end
		

	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE16), GS(CPC_LAM_Level1)), function() 
			
			
			
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", getItemLinksFromList(writPotion1))
		end)
		
	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE16), GS(CPC_LAM_MaxLevel)), function() 
			local itemLinks = {}
			getItemLinksFromList(writPotion, itemLinks)
			getItemLinksFromList(writPoison, itemLinks)
			
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)	
	
	AddCustomMenuItem("-", function() end)
	
	local function addIngredientsFromRecipe(foodLink, itemLinks)
		local recipeListIndex, recipeIndex, known = CarosPreCrafter.getRecipeFromLink(foodLink)
		local linksDone = {}
		itemLinks = itemLinks or {}
		for i, v in pairs(itemLinks) do linksDone[v] = true end
		if known then
			local _, _, numIngredients = GetRecipeInfo(recipeListIndex, recipeIndex)
			for ingredientIndex=1, numIngredients do
				local ingredientLink = GetRecipeIngredientItemLink(recipeListIndex, recipeIndex, ingredientIndex)
				if not linksDone[ingredientLink] then
					linksDone[ingredientLink] = true
					table.insert(itemLinks, ingredientLink)
				end
			end
		end	
	end	
	
	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE18), GS(CPC_LAM_MaxLevel)), function() 
			local itemLinks = {}
			for itemId in pairs(writFood) do
				addIngredientsFromRecipe(string.format(strIL, itemId), itemLinks)
			end
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)	
	
	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE18), GS(CPC_LAM_Level1)..", DC"), function() 
			local itemLinks = {}
			for itemId in pairs(writFoodLev1DC) do
				addIngredientsFromRecipe(string.format(strIL, itemId), itemLinks)
			end
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)
	
	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE18), GS(CPC_LAM_Level1)..", AD"), function() 
			local itemLinks = {}
			for itemId in pairs(writFoodLev1AD) do
				addIngredientsFromRecipe(string.format(strIL, itemId), itemLinks)
			end
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)
		
	AddCustomMenuItem(string.format(GS(CPC_RestockMatsForWrits), GS(SI_ITEMFILTERTYPE18), GS(CPC_LAM_Level1)..", EP"), function() 
			local itemLinks = {}
			for itemId in pairs(writFoodLev1EP) do
				addIngredientsFromRecipe(string.format(strIL, itemId), itemLinks)
			end
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)
	AddCustomMenuItem("-", function() end)
	--[[
	AddCustomMenuItem(string.format("%s (%s)", GS(SI_PROVISIONER_INGREDIENTS_HEADER), GS(CPC_LAM_SubMenu_CustomItems)), function() 
			local itemLinks = {}
			for customItemLink in pairs(CarosPreCrafter.sV.customItems) do
				local itemType = GetItemLinkItemType(customItemLink)
				if itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_FOOD then
					addIngredientsFromRecipe(customItemLink, itemLinks)
				else
					local _, combination = CPC.getRecipeOrCombination(itemLink)
					--addIngredientsFromRecipe(string.format(strIL, itemId), itemLinks)
				end
				
				
				
				
			end
			if #itemLinks == 0 then return end
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", itemLinks)
		end)	
		
	AddCustomMenuItem("-", function() end)
	
	]]--
	for stringId, itemList in pairs(writItems) do
		local linkList = {}
		for i, v in pairs(itemList) do
			table.insert(linkList, string.format(strIL, v))
		end
		AddCustomMenuItem(string.format(GS(CPC_LAM_SubMenu_WritPreCraftingMaxLevel), GS(stringId)), function() 
			ZO_Dialogs_ShowDialog("CPC_DIAG_ADDRESTOCK", linkList)
		end)
	end
	ShowMenu() 
end

function CPC.initDiagAddRestock(self)
    ZO_Dialogs_RegisterCustomDialog("CPC_DIAG_ADDRESTOCK",   
    {
        customControl = self,
        setup = function(diagControl, itemLink)			
			self.itemLinks = type(itemLink) == "table" and itemLink or {itemLink}
			local promptList = {}
			for _, itemLink in pairs(self.itemLinks) do
				table.insert(promptList,
					string.format("|t26:26:%s|t %s", GetItemLinkIcon(itemLink), itemLink))
			end
			GetControl(diagControl, "Prompt"):SetText(table.concat(promptList, "\n"))
			
			diagControl.spinner:SetMinMax(1, 1000)
			diagControl.spinner:SetValue(lastSpinnerValue or 200)
    	end,
        title =
        {
            text = GS(CPC_Restock_AddToList),
        },
        buttons =
        {
            [1] =
            {
                control =   GetControl(self, "Add"),
                text =      SI_ITEM_ACTION_ADD_TO_CRAFT,
                callback =  function(diagControl)
								local stackSize = diagControl.spinner:GetValue()
								lastSpinnerValue = stackSize
								local itemList = CPC.sV.restockGuildStoreItems
								for _, itemLink in pairs(diagControl.itemLinks) do
									if not itemList[itemLink] or itemList[itemLink] < stackSize then itemList[itemLink] = stackSize end
								end
								if CPCLAMRestockItemsDropdown then
									CPCLAMRestockItemsDropdown.updateItems() 
								end 
                            end,
            },
        
            [2] =
            {
                control =   GetControl(self, "Cancel"),
                text =      SI_DIALOG_CANCEL,
            }
        }
    })
	
    self.spinner = ZO_Spinner:New(GetControl(self, "Spinner"))
end
