local LAM2 = LibAddonMenu2

local HearthHomeFilter = {}


HearthHomeFilter.SavedVars = { }
HearthHomeFilter.VarsVersion = 1.0
HearthHomeFilter.DefaultVars = {
	hhfdoorbelltoggle = false, 
	hhftogglewelcome = false,
	hhfsearchdelay = 300,
	hhfclronextog = true,
	hhfusecosts = true,
	hhfuseMA = true,
	noValSignals = false,
	hhfuseTTC = false,
	wrbenable = true,
	PriceToolX = 0,
	PriceToolY = -40,
	SearchToolX = 0,
	SearchToolY = 0,
	ChangedPricePosition = false,
	ChangedSearchPosition = false
}

local hhf = HearthHomeFilter
local wm = GetWindowManager()
local exists = false
local buttonexists = false
local writbuttonexists = false
local LabelsExist = false

local HHFST = ZO_ProvisionerTopLevel
local HHFST2 = ZO_SharedRightPanelBackground

local hhfresultTooltip = PROVISIONER.control:GetNamedChild("Tooltip")
local hhfo = PROVISIONER

local offsetx = -5
local pincontrolx = 197
local offsety = 65
local offsety2 = -30
local offsety3 = -115

local nSearchCount = 0

local nGuests = 0
local nPrevGuests = 0

local nGuestLimit
local nHouseID

local RestoreDefaultRefresh = PROVISIONER.RefreshRecipeList
--local RefreshRecipeList = hhf.FilterEntries 

local hhfPreHooked = false

local areLabelsHidden = true

local hhfchecktabs = false

local foodtab = PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES
local drinktab = PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING

--Strings----------------------------------------------------------
local hhfSearchFieldText = ""
local textdata = ""
local sHouseName = ""
local sMarketAverage = ""
local sCraftCosts = ""
local sCompatText = ""
local sPriceAddonText = ""
local sTTAddonText = ""
local hhffoodlist = "Lilmoth Garlic Hagfish Hearty Garlic Corn Chowder Firsthold Fruit and Cheese Plate West Weald Corn Chowder Orcrest Garlic Apple Jelly Millet-Stuffed Pork Loin Skyrim Jazbay Crostata Mammoth Snout Pie Cyrodilic Cornbread Stormhold Baked Bananas	Jerall View Inn Carrot Cake	Hare in Garlic Sauce Senchal Curry Fish and Rice Elinhir Roast Antelope Cyrodilic Pumpkin Fritters Chorrol Corn on the Cob Garlic Mashed Potatoes Cinnamon Grape Jelly Venison Pasty Redoran Peppered Melon Battaglir Chowder Pellitine Tomato Rice Breton Pork Sausage Alik'r Beets with Goat Cheese Whiterun Cheese Baked Trout Nibenese Garlic Carrots Garlic Pumpkin Seeds Baked Potato Banana Surprise Chicken Breast Baked Apples Carrot Soup Fishy Stick Chicken Breast Roast Corn Grape Preserves"
local hhfdrinklist = "Hagraven's Tonic Markarth Mead Muthsera's Remorse Comely Wench Whisky Grandpa's Bedtime Tonic Aetherial Tea Blue Road Marathon Two-Zephyr Tea Gods-Blind-Me Maormer Tea Sour Mash Rye-In-Your-Eye Nereid Wine Mulled Wine Torval Mint Tea Sorry, Honey Lager Spiceberry Chai Spiced Mazte Honey Rye Bitterlemon Tea Seaflower Tea Eltheric Hooch Mermaid Whiskey Ginger Wheat Beer Barley Nectar Gossamer Mazte Treacleberry Tea Clarified Syrah Wine Nut Brown Ale Lemon Flower Mazte Bog-Iron Ale Surilie Syrah Wine Mazte Golden Lager Four-Eye Grog Red Rye Beer"
-------------------------------------------------------------------

--Labels/UI--------------------------------------------------------
local HHFValueLabel
local HHFValueLabel2
local HHFValueLabel3
local HHFValueLabel4
local HHFValueLabel5
local HHFValueLabel6
local HHFValueLabel7
local HHFValueLabel8
local HHFValueLabel9
local HHFValueLabel10
local HHFValueLabel11
local HHFValueLabel12
local HHFSearchPin
local HHFSearchBox
local HHFSearchField
local HHFSearchClrB
local HHFSearchWritB
local hhfBackdrop
local hhfBackdropbg
local SetWritButtonHidden
------------------------------------------------------------------

--Trade Variables-------------------------------------------------
local maItemValue
local sSuggestCosts
local sTTCma
local sTTCmn
local sTTClists
local nIngAddCount
local sTTCAvg
local sTTCMin
local sTTCCount
local hhfresultstring
------------------------------------------------------------------

--Art and Sound Assets---------------------------------------------
local hhficon = "EsoUI/Art/lfg/lfg_tabIcon_groupTools_down.dds"
local hhfclricon1 = "EsoUI/Art/Buttons/closebutton_up.dds"
local hhfclricon2 = "EsoUI/Art/Buttons/closebutton_mouseover.dds"
local hhfwriicon1 = "esoui/art/buttons/button_xlarge_mousedown.dds"
local hhfwriicon2 = "esoui/art/buttons/button_xlarge_mouseover.dds"
local clrsfx = "Dyeing_Swatch_Selected"
local sgoldicon = " |t15:15:EsoUI/Art/currency/currency_gold.dds|t"
local fontA = "ZoFontChat"
local fontB = "ZoFontGameLargeBold"
local fontS = "ZoFontGameSmall"
local sArrup = "|t15:15:esoui/art/tooltips/arrow_up.dds|t "
local sArrdown = "|t15:15:esoui/art/tooltips/arrow_down.dds|t "
local sArrIcon = "|t15:15:art/fx/texture/whitesquare.dds|t "
local hhfpinicon1 = "esoui/art/buttons/pinned_mousedown.dds"
local hhfpinicon2 = "esoui/art/buttons/pinned_mouseover.dds"
local hhfpinicon3 = "esoui/art/buttons/pinned_normal.dds"
-------------------------------------------------------------------

--Compatibility----------------------------------------------------
local MasterMerchantLoaded = false
local ATTLoaded = false
local TTCLoaded = false
local havePriceAddon = false
local ffcCompatibilityMode = false
local pixCompat = false
-------------------------------------------------------------------


----------------------
--Settings Menu
----------------------
function hhf.CreateSettingsWindow()
	 local panelData = {
		type = "panel",
		name = "HearthHomeFilter",
		displayName = "HearthHome Filter",
		author = "Tanelornian",
		version = "1.0.2.7",
		slashCommand = "/hhf",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("hhfAddonPanel", panelData)

	local optionsData = {
		[1] = {
			type = "header",
			name = "HearthHome Filter Settings",
			},
		[2] = {
			type = "slider",
			name = "Search delay",
			tooltip = "Adjusts how much time (in milliseconds) will pass before the filter searches after typing. This can help smooth out the search when many recipes are known. (Default = 300)",
			min = 0,
			max = 1000,
			step = 1,
			default = 300,
			getFunc = function() return hhf.SavedVars.hhfsearchdelay end,
			setFunc = function(newValue) 
						hhf.SavedVars.hhfsearchdelay = newValue
						end,
			},
		[3] = {
			type = "checkbox",
			name = "Clear search-field when leaving station?",
			tooltip = "When ON your search text will be cleared when you exit a crafting station. When OFF your search text will remain (including between different stations) unless cleared manually." ,
			default = true,
			getFunc = function() return hhf.SavedVars.hhfclronextog end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhfclronextog = newValue				  
				end,
			},
		[4] = {
			type = "checkbox",
			name = "Use provisioner writs search button?",
			tooltip = "When ON you will see a button next to the search bar if you have a provisioner writ daily quest. Clicking on this button will fill the search-box with the name of the food or drink needed for the quest." ,
			default = true,
			getFunc = function() return hhf.SavedVars.wrbenable end,
			setFunc = function(newValue) 
				hhf.SavedVars.wrbenable = newValue				  
				end,
			},			
		[5] = {
            type = "header",
            name = "Crafting Value Settings",    
			width = "full",
			},
		[6] = {
			type = "checkbox",
			name = "Show value of crafting materials?",
			tooltip = "When ON you will see the total market value of the ingredients used to craft a furnishing, food, or drink item under their results tooltip." .. sPriceAddonText,
			default = true,
			getFunc = function() return hhf.SavedVars.hhfusecosts end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhfusecosts = newValue 				
				end,
			disabled = function() return not havePriceAddon end,
			},
		[7] = {
			type = "checkbox",
			name = "Show MM/ATT average value?",
			tooltip = "When ON you will see the average market value of a furnishing, food, or drink item given by Master Merchant or Arkadius Trade Tools at the crafting station under their results tooltip." .. sPriceAddonText,
			default = true,
			getFunc = function() return hhf.SavedVars.hhfuseMA end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhfuseMA = newValue 
				end,
			disabled = function() return not havePriceAddon end,
			},	
		[8] = {
			type = "checkbox",
			name = "Use TTC Prices?",
			tooltip = "When ON you will see a suggested sale price, the average price, the number of listings and the minimum price according to Tamriel Trade Centre for furnishing, food, and drink items at the crafting station under their results tooltip." .. sTTAddonText,
			default = true,
			getFunc = function() return hhf.SavedVars.hhfuseTTC end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhfuseTTC = newValue 
				end,
			disabled = function() return not TTCLoaded end,						
			},			
		[9] = {
			type = "checkbox",
			name = "Disable profit indicator icons?",
			tooltip = "When ON you will no longer see an arrow indicating whether it would be profitable to sell a crafted furnishing, food or drink, according to your price history." .. sPriceAddonText,
			default = false,
			getFunc = function() return hhf.SavedVars.noValSignals end,
			setFunc = function(newValue) 
				hhf.SavedVars.noValSignals = newValue 
				end,
			disabled = function() return not havePriceAddon end,				
			},	
		[10] = {
			type = "button",
			name = "Reset UI Positions",
			tooltip = "Moves the price data tooltip and the searchbox back to its default position.",
			func = function() 
				hhf.SavedVars.ChangedPricePosition = false 
				hhf.SavedVars.ChangedSearchPosition = false 
				end,
			width = "half",				
			},			
		[11] = {
            type = "header",
            name = "House Population Settings",    
			width = "full",
			},
		[12] = {
			type = "checkbox",
			name = "Announce visitors?",
			tooltip = "When ON you will receive a system message when a visitor arrives or departs a house you are in.",
			default = false,
			getFunc = function() return hhf.SavedVars.hhfdoorbelltoggle end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhfdoorbelltoggle = newValue 
				if newValue == false then
					hhf.SavedVars.hhftogglewelcome = newValue 
				end
				end,
			},
		[13] = {
			type = "checkbox",
			name = "Be greeted?",
			tooltip = "When ON you will receive a welcome message with some population information when you enter a player's house. Disabled if Announce Visitors is disabled.",
			default = false,
			getFunc = function() return hhf.SavedVars.hhftogglewelcome end,
			setFunc = function(newValue) 
				hhf.SavedVars.hhftogglewelcome = newValue 
				end,
			disabled = function() return not hhf.SavedVars.hhfdoorbelltoggle end,
			},			
	}
	LAM2:RegisterOptionControls("hhfAddonPanel", optionsData)
end

--------------------------------
--Price Data Functions
--------------------------------

local function findMavg(itemLink)
	local maitemValue 
	if not MasterMerchantLoaded and not ATTLoaded then			
		maItemValue = nil			
	else
		if ATTLoaded then			
			local days = ArkadiusTradeToolsSalesData.settings.tooltips.days				
			maItemValue = ArkadiusTradeTools.Modules.Sales:GetAveragePricePerItem(itemLink, GetTimeStamp() - 86400 * days)		
		else
			if MasterMerchantLoaded then
				local mmItemData = MasterMerchant:itemStats(itemLink, false)
				maItemValue = mmItemData.avgPrice
			end				  
		end
	end	
	if maItemValue ~= nil then		
		return maItemValue
	else
		return nil
	end
end
--TTC function
local function findTTCPrice(itemLink)
	if not TTCLoaded then
		return nil
	end
	local TTCPrice = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if not TTCPrice then return nil end 
	TTCPrice = TTCPrice.SuggestedPrice
	if TTCPrice ~= nil then
		return TTCPrice
	else
		return nil
	end
end
--Extra TTC info
local function findTTCX(itemLink)
	if not TTCLoaded then
		return nil
	end
	local TTCPrice = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
	if not TTCPrice then return nil end 
	local TTCAVG = TTCPrice.Avg
	local TTCMIN = TTCPrice.Min
	local TTCnEntry = TTCPrice.EntryCount
	if TTCPrice ~= nil then
		return TTCAVG, TTCMIN, TTCnEntry
	else
		return nil
	end
end
--Acquire base MA
local function hhfShowMarketValue(itemLink)	
	local hhfValue = findMavg(itemLink)
	
	if hhfValue == nil then 
		hhfValue = 0 		
	end 	
	return hhfValue
end
--Acquire crafting costs
local function hhfShowCraftingValue(itemLink, qty)
	local hhfingValue = hhfShowMarketValue(itemLink) 
	if hhfingValue == nil then  
		hhfingValue = 0 
	end 
	local totalCost = hhfingValue * qty	
	
	return totalCost
end


--------------------------------
--Craft Cost Info Setup
--------------------------------

function hhf.RetrieveItemLinks()
	local nMarketAverage
	sMarketAverage = "No Data" 
	local nCraftCosts
	sCraftCosts = "No Data" 
	local nSuggestedCost
	sSuggestCosts = "No Data"
	local sValSignalIcon = sArrIcon
	local sValSignalIcon2 = sArrIcon
	local sValSignalIcon3 = sArrIcon
	local ingcostenabled = true	
	--TTC Extended Info
	local nTTCma
	local nTTCmn
	local nTTClists
	sTTCma = "No Data"
	sTTCmn = "No Data"
	sTTClists = "No Data"
	--
	
	if not hhf.SavedVars.hhfusecosts or not havePriceAddon then
		ingcostenabled = false
	end
	
	local selectedData = PROVISIONER.recipeTree:GetSelectedData()    
	
	local nRecLstIndx, nRecIndx = hhf.GetCurrentIndices()
	
	local RecipeitemLink = GetRecipeResultItemLink(nRecLstIndx, nRecIndx)	
	if not selectedData then		
		hhf.SetDefaultLabelData()		
	else
		if not SYSTEMS:GetObject("itemPreview"):IsInteractionCameraPreviewEnabled() then
			hhf.SetValLabelsHidden(false)			
		end
		--Cycle through all ingredient requirements from the selected recipe
		local nIngIndx	
		local ningAddCount = 0
		local nIngCraftCost = 0
		local nMissingDataCounter = 0
		for nIngIndx = 1, 6 do
			local ingredientName, _, nIngQty = GetRecipeIngredientItemInfo(nRecLstIndx, nRecIndx, nIngIndx)
			if ingredientName == "" or ingredientName == nil then 			
				break 			
			end				
			local ingredientItemLink = GetRecipeIngredientItemLink(nRecLstIndx, nRecIndx, nIngIndx)
			--d(ingredientItemLink .. " x" ..nIngQty) 
			nIngAddCount = hhfShowCraftingValue(ingredientItemLink, nIngQty)
			if nIngAddCount == 0 or nIngAddCount == nil then
				local nMissingDataCounter = nMissingDataCounter +1
			end
			nIngCraftCost = nIngCraftCost + nIngAddCount
		end	
		--TTC Suggested Cost
		if TTCLoaded then
			local TTCSuggested = findTTCPrice(RecipeitemLink)
			local TTCx = findTTCX(RecipeitemLink)
			--local TTCAvg, TTCMin, TTCn = findTTCX(RecipeitemLink)
			nTTCma, nTTCmn, nTTClists = findTTCX(RecipeitemLink)
			--d("Average: " .. TTCAvg .. " Min: " .. TTCMin .. " Listings: " .. TTCn)
			if TTCSuggested == nil then TTCSuggested = 0 end
			if nTTCma == nil then nTTCma = 0 end
			if nTTCmn == nil then nTTCmn = 0 end
			if nTTClists == nil then nTTClists = 0 end
			--rounding
			nSuggestedCost = math.floor(TTCSuggested * 100 + 0.5)/100
			nTTCmn = math.floor(nTTCmn * 100 + 0.5)/100
		else
			nSuggestedCost = 0
			nTTCma = 0
			nTTCmn = 0
			nTTClists = 0
		end
		nMarketAverage = math.floor(hhfShowMarketValue(RecipeitemLink) * 100 + 0.5)/100		
		
		--Craft costs
		local nCraftCosts = math.floor(nIngCraftCost * 100 + 0.5)/100
		HHFValueLabel4:SetColor(1.0, 1.0, 1.0, 1)
		if nMissingDataCounter > 0 then 
			HHFValueLabel4:SetColor(0.8, 0.0, 0.0, 1)
		end
		if nCraftCosts > nMarketAverage then
			HHFValueLabel3:SetColor(0.8, 0.0, 0.0, 1)
			sValSignalIcon = sArrdown					
		else
			HHFValueLabel3:SetColor(0.0, 0.8, 0.2, 1)
			if nCraftCosts < nMarketAverage then	
				HHFValueLabel3:SetColor(0.0, 0.8, 0.2, 1)
				sValSignalIcon = sArrup				
			end				
		end	
		if nCraftCosts < nSuggestedCost then
			HHFValueLabel6:SetColor(0.0, 0.8, 0.2, 1)
			sValSignalIcon2 = sArrup
		else
			if nCraftCosts > nSuggestedCost then
				HHFValueLabel6:SetColor(0.8, 0.0, 0.0, 1)
				sValSignalIcon2 = sArrdown
			end
		end		
		--TTC extended Signals
		if nCraftCosts < nTTCma then
			HHFValueLabel10:SetColor(0.0, 0.8, 0.2, 1)
			sValSignalIcon3 = sArrup
		else
			if nCraftCosts > nTTCma then
				HHFValueLabel10:SetColor(0.8, 0.0, 0.0, 1)
				sValSignalIcon3 = sArrdown
			end
		end
		--
		--Market Average
		if nMarketAverage == 0 or nMarketAverage == nil then
			HHFValueLabel3:SetColor(0.4, 0.4, 0.4, 1)
			sMarketAverage = "No data"			
		else		
			if hhf.SavedVars.noValSignals then
				sValSignalIcon = ""
			end
			if hhf.GetConsumableTab() or not ingcostenabled then
				sValSignalIcon = ""
				HHFValueLabel3:SetColor(1.0, 1.0, 1.0, 1)
			end
			sMarketAverage = sValSignalIcon .. nMarketAverage .. sgoldicon			
		end

		--TTC Extended Info
		--TTC Average
		if nTTCma == 0 or nTTCma == nil then
			HHFValueLabel10:SetColor(0.4, 0.4, 0.4, 1)
			sTTCma = "No data"			
		else		
			if hhf.SavedVars.noValSignals then
				sValSignalIcon3 = ""
			end
			if hhf.GetConsumableTab() or not TTCLoaded then 
				sValSignalIcon3 = ""
				HHFValueLabel10:SetColor(1.0, 1.0, 1.0, 1)
			end
			sTTCma = sValSignalIcon3 .. nTTCma .. sgoldicon			
		end		
		--
		
		sCraftCosts = nCraftCosts .. sgoldicon
	end	

		
	if nSuggestedCost == 0 or nSuggestedCost == nil then
		HHFValueLabel6:SetColor(0.4, 0.4, 0.4, 1)
		sSuggestCosts = "No data"
	else
		if hhf.SavedVars.noValSignals then
			sValSignalIcon2 = ""
		end			
		if hhf.GetConsumableTab() or not ingcostenabled then			
			sValSignalIcon2 = ""
			HHFValueLabel6:SetColor(1.0, 1.0, 1.0, 1)
		end
		sSuggestCosts = sValSignalIcon2 .. nSuggestedCost .. sgoldicon
	end	
	--Change label based on loaded market addon
	local sMASource = ""
	if ATTLoaded then
		sMASource = "ATT "
	else
		if MasterMerchantLoaded then
			sMASource = "MM "
		else 
			sMASource = ""
		end
	end
	--TTC Extended Info Min and Listings
	if nTTCmn == 0 or nTTCmn == nil then
		HHFValueLabel11:SetColor(0.4, 0.4, 0.4, 1)
		sTTCmn = "No data"
	else
		HHFValueLabel11:SetColor(1.0, 1.0, 1.0, 1)	
		sTTCmn = nTTCmn .. sgoldicon
	end
		
	if nTTClists == 0 or nTTClists == nil then
		HHFValueLabel12:SetColor(0.4, 0.4, 0.4, 1)
		sTTClists = "No data"
	else
		HHFValueLabel12:SetColor(1.0, 1.0, 1.0, 1)
		sTTClists = nTTClists
	end
	--
	--Label set up
		HHFValueLabel:SetText(sMASource .. "Market Avg")
		HHFValueLabel3:SetText(sMarketAverage)
		HHFValueLabel2:SetText("Value of Materials")
		HHFValueLabel4:SetText(sCraftCosts)
		HHFValueLabel5:SetText("TTC Suggests")
		HHFValueLabel6:SetText(sSuggestCosts)
		--TTC Extended Info
		HHFValueLabel7:SetText("TTC Avg")
		HHFValueLabel10:SetText(sTTCma)
		HHFValueLabel8:SetText("(TTC Min:")
		HHFValueLabel11:SetText(sTTCmn)		
		HHFValueLabel9:SetText("Listings:")
		HHFValueLabel12:SetText(sTTClists .. ")")
		--
		
		hhf.ApplyPriceSettings()
end

function hhf.GetSelectionInformation(station)
	if not havePriceAddon and not TTCLoaded then return end 
	
	if station == CRAFTING_TYPE_PROVISIONING then
		hhfchecktabs = true
	else
		hhfchecktabs = false
	end
	
	if not hhfPreHooked then
		-- ZO_PreHook(PROVISIONER, "RefreshRecipeDetails", hhf.RetrieveItemLinks)		
		-- ZO_PreHook(PROVISIONER, "TogglePreviewMode", hhf.valLabelsToggle)	
		-- ZO_PreHook(PROVISIONER, "OnTabFilterChanged", hhf.SetDefaultLabelData)
		SecurePostHook(PROVISIONER, "RefreshRecipeDetails", hhf.RetrieveItemLinks)		
		SecurePostHook(PROVISIONER, "TogglePreviewMode", hhf.valLabelsToggle)	
		SecurePostHook(PROVISIONER, "OnTabFilterChanged", hhf.SetDefaultLabelData)
		hhfPreHooked = true
	end
end

----------------------
--Search Filter
----------------------
local function hhf_Searching(recipename, shhf, num)	 
	if string.find(recipename, shhf, 1, true) == nil then
		return false
	end	
	num = num + 1
	nSearchCount = num
	return true	
end

function hhf.FilterEntries()	
	hhfo.recipeTree:Reset()	
	nSearchCount = 0 --deprecated
	local foundsomething = false
	local sResultsLabel = "Search Results" 
	local shhf = textdata
	local craftingInteractionType = GetCraftingInteractionType()
	local recipeLists = PROVISIONER_MANAGER:GetRecipeListData(craftingInteractionType)		
	local parent
    local requireIngredients = ZO_CheckButton_IsChecked(hhfo.haveIngredientsCheckBox)
    local requireSkills = ZO_CheckButton_IsChecked(hhfo.haveSkillsCheckBox)
	

	local knowAnyRecipesInTab = false
    local hasRecipesWithFilter = false

	for _, recipeList in pairs(recipeLists) do
		for _,recipe in ipairs(recipeList.recipes) do	

			if recipe.requiredCraftingStationType == craftingInteractionType and hhfo.filterType == recipe.specialIngredientType then
				knowAnyRecipesInTab = true

				if shhf ~= nil and shhf ~= "" and shhf ~= " " then				
					if hhfo:DoesRecipePassFilter(recipe.specialIngredientType, requireIngredients, recipe.maxIterationsForIngredients, requireSkills, recipe.tradeskillsLevelReqs, recipe.qualityReq, craftingInteractionType, recipe.requiredCraftingStationType) 
					and hhf_Searching(recipe.name:lower(), shhf, nSearchCount) then						
						
						parent = parent or hhfo.recipeTree:AddNode("ZO_ProvisionerNavigationHeader", {  
						recipeListIndex = recipeList.recipeListIndex,
						name = sResultsLabel,
						upIcon = hhficon,
						downIcon = hhficon, 
						overIcon = hhficon,
						disabledIcon = hhficon
						}, nil, SOUNDS.PROVISIONING_BLADE_SELECTED)							
						hhfo.recipeTree:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent, SOUNDS.PROVISIONING_ENTRY_SELECTED)	
						hasRecipesWithFilter = true
					end			
				else 
					if hhfo:DoesRecipePassFilter(recipe.specialIngredientType, requireIngredients, recipe.maxIterationsForIngredients, requireSkills, recipe.tradeskillsLevelReqs, recipe.qualityReq, craftingInteractionType, recipe.requiredCraftingStationType) then
						
						parent = parent or hhfo.recipeTree:AddNode("ZO_ProvisionerNavigationHeader", {
						recipeListIndex = recipeList.recipeListIndex,
						name = recipeList.recipeListName,
						upIcon = recipeList.upIcon,
						downIcon = recipeList.downIcon,
						overIcon = recipeList.overIcon,
						disabledIcon = recipeList.disabledIcon
						}, nil, SOUNDS.PROVISIONING_BLADE_SELECTED)								
						hhfo.recipeTree:AddNode("ZO_ProvisionerNavigationEntry", recipe, parent, SOUNDS.PROVISIONING_ENTRY_SELECTED)		
						nSearchCount = nSearchCount + 1 --Deprecated but may use in future
						hasRecipesWithFilter = true
					end							
					hhfo:DirtyRecipeList() 
				end
			end
		end			
	end 
	
	--Toggles previewmode off to avoid an error due to un-secured data.
	hhf.ClearPreviewMode()
	
	hhfo.recipeTree:Commit() 
	
	--Deprecated
	--if nSearchCount > 0  then
		--foundsomething = true 		
	--end		
	
	foundsomething = hasRecipesWithFilter
	
	hhfo.noRecipesLabel:SetHidden(foundsomething)		
	if not foundsomething then				 
		hhf.SetValLabelsHidden(true)
		hhfo.noRecipesLabel:SetText("No matches found.")
		if not knowAnyRecipesInTab then 
            hhfo.noRecipesLabel:SetText(GetString(SI_PROVISIONER_NO_RECIPES))
		end
		hhfo:RefreshRecipeDetails()
	else 		
		hhf.SetValLabelsHidden(false)
		hhfo.recipeTree:SelectAnything()	
	end			
	

end

-----------------------------
-- Search function
-----------------------------
local function hhfupdatetext()
	
	ZO_EditDefaultText_OnTextChanged(HHFSearchField)			
	hhfSearchFieldText = HHFSearchField:GetText():lower()		
	textdata = hhfSearchFieldText 	
		--Compatibility mode for Favorite Furniture Crafter, disables favorites checking while text searching.
		if ffcCompatibilityMode then
			ZO_CheckButton_SetUnchecked(FavouriteFurnitureCrafter.FavouriteCheckBox)
		end
		
		zo_callLater(function () hhf.FilterEntries() end, hhf.SavedVars.hhfsearchdelay) 
		--Have to swap the refreshrecipelist function otherwise it resets search results after every craft.
		 if textdata ~= nil and textdata ~= "" and textdata ~= " " then			
			PROVISIONER.RefreshRecipeList = hhf.FilterEntries 
		else
			PROVISIONER.RefreshRecipeList = RestoreDefaultRefresh
		end				
end


-----------------------------
-- Create/position controls
-----------------------------
local function hhfSaveTooltipPos(self)
    hhf.SavedVars.PriceToolX = self:GetLeft()
    hhf.SavedVars.PriceToolY = self:GetTop()
	hhf.SavedVars.ChangedPricePosition = true
end

local function hhfSaveSearchPos(self)
    hhf.SavedVars.SearchToolX = self:GetLeft()
    hhf.SavedVars.SearchToolY = self:GetTop()
	hhf.SavedVars.ChangedSearchPosition = true
end


local function CreateSearchBox(parent)
	if not exists then		
		HHFSearchBox = wm:CreateControlFromVirtual("$(parent)HearthHomeFilter", parent, "ZO_InventorySearchTemplate") 
		HHFSearchBox:SetDimensions(195, 25)
		
		HHFSearchPin = wm:CreateControl("$(parent)HearthHomeFilterSearchMover", parent, CT_BUTTON)
		HHFSearchPin:SetNormalTexture(hhfpinicon3)
		HHFSearchPin:SetMouseOverTexture(hhfpinicon2)
		HHFSearchPin:SetPressedTexture(hhfpinicon1)
		HHFSearchPin:SetDimensions(40,40)
		
		HHFSearchBox:SetDrawLayer(1)
		HHFSearchBox:SetDrawLevel(1)
		HHFSearchBox:SetDrawTier(2)
		HHFSearchPin:SetDrawLayer(1)
		HHFSearchPin:SetDrawLevel(1)
		HHFSearchPin:SetDrawTier(2)
		
		exists = true		
	end	
	--Movability
	HHFSearchPin:SetMovable(true)
	HHFSearchPin:SetMouseEnabled(true)
	HHFSearchPin:SetClampedToScreen(true)	
	
	HHFSearchField = HHFSearchBox:GetNamedChild("Box")
	hhfSearchFieldText = HHFSearchField:GetNamedChild("Text")

	HHFSearchField:SetHandler("OnTextChanged", hhfupdatetext)	     	
end

local function CreateCloseButton(parent)
	if not buttonexists then
		HHFSearchClrB = wm:CreateControl("$(parent)HearthHomeFilterClearButton", parent, CT_BUTTON)	
		HHFSearchClrB:SetNormalTexture(hhfclricon1)
		HHFSearchClrB:SetMouseOverTexture(hhfclricon2)
		HHFSearchClrB:SetClickSound(clrsfx)
		HHFSearchClrB:SetDimensions(30,30)
		HHFSearchClrB:SetDrawLayer(1)
		HHFSearchClrB:SetDrawLevel(2)
		HHFSearchClrB:SetDrawTier(2)		
		buttonexists = true
	end
		HHFSearchClrB:SetHandler("OnClicked", hhf.srchbxclr)
end

local function CreateWritSearchButton(parent)
	if not writbuttonexists then
		HHFSearchWritB = wm:CreateControl("$(parent)HearthHomeFilterWritButton", parent, CT_BUTTON)	
		HHFSearchWritB:SetNormalTexture(hhfwriicon1)
		HHFSearchWritB:SetMouseOverTexture(hhfwriicon2)
		HHFSearchWritB:SetClickSound(clrsfx)
		HHFSearchWritB:SetDimensions(120, 45)
		HHFSearchWritB:SetDrawLayer(1)
		HHFSearchWritB:SetDrawLevel(1)
		HHFSearchWritB:SetDrawTier(2)
		HHFSearchWritB:SetFont(fontA)
		HHFSearchWritB:SetText("Find Writ")
		
		writbuttonexists = true
	end
		HHFSearchWritB:SetHandler("OnClicked", hhf.setFoodSearch)
end

local function CreatePriceLabels(parent)
	local LabelDimensionsy = 25
	local stringLabelDimensions = 140
	local valLabelDimensions = 105
	
	if not LabelsExist then				
		hhfBackdrop = wm:CreateControl("$(parent)HearthHomeFilterLabelContainer", parent, CT_CONTROL)			
		hhfBackdrop:SetDimensions(255,65)
		hhfBackdrop:SetDrawLayer(1)
		hhfBackdrop:SetDrawLevel(1)
		hhfBackdrop:SetDrawTier(2)
		--Customize Placement
		hhfBackdrop:SetMovable(true)
		hhfBackdrop:SetMouseEnabled(true)
		hhfBackdrop:SetClampedToScreen(true)
		
		HHFValueLabel = wm:CreateControl("$(parent)HearthHomeFilterValueLabel", hhfBackdrop, CT_LABEL)
		HHFValueLabel2 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel2", hhfBackdrop, CT_LABEL)
		HHFValueLabel3 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel3", hhfBackdrop, CT_LABEL)
		HHFValueLabel4 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel4", hhfBackdrop, CT_LABEL)
		HHFValueLabel5 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel5", hhfBackdrop, CT_LABEL) 
		HHFValueLabel6 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel6", hhfBackdrop, CT_LABEL)
		--TTC Extended Info 
			HHFValueLabel7 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel7", hhfBackdrop, CT_LABEL)
			HHFValueLabel8 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel8", hhfBackdrop, CT_LABEL) 
			HHFValueLabel9 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel9", hhfBackdrop, CT_LABEL)
			HHFValueLabel10 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel10", hhfBackdrop, CT_LABEL)
			HHFValueLabel11 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel11", hhfBackdrop, CT_LABEL) 
			HHFValueLabel12 = wm:CreateControl("$(parent)HearthHomeFilterValueLabel12", hhfBackdrop, CT_LABEL)
		--
		HHFValueLabel:SetDimensions(stringLabelDimensions, LabelDimensionsy)
		HHFValueLabel2:SetDimensions(stringLabelDimensions, LabelDimensionsy)		
		HHFValueLabel3:SetDimensions(valLabelDimensions, LabelDimensionsy)
		HHFValueLabel4:SetDimensions(valLabelDimensions, LabelDimensionsy)		
		HHFValueLabel5:SetDimensions(stringLabelDimensions, LabelDimensionsy)		
		HHFValueLabel6:SetDimensions(valLabelDimensions, LabelDimensionsy)
		--TTC Extended Info 
			HHFValueLabel7:SetDimensions(valLabelDimensions, LabelDimensionsy)		
			HHFValueLabel8:SetDimensions(stringLabelDimensions, LabelDimensionsy)		
			HHFValueLabel9:SetDimensions(valLabelDimensions, LabelDimensionsy)
			HHFValueLabel10:SetDimensions(valLabelDimensions, LabelDimensionsy)		
			HHFValueLabel11:SetDimensions(stringLabelDimensions, LabelDimensionsy)		
			HHFValueLabel12:SetDimensions(valLabelDimensions, LabelDimensionsy)
		--
		HHFValueLabel:SetDrawLayer(2)	
		HHFValueLabel2:SetDrawLayer(2)
		HHFValueLabel3:SetDrawLayer(2)	
		HHFValueLabel4:SetDrawLayer(2)	
		HHFValueLabel5:SetDrawLayer(2)
		HHFValueLabel6:SetDrawLayer(2)
		--TTC Extended Info 
			HHFValueLabel7:SetDrawLayer(2)	
			HHFValueLabel8:SetDrawLayer(2)
			HHFValueLabel9:SetDrawLayer(2)	
			HHFValueLabel10:SetDrawLayer(2)	
			HHFValueLabel11:SetDrawLayer(2)
			HHFValueLabel12:SetDrawLayer(2)	
		--
				
		hhfBackdropbg = wm:CreateControlFromVirtual("$(parent)HearthHomeFilterLabelBackground", hhfBackdrop, "ZO_DefaultBackdrop")
		hhfBackdropbg:SetDrawLayer(1)			
	LabelsExist = true
	end
	hhfBackdrop:SetHandler("OnMoveStop", hhfSaveTooltipPos)
end
-----------------------------
--Utilities
-----------------------------
function hhf.ClearPreviewMode()
	if SYSTEMS:GetObject("itemPreview"):IsInteractionCameraPreviewEnabled() then
		if IsCurrentlyPreviewing() then		
			hhfo:TogglePreviewMode()
		end
	end
end

function hhf.SelectRefresh()
	hhfo.recipeTree:Commit()
	hhfo:RefreshRecipeDetails()
	--Prevents a bug with the provisioning station having an empty list. 
	--hhfo:ResetSelectedTab()   --Alternative solution.
	hhfo:DirtyRecipeList()
end	

function hhf.GetCurrentIndices()
	return PROVISIONER:GetSelectedRecipeListIndex(), PROVISIONER:GetSelectedRecipeIndex()	
end

function hhf.srchbxclr()
	HHFSearchField:SetText("")
end

function hhf.GetConsumableTab()
	local isConsumable = false
	if hhfchecktabs then
		if hhfo.filterType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING then
			isConsumable = true
		end
	end
	return isConsumable
end
-----------------------------
--Label Display Utility Functions
-----------------------------
local function isTTCLoadedandToggled()
	local OptionsToggle = hhf.SavedVars.hhfuseTTC
		if not TTCLoaded then
			OptionsToggle = TTCLoaded
		end
	return OptionsToggle
end

local function arePriceOptionsLoadedandToggled()
	local anyOptionsToggled = false 	
		if hhf.SavedVars.hhfusecosts or hhf.SavedVars.hhfuseMA then
			anyOptionsToggled = true 
		end	
		if not havePriceAddon then
			anyOptionsToggled = havePriceAddon
		end	
	return anyOptionsToggled
end

function hhf.SetValLabelsHidden(bHideLabels)
	local controlboolean = bHideLabels
	local optionson = arePriceOptionsLoadedandToggled()
	local ttcon = isTTCLoadedandToggled()
	
	if not optionson and not ttcon then controlboolean = true end --Do not show if there's no data to show	
	
	HHFValueLabel:SetHidden(controlboolean)
	HHFValueLabel2:SetHidden(controlboolean) 
	HHFValueLabel3:SetHidden(controlboolean) 
	HHFValueLabel4:SetHidden(controlboolean) 
	HHFValueLabel5:SetHidden(controlboolean) 
	HHFValueLabel6:SetHidden(controlboolean)
	--TTC Extended
		HHFValueLabel7:SetHidden(controlboolean) 
		HHFValueLabel8:SetHidden(controlboolean) 
		HHFValueLabel9:SetHidden(controlboolean)	
		HHFValueLabel10:SetHidden(controlboolean) 
		HHFValueLabel11:SetHidden(controlboolean) 
		HHFValueLabel12:SetHidden(controlboolean)	
	--
	hhfBackdropbg:SetHidden(controlboolean)	
		
	areLabelsHidden = controlboolean	
end

local function LoadSavedPos(self)
	if self == hhfBackdrop then
		if hhf.SavedVars.ChangedPricePosition then
			self:ClearAnchors()
			self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hhf.SavedVars.PriceToolX, hhf.SavedVars.PriceToolY)
		end
	else
		if self == HHFSearchPin then
			if hhf.SavedVars.ChangedSearchPosition then
				self:ClearAnchors()
				self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, hhf.SavedVars.SearchToolX, hhf.SavedVars.SearchToolY)
			end
		end
	end
end

function hhf.SetDefaultLabelData()
	--Positioning
	hhfBackdrop:ClearAnchors()
	--hhfBackdrop:SetAnchor(TOP, hhfresultTooltip, BOTTOM, 0, 10)	
	hhfBackdrop:SetAnchor(BOTTOM, hhfresultTooltip, TOP, 0, -60)
	if pixCompat then
		hhfBackdrop:ClearAnchors()
		hhfBackdrop:SetAnchor(BOTTOM, ZO_ProvisionerTopLevelTooltip, TOP, 0, -40)		
	end
	LoadSavedPos(hhfBackdrop)
	
	--Font
	HHFValueLabel:SetFont(fontB)
	HHFValueLabel2:SetFont(fontB)
	HHFValueLabel3:SetFont(fontB)
	HHFValueLabel4:SetFont(fontB)	
	HHFValueLabel5:SetFont(fontB)
	HHFValueLabel6:SetFont(fontB)
	--TTC Extended
		HHFValueLabel7:SetFont(fontB)	
		HHFValueLabel8:SetFont(fontS)
		HHFValueLabel9:SetFont(fontS)
		HHFValueLabel10:SetFont(fontB)	
		HHFValueLabel11:SetFont(fontS)
		HHFValueLabel12:SetFont(fontS)
	--Color and Text
	HHFValueLabel3:SetColor(0.4, 0.4, 0.4, 1)
	HHFValueLabel4:SetColor(0.4, 0.4, 0.4, 1)
	HHFValueLabel6:SetColor(0.4, 0.4, 0.4, 1)
	sMarketAverage = "No data"
	sCraftCosts = "No data"
	sSuggestCosts = "No data"
	sTTCAvg = "No data"
	sTTCMin = "No data"
	sTTCCount = "No data"
	HHFValueLabel:SetText("Market Average")
	HHFValueLabel3:SetText(sMarketAverage)
	HHFValueLabel2:SetText("Value of Materials")
	HHFValueLabel4:SetText(sCraftCosts)	
	HHFValueLabel5:SetText("TTC Suggests")
	HHFValueLabel6:SetText(sSuggestCosts)	
	--TTC Extended
		HHFValueLabel7:SetText("TTC Avg")	
		HHFValueLabel10:SetText(sTTCAvg)
		HHFValueLabel8:SetText("(TTC Min:")
		HHFValueLabel11:SetText(sTTCMin)
		HHFValueLabel9:SetText("Listings:")	
		HHFValueLabel12:SetText(sTTCCount .. ")")
	--
	hhf.ApplyPriceSettings()	
	--If theres no data to show, probably shouldn't display the tooltip at all
	--Since a toggle for label displaying has been prehooked into the previewmode function, if the label is going to stay hidden after tab-change while preview is enabled we'll need to call the toggle here.
	hhf.ClearPreviewMode()
	hhf.SetValLabelsHidden(true)
end

function hhf.valLabelsToggle()
	if areLabelsHidden then
		areLabelsHidden = false
	else 
		areLabelsHidden = true
	end		
	hhf.SetValLabelsHidden(areLabelsHidden)	
end

--Moves things around based on options toggles
function hhf.ApplyPriceSettings()
	local controlx = 265
	local controlSizeOne = 45
	local controlSizeTwo = 65
	local controlSizeThree = 85
	local controlSizeExt = 120
	local controlSizeExt2 = 100
	
	local optionsToggled = arePriceOptionsLoadedandToggled()
	local TTCtoggled = isTTCLoadedandToggled()
	HHFValueLabel5:SetAnchor(TOPLEFT, hhfBackdrop, TOPLEFT, 5, 10)
	HHFValueLabel6:SetAnchor(LEFT, HHFValueLabel5, RIGHT, 20, 0)
	if not TTCtoggled then
		HHFValueLabel5:SetText("")	
		HHFValueLabel6:SetText("")
		HHFValueLabel7:SetText("")	
		HHFValueLabel8:SetText("")
		HHFValueLabel9:SetText("")	
		HHFValueLabel10:SetText("")
		HHFValueLabel11:SetText("")	
		HHFValueLabel12:SetText("")
	end

	if (hhf.SavedVars.hhfuseMA and hhf.SavedVars.hhfusecosts) and havePriceAddon then
		hhfBackdrop:SetDimensions(controlx, controlSizeTwo)
		HHFValueLabel:SetAnchor(TOPLEFT, hhfBackdrop, TOPLEFT, 5, 10)
		HHFValueLabel2:SetAnchor(TOPLEFT, HHFValueLabel, TOPLEFT, 0, 20)	
		HHFValueLabel3:SetAnchor(LEFT, HHFValueLabel, RIGHT, 20, 0)
		HHFValueLabel4:SetAnchor(TOPLEFT, HHFValueLabel3, TOPLEFT, 0, 20)
		if TTCtoggled then
			--HHFValueLabel:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT, 0, 20)
			HHFValueLabel:SetAnchor(TOPLEFT, HHFValueLabel7, TOPLEFT, 0, 20)
			HHFValueLabel2:SetAnchor(TOPLEFT, HHFValueLabel, TOPLEFT, 0, 20)	
			HHFValueLabel3:SetAnchor(LEFT, HHFValueLabel, RIGHT, 20, 0)
			HHFValueLabel4:SetAnchor(TOPLEFT, HHFValueLabel3, TOPLEFT, 0, 20)
			--TTC Extended
				HHFValueLabel7:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT,0, 20)
				HHFValueLabel8:SetAnchor(TOPLEFT, HHFValueLabel2, TOPLEFT,0, 30)
				HHFValueLabel9:SetAnchor(LEFT, HHFValueLabel11, CENTER,0, 0)
				HHFValueLabel10:SetAnchor(TOPLEFT, HHFValueLabel6, TOPLEFT,0, 20)
				HHFValueLabel11:SetAnchor(LEFT, HHFValueLabel8, CENTER,0, 0)
				HHFValueLabel12:SetAnchor(LEFT, HHFValueLabel9, CENTER,0, 0)		
			--
			--hhfBackdrop:SetDimensions(controlx, controlSizeThree)		
			hhfBackdrop:SetDimensions(controlx, controlSizeExt)	
		end
	else
		if not optionsToggled then
			if TTCtoggled then
				HHFValueLabel:SetText("")	
				HHFValueLabel2:SetText("")
				HHFValueLabel3:SetText("")	
				HHFValueLabel4:SetText("")
				--TTC Extended
					HHFValueLabel7:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT,0, 20)
					HHFValueLabel8:SetAnchor(TOPLEFT, HHFValueLabel7, TOPLEFT,0, 30)
					HHFValueLabel9:SetAnchor(LEFT, HHFValueLabel11, CENTER,0, 0)
					HHFValueLabel10:SetAnchor(TOPLEFT, HHFValueLabel6, TOPLEFT,0, 20)
					HHFValueLabel11:SetAnchor(LEFT, HHFValueLabel8, CENTER,0, 0)
					HHFValueLabel12:SetAnchor(LEFT, HHFValueLabel9, CENTER,0, 0)
				--	
				hhfBackdrop:SetDimensions(controlx, controlSizeThree)
			end
		else		
			if not hhf.SavedVars.hhfuseMA then
				HHFValueLabel:SetText("")
				HHFValueLabel3:SetText("")		
				HHFValueLabel2:SetAnchor(TOPLEFT, hhfBackdrop, TOPLEFT, 5, 10)
				HHFValueLabel4:SetAnchor(LEFT, HHFValueLabel2, RIGHT, 20, 0)
				hhfBackdrop:SetDimensions(controlx, controlSizeOne)
				if TTCtoggled then			
					--HHFValueLabel2:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT, 0, 20)			
					HHFValueLabel2:SetAnchor(TOPLEFT, HHFValueLabel7, TOPLEFT, 0, 20)	
					--HHFValueLabel4:SetAnchor(TOPLEFT, HHFValueLabel6, TOPLEFT, 0, 20)
					HHFValueLabel4:SetAnchor(TOPLEFT, HHFValueLabel10, TOPLEFT, 0, 20)
				--TTC Extended
					HHFValueLabel7:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT,0, 20)
					HHFValueLabel8:SetAnchor(TOPLEFT, HHFValueLabel2, TOPLEFT,0, 30)
					HHFValueLabel9:SetAnchor(LEFT, HHFValueLabel11, CENTER,0, 0)
					HHFValueLabel10:SetAnchor(TOPLEFT, HHFValueLabel6, TOPLEFT,0, 20)
					HHFValueLabel11:SetAnchor(LEFT, HHFValueLabel8, CENTER,0, 0)
					HHFValueLabel12:SetAnchor(LEFT, HHFValueLabel9, CENTER,0, 0)			
				--
					--hhfBackdrop:SetDimensions(controlx, controlSizeTwo)
					hhfBackdrop:SetDimensions(controlx, controlSizeExt2)
				end
			end
			if not hhf.SavedVars.hhfusecosts then
				HHFValueLabel2:SetText("")
				HHFValueLabel4:SetText("")
				HHFValueLabel:SetAnchor(TOPLEFT, hhfBackdrop, TOPLEFT, 5, 10)
				HHFValueLabel3:SetAnchor(LEFT, HHFValueLabel, RIGHT, 20, 0)
				hhfBackdrop:SetDimensions(controlx, controlSizeOne)
				if TTCtoggled then
					--HHFValueLabel:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT, 0, 20)
					HHFValueLabel:SetAnchor(TOPLEFT, HHFValueLabel7, TOPLEFT, 0, 20)				
					HHFValueLabel3:SetAnchor(TOPLEFT, HHFValueLabel10, TOPLEFT, 0, 20)	
				--TTC Extended
					HHFValueLabel7:SetAnchor(TOPLEFT, HHFValueLabel5, TOPLEFT,0, 20)
					HHFValueLabel8:SetAnchor(TOPLEFT, HHFValueLabel, TOPLEFT,0, 30)
					HHFValueLabel9:SetAnchor(LEFT, HHFValueLabel11, CENTER,0, 0)
					HHFValueLabel10:SetAnchor(TOPLEFT, HHFValueLabel6, TOPLEFT,0, 20)
					HHFValueLabel11:SetAnchor(LEFT, HHFValueLabel8, CENTER,0, 0)
					HHFValueLabel12:SetAnchor(LEFT, HHFValueLabel9, CENTER,0, 0)
				--			
					--hhfBackdrop:SetDimensions(controlx, controlSizeTwo)
					hhfBackdrop:SetDimensions(controlx, controlSizeExt2)
				end
			end
		end
	end		
end
-----------------------------
--Compatibility Utility
-----------------------------
function hhf.SetPixUIAnchor(station)
	local where = station
		if where ~= CRAFTING_TYPE_PROVISIONING then		
			HHFSearchPin:ClearAnchors()
			HHFSearchPin:SetAnchor(TOPLEFT, HHFST2, TOPLEFT, pincontrolx, offsety3)
		else		
			HHFSearchPin:ClearAnchors()
			HHFSearchPin:SetAnchor(TOPLEFT, HHFST2, TOPLEFT, pincontrolx, offsety3)
		end
end
-----------------------------
--Writ Functions-------------
-----------------------------
function hhf.trimProvQstStr(hhfqueststring)
	local hhfRecipeString
		hhfRecipeString = string.gsub(hhfqueststring, "Craft ", "")
		hhfRecipeString = string.gsub(hhfRecipeString, ":.*", "")
	return hhfRecipeString
end

function SetWritButtonHidden(station)
	if station ~= CRAFTING_TYPE_PROVISIONING then return true end
	if hhf.SavedVars.wrbenable == false then return true end

	local quindex
	for quindex=1,25 do
		local questname = GetJournalQuestName(quindex)
		if not questname or questname == "" then 
			return true
		end
		if questname == "Provisioner Writ" then
			return false
		end	
	end		
end

local function GetWritTasks()
	local quindex, stepindex
	local hhffoodstring = ""
	local hhfdrinkstring = ""
	for quindex=1,25 do
		local questname = GetJournalQuestName(quindex)
		if not questname or questname == "" then return end
		if questname == "Provisioner Writ" then
			local stepindex = 1 
			local conditionIndex 
			for conditionIndex=1, GetJournalQuestNumConditions(quindex, stepindex) do
				local hhfWritString = GetJournalQuestConditionInfo(quindex, stepindex, conditionIndex)
				hhfresultstring = hhf.trimProvQstStr(hhfWritString)
				if hhfresultstring ~= "" and hhfresultstring ~= nil then 
					if string.find(hhffoodlist, hhfresultstring, 1, true) ~= nil then  
						hhffoodstring = hhfresultstring
					else
						if string.find(hhfdrinklist, hhfresultstring, 1, true) ~= nil then
							hhfdrinkstring = hhfresultstring
						end
					end		
				end	
			end
			return hhffoodstring, hhfdrinkstring
		end
	end
end

function hhf.RetrieveWritStrings()
	local sFood, sDrink = GetWritTasks()
		if sFood == nil then
			sFood = ""
		end
		if sDrink == nil then
			sDrink = ""
		end
	return sFood, sDrink
end

function hhf.setFoodSearch()
	local boxstrFood, boxstrDrink = hhf.RetrieveWritStrings()
	if not hhf.GetConsumableTab() then
		return
	else
		if hhfo.filterType == foodtab then 
			HHFSearchField:SetText(boxstrFood)
		end
		if hhfo.filterType == drinktab then 
			HHFSearchField:SetText(boxstrDrink)
		end
	end
end

-----------------------------

function hhf:Setup(station)	
	CreateSearchBox(HHFST)
	CreateCloseButton(HHFST)
	CreatePriceLabels(HHFST)
	CreateWritSearchButton(HHFST)
	

	HHFSearchBox:ClearAnchors()
	HHFSearchPin:ClearAnchors()

	HHFSearchPin:SetAnchor(TOPLEFT, HHFST2, TOPLEFT, pincontrolx, offsety2)
		
	HHFSearchBox:SetAnchor(TOPRIGHT, HHFSearchPin, TOPLEFT, -3, 0)
	-------------
	HHFSearchBox:SetHidden(false)
	HHFSearchClrB:SetAnchor(TOPLEFT, HHFSearchBox, TOPLEFT, 175, 6)	

	HHFSearchWritB:SetAnchor(RIGHT, HHFSearchBox, LEFT, -5, 10)
	HHFSearchWritB:SetHidden(SetWritButtonHidden(station))
	--Compatibility
	if pixCompat then
		hhf.SetPixUIAnchor(station)
	end					
	--Movability
	HHFSearchPin:SetHandler("OnMoveStop", hhfSaveSearchPos)
	LoadSavedPos(HHFSearchPin)
	-------------
	hhf.SetDefaultLabelData()
				
	--Makes sure the last open listing is re-selected and refreshed, this reloads the tooltip display if it gets lost somehow.
	hhf.SelectRefresh()
	
	--hhfSearchFieldText:SetTex("Enter Search Term")
	HHFSearchField:SetDefaultText("Enter Search Term")		

end
	
function hhf.Init(event, station)	
	if station == CRAFTING_TYPE_INVALID then 	
			--d("HHF: Invalid crafting station")		
		return
	end
	if station ~= CRAFTING_TYPE_PROVISIONING then 
			hhf:Setup(station)
			hhf.GetSelectionInformation(station)				
	else			
			hhf:Setup(station)			
			hhf.GetSelectionInformation(station)
	end
end



----------------------------------
--Housing Population Functions----
--Node: Potentially Deprecated----
----This only remains on off -----
----chance anyone still uses it.--
----------------------------------

local function hhfding(event)	
	if hhf.SavedVars.hhfdoorbelltoggle == false then return end	
	nGuests = GetCurrentHousePopulation()
	nGuestLimit = GetCurrentHousePopulationCap()
	sHouseName = GetCollectibleName(GetCollectibleIdForHouse(GetCurrentZoneHouseId()))	
	if nGuests == nil then return	
	else
		if nGuests > 1 then		
			if nGuests > nPrevGuests then	
				d(string.format("|cd1c98eA new guest has arrived! |cFFFFFF" .. sHouseName .. "|cd1c98e is hosting |c00FF00"..nGuests.."|cd1c98e out of |cFF0000" ..nGuestLimit.. "|cd1c98e inhabitants."))
			else
				if nGuests < nPrevGuests then 
					d(string.format("|cd1c98eA guest has left! |cFFFFFF" .. sHouseName .. "|cd1c98e is hosting |c00FF00"..nGuests.."|cd1c98e out of |cFF0000" ..nGuestLimit.. "|cd1c98e inhabitants."))
				end
			end
		else 
			if nGuests > nPrevGuests then 
				if nGuests == 1 then					
					d(string.format("|cd1c98eYou are the only one present, out of |cFF0000" ..nGuestLimit.. "|cd1c98e.")) 				
				end
			else
				if nGuests == 0 then return 
				else 
					d(string.format("|cd1c98eA guest has left! You are the only one present in |cFFFFFF" .. sHouseName .. "|cd1c98e, out of |cFF0000" ..nGuestLimit.. "|cd1c98e."))
				end
			end
		end
	end
	nPrevGuests = nGuests	
end

local function hhfresetpop(event) 
	nPrevGuests = 0
	nHouseID = GetCollectibleIdForHouse(GetCurrentZoneHouseId())
	sHouseName = GetCollectibleName(nHouseID)	
if hhf.SavedVars.hhftogglewelcome == false then return end
	
	if nHouseID == nil or nHouseID == 0 then 
		return 
	else
		d(string.format("|cd1c98eWelcome to |cFFFFFF" .. sHouseName .. ". |cd1c98eThe owner of this property is |cFFFFFF" .. GetCurrentHouseOwner() .. "."))		
		hhfding()
	end 
end

local function hhfcheckguests() 
	sHouseName = GetCollectibleName(GetCollectibleIdForHouse(GetCurrentZoneHouseId()))
	if sHouseName == nil or sHouseName == "" then 
		d(string.format("|cd1c98eCan't find house name or not in a valid house."))
		return 
	end 
	if GetCurrentHousePopulation() > 1 then 
		d(string.format("|cFFFFFF" .. sHouseName .. "|cd1c98e is currently hosting |c00FF00"..GetCurrentHousePopulation().."|cd1c98e out of |cFF0000" ..GetCurrentHousePopulationCap().. "|cd1c98e inhabitants!"))
	else 
		d(string.format("|cd1c98eYou are the only one present in |cFFFFFF" .. sHouseName .. "|cd1c98e, out of |cFF0000" ..GetCurrentHousePopulationCap().. "|cd1c98e."))
	end 
end

SLASH_COMMANDS["/guests"] = hhfcheckguests 

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

function hhf.OnAddOnLoaded(event, addonName)	
		
	if addonName == "HearthHomeFilter" then 	
		hhf.SavedVars = ZO_SavedVars:NewAccountWide("HearthHomeFilterVars", hhf.VarsVersion, nil, hhf.DefaultVars)
----------------------------------------------------------------------------------------------------------------------------------------------------------	
--Compatibility modes-------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------
		if FavouriteFurnitureCrafter then
			RestoreDefaultRefresh = FavouriteFurnitureCrafter.RefreshRecipeList
			ffcCompatibilityMode = true				
		end 
		if PerfectPixel then
			pixCompat = true
		end				

		if ArkadiusTradeTools then
			ATTLoaded = true				
		end
		if MasterMerchant then
			MasterMerchantLoaded = true			
		end				
		if TamrielTradeCentre then			
			TTCLoaded = true
		else
			sTTAddonText = string.format("|cFF0000 If you wish to use this feature, please load Tamriel Trade Centre.")
		end		
		if ATTLoaded or MasterMerchantLoaded then
			havePriceAddon = true
			sPriceAddonText = ""
		else
			sPriceAddonText = string.format("|cFF0000 If you wish to use this feature, please load Arkadius Trade Tools or Master Merchant.")
		end
----------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------		
----------------------------------------------------------------------------------------------------------------------------------------------------------	
		hhf.CreateSettingsWindow()	
		
		
		EVENT_MANAGER:RegisterForEvent("HearthHomeFilter", EVENT_CRAFTING_STATION_INTERACT, hhf.Init)
		EVENT_MANAGER:RegisterForEvent("HearthHomeFilter", EVENT_END_CRAFTING_STATION_INTERACT, hhf.endStationSession)
		EVENT_MANAGER:RegisterForEvent("HearthHomeFilter", EVENT_PLAYER_ACTIVATED, hhfresetpop) 
		EVENT_MANAGER:RegisterForEvent("HearthHomeFilter", EVENT_HOUSING_POPULATION_CHANGED, hhfding)
		
	end

	
end

function hhf.clr()
	if hhf.SavedVars.hhfclronextog == false then return end	
	hhf.srchbxclr()
end

function hhf.endStationSession(event, station)	
	if station == CRAFTING_TYPE_INVALID then return end
	hhf.ClearPreviewMode()
	hhf.SetValLabelsHidden(true)	
	hhf.clr()
end

EVENT_MANAGER:RegisterForEvent("HearthHomeFilter", EVENT_ADD_ON_LOADED, hhf.OnAddOnLoaded)











