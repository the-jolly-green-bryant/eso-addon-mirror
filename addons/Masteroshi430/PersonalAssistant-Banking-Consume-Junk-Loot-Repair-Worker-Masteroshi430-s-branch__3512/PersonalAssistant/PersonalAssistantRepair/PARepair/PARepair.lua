-- Local instances of Global tables --
local PA = PersonalAssistant
local PAR = PA.Repair
local PAHF = PA.HelperFunctions
local PARProfileManager = PA.ProfileManager.PARepair

-- ---------------------------------------------------------------------------------------------------------------------
PAR.SiegeWeapons = {}
PAR.SiegeWeapons[ALLIANCE_ALDMERI_DOMINION] =
	{
		[1] = { settingName = "KeepRecallStone", itemId = 141731, gold = false, AP = 20000,},
		[2] = { settingName = "FlamingOil", itemId = 30359, gold = false, AP = 800,}, 
		[3] = { settingName = "ForwardCamp", itemId = 29533, gold = false, AP = 20000,}, 
		[4] = { settingName = "Ballista", itemId = 36567, gold = false, AP = 1800,}, 
		[5] = { settingName = "FireBallista", itemId = 27970, gold = 450, AP = 1200,}, 
		[6] = { settingName = "LightningBallista", itemId = 27973, gold = false, AP = 1200,},
		[7] = { settingName = "MeatbagCatapult", itemId = 27964, gold = false, AP = 1200,},		
		[8] = { settingName = "OilCatapult", itemId = 27967, gold = false, AP = 1200,},		
		[9] = { settingName = "ScattershotCatapult", itemId = 44770, gold = false, AP = 1200,},			
		[10] = { settingName = "FirepotTrebuchet", itemId = 27105, gold = 450, AP = 1800,},		
		[11] = { settingName = "IceballTrebuchet", itemId = 44768, gold = false, AP = 1800,},			
		[12] = { settingName = "StoneTrebuchet", itemId = 44769, gold = false, AP = 1800,},		
		[13] = { settingName = "BatteringRam", itemId = 27136, gold = false, AP = 1800,},
    [14] = { settingName = "TriPots", itemId = 217946, gold = false, AP = 900,},
    [15] = { settingName = "SigilOfImperialRetreat", itemId = 68347, gold = false, AP = 10000,},
	} 
PAR.SiegeWeapons[ALLIANCE_DAGGERFALL_COVENANT] =
	{
		[1] = { settingName = "KeepRecallStone", itemId = 141731, gold = false, AP = 20000,},
		[2] = { settingName = "FlamingOil", itemId = 30359, gold = false, AP = 800,}, 
    [3] = { settingName = "ForwardCamp", itemId = 29535, gold = false, AP = 20000,},
		[4] = { settingName = "Ballista", itemId = 36569, gold = false, AP = 1800,}, 
		[5] = { settingName = "FireBallista", itemId = 27972, gold = 450, AP = 1200,}, 
		[6] = { settingName = "LightningBallista", itemId = 27975, gold = false, AP = 1200,},
		[7] = { settingName = "MeatbagCatapult", itemId = 27966, gold = false, AP = 1200,},		
		[8] = { settingName = "OilCatapult", itemId = 27969, gold = false, AP = 1200,},		
		[9] = { settingName = "ScattershotCatapult", itemId = 44773, gold = false, AP = 1200,},			
		[10] = { settingName = "FirepotTrebuchet", itemId = 27115, gold = 450, AP = 1800,},		
		[11] = { settingName = "IceballTrebuchet", itemId = 44771, gold = false, AP = 1800,},			
		[12] = { settingName = "StoneTrebuchet", itemId = 44772, gold = false, AP = 1800,},		
		[13] = { settingName = "BatteringRam", itemId = 27835, gold = false, AP = 1800,},
    [14] = { settingName = "TriPots", itemId = 217946, gold = false, AP = 900,},
    [15] = { settingName = "SigilOfImperialRetreat", itemId = 68347, gold = false, AP = 10000,},
	} 
PAR.SiegeWeapons[ALLIANCE_EBONHEART_PACT] =
	{
		[1] = { settingName = "KeepRecallStone", itemId = 141731, gold = false, AP = 20000,},
		[2] = { settingName = "FlamingOil", itemId = 30359, gold = false, AP = 800,}, 
    [3] = { settingName = "ForwardCamp", itemId = 29534, gold = false, AP = 20000,},
		[4] = { settingName = "Ballista", itemId = 36568, gold = false, AP = 1800,}, 
		[5] = { settingName = "FireBallista", itemId = 27971, gold = 450, AP = 1200,}, 
		[6] = { settingName = "LightningBallista", itemId = 27974, gold = false, AP = 1200,},
		[7] = { settingName = "MeatbagCatapult", itemId = 27965, gold = false, AP = 1200,},		
		[8] = { settingName = "OilCatapult", itemId = 27968, gold = false, AP = 1200,},		
		[9] = { settingName = "ScattershotCatapult", itemId = 44777, gold = false, AP = 1200,},			
		[10] = { settingName = "FirepotTrebuchet", itemId = 27114, gold = 450, AP = 1800,},		
		[11] = { settingName = "IceballTrebuchet", itemId = 44775, gold = false, AP = 1800,},			
		[12] = { settingName = "StoneTrebuchet", itemId = 44776, gold = false, AP = 1800,},		
		[13] = { settingName = "BatteringRam", itemId = 27850, gold = false, AP = 1800,},
    [14] = { settingName = "TriPots", itemId = 217946, gold = false, AP = 900,},
    [15] = { settingName = "SigilOfImperialRetreat", itemId = 68347, gold = false, AP = 10000,}, 
	} 
 
-- ---------------------------------------------------------------------------------------------------------------------

local _repairItemList

-- a comparator that returns all items that have durability, and that durability is below the provided threshold
local function _getItemHasDurabilityBelowThresholdComparator(threshold)
    return function(itemData)
        local bagId = itemData.bagId
        local slotIndex = itemData.slotIndex
        -- does item have durability?
        if DoesItemHaveDurability(bagId, slotIndex) then
            local itemCondition = GetItemCondition(bagId, slotIndex)
            -- is item durability below threshold?
            if itemCondition <= threshold then
                return true
            end
        end
        return false
    end
end

-- repair all items that are below the given threshold for the bag
local function _repairItems(bagId, threshold)
    local durabilityAndThresholdComparator = _getItemHasDurabilityBelowThresholdComparator(threshold)
    local bagCache = SHARED_INVENTORY:GenerateFullSlotData(durabilityAndThresholdComparator, bagId)

    if bagCache then
        local repairCost = 0
        local repairedItemCount = 0
        local notRepairedItemCount = 0
        local notRepairedItemsCost = 0
        local currentMoney = GetCurrentMoney()
        _repairItemList = {}

        -- loop through all items of the corresponding bagId
        for _, itemData in ipairs(bagCache) do
            local slotIndex = itemData.slotIndex
            -- [DoesItemHaveDurability] and ItemCondition check are not necessary anymore (already done by comparator)
            -- get the repair cost for that item and repair if possible
            local itemRepairCost = GetItemRepairCost(bagId, slotIndex)
            if itemRepairCost > 0 then
                local itemCondition = GetItemCondition(bagId, slotIndex)
                local stackSize = GetSlotStackSize(bagId, slotIndex)
                if itemRepairCost > currentMoney then
                    -- even though not enough money available, continue as maybe a cheaper item still can be repaired
                    notRepairedItemCount = notRepairedItemCount + stackSize
                    notRepairedItemsCost = notRepairedItemsCost + itemRepairCost
                    -- add the item to the list as NOT repaired
                    table.insert(_repairItemList, {
                        itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS),
                        repairCost = itemRepairCost,
                        itemCondition = itemCondition,
                        repaired = false
                    })
                else
                    -- sum up the total repair costs
                    repairCost = repairCost + itemRepairCost;
                    repairedItemCount = repairedItemCount + stackSize
                    RepairItem(bagId, slotIndex)
                    -- currentMoney has to be manually calculated, as the "GetCurrentMoney()"
                    -- does not yet reflect the just made repairs
                    currentMoney = currentMoney - itemRepairCost
                    -- add the item to the list as repaired
                    table.insert(_repairItemList, {
                        itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS),
                        repairCost = itemRepairCost,
                        itemCondition = itemCondition,
                        repaired = true
                    })
                end
            end
        end

        -- show output to chat
        local repairCostFmt = PAHF.getFormattedCurrency(repairCost * -1) -- to be converted to a negative amount
        if notRepairedItemCount > 0 then
            local missingGold = notRepairedItemsCost - currentMoney
            local missingGoldFmt = PAHF.getFormattedCurrency(missingGold, CURT_MONEY, true)
            if bagId == BAG_BACKPACK then
                PAR.println(SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_PARTIAL, repairCostFmt, missingGoldFmt)
            else
                PAR.println(SI_PA_CHAT_REPAIR_SUMMARY_PARTIAL, repairCostFmt, missingGoldFmt)
            end
        elseif repairedItemCount > 0 then
            if bagId == BAG_BACKPACK then
                PAR.println(SI_PA_CHAT_REPAIR_SUMMARY_INVENTORY_FULL, repairCostFmt)
            else
                PAR.println(SI_PA_CHAT_REPAIR_SUMMARY_FULL, repairCostFmt)
            end
        end
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

local function _buyItem(itemId, amount, currency, currencyTwo)
        for i = 1, GetNumStoreItems() do
            local itemLink = GetStoreItemLink(i,LINK_STYLE_BRACKETS)
			if itemLink and itemLink ~= "" then
			   local storeItemId = GetItemLinkItemId(itemLink)
			   local _,_,_, price,_,meetsRequirementsToBuy,meetsRequirementsToUse,_,_,itemCurrency, itemCurrencyAmount = GetStoreEntryInfo(i)
			   local recalculatedAmount = 0
			   if storeItemId == itemId and (itemCurrency == currency or (currency == CURT_MONEY and price > 0)) and meetsRequirementsToBuy and meetsRequirementsToUse then
			      local max = GetStoreEntryMaxBuyable(i)
				  recalculatedAmount = amount
			      if max < recalculatedAmount then
				      recalculatedAmount = max
				  end
				  
				  local currentCurrency = GetCurrencyAmount(currency, CURRENCY_LOCATION_CHARACTER) 
				  
				  if price > 0 and itemCurrencyAmount == 0 then
                      itemCurrencyAmount = price
                  end				  
				  
				  if currentCurrency < itemCurrencyAmount then
				      PAR.println(SI_PA_CHAT_BUY_SUMMARY_MISSING, itemLink, PAHF.getFormattedCurrency(itemCurrencyAmount, currency, true), PAHF.getFormattedCurrency(itemCurrencyAmount - currentCurrency, currency, true))
					  if currencyTwo then
					      _buyItem(itemId, amount, currencyTwo)
					  end
				      return
				  elseif currentCurrency < itemCurrencyAmount * recalculatedAmount then
				      while currentCurrency < itemCurrencyAmount * recalculatedAmount do
					      recalculatedAmount = recalculatedAmount - 1 
					  end
				  end
				  
			      BuyStoreItem(i, recalculatedAmount)
				  PAR.println(SI_PA_CHAT_BUY_SUMMARY_BOUGHT, recalculatedAmount, itemLink, PAHF.getFormattedCurrency(itemCurrencyAmount * recalculatedAmount, currency, true))
			   end
			end   
        end
end

local function _countInventoryItem(itemId)
    local itemIdComparator = PAHF.getItemIdComparator({[itemId] = true}, true)
    local itemBagCache = SHARED_INVENTORY:GenerateFullSlotData(itemIdComparator, BAG_BACKPACK)

    local totalItemsCount = 0
    for _, data in pairs(itemBagCache) do
            totalItemsCount = totalItemsCount + data.stackCount
    end

    return totalItemsCount
end

local function _buyEquipmentRepairKits()
    local PARepairSavedVars = PAR.SavedVars
    local _, amountInInventory = PAR._getRepairKitsIn(BAG_BACKPACK)
	local threshold = PARepairSavedVars.AutoBuyRepairKits.buyEquipmentRepairKitsThreshold
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	    _buyItem(44879, toBuy, CURT_MONEY)
	end
end

local function _buyCyrodiilRepairKits() 
  local PARepairSavedVars = PAR.SavedVars
  local amountInInventory = _countInventoryItem(204483)
	local threshold = PARepairSavedVars.AutoBuyRepairKits.buyCyrodiilRepairKitsThreshold
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	   local priority = PARepairSavedVars.AutoBuyRepairKits.buyCyrodiilRepairKitsPriority
	   if priority == "AP->GOLD" then
	      _buyItem(204483, toBuy, CURT_ALLIANCE_POINTS, CURT_MONEY)
	   elseif priority == "GOLD->AP" then
	      _buyItem(204483, toBuy, CURT_MONEY, CURT_ALLIANCE_POINTS)
	   elseif priority == "AP" then
	       _buyItem(204483, toBuy, CURT_ALLIANCE_POINTS)
	   elseif priority == "GOLD" then
	       _buyItem(204483, toBuy, CURT_MONEY)
	   end
	   
	end
end

local function _buyFullSoulGems()
  local PARepairSavedVars = PAR.SavedVars
  local amountInInventory = _countInventoryItem(33271)
	local threshold = PARepairSavedVars.AutoBuySoulGems.buyFullSoulGemsThreshold
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	     if IsPlayerInAvAWorld() then
	         _buyItem(33271, toBuy, CURT_ALLIANCE_POINTS) -- PvP Siege merchant
		else
		     _buyItem(33271, toBuy, CURT_MONEY) -- PvE Mystic
		end
	end
end

local function _buyEmptySoulGems()
    local PARepairSavedVars = PAR.SavedVars
    local amountInInventory = _countInventoryItem(33265)
	local threshold = PARepairSavedVars.AutoBuySoulGems.buyEmptySoulGemsThreshold
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	    _buyItem(33265, toBuy, CURT_MONEY)
	end
end

local function _buyLockpicks()
    local PARepairSavedVars = PAR.SavedVars
    local amountInInventory = _countInventoryItem(30357)
	local threshold = PARepairSavedVars.AutoBuySoulGems.buyLockpicksThreshold
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	    _buyItem(30357, toBuy, CURT_MONEY)
	end
end

local function _buySiegeItems(itemId, threshold, priority)
    local amountInInventory = _countInventoryItem(itemId)
	local toBuy = threshold - amountInInventory
	
	if toBuy > 0 then
	   if priority == "AP->GOLD" then
	      _buyItem(itemId, toBuy, CURT_ALLIANCE_POINTS, CURT_MONEY)
	   elseif priority == "GOLD->AP" then
	      _buyItem(itemId, toBuy, CURT_MONEY, CURT_ALLIANCE_POINTS)
	   elseif priority == "AP" then
	       _buyItem(itemId, toBuy, CURT_ALLIANCE_POINTS)
	   elseif priority == "GOLD" then
	       _buyItem(itemId, toBuy, CURT_MONEY)
	   end
	end
end

-- ---------------------------------------------------------------------------------------------------------------------



local function IsCPEnabledInCampaign()
	local rulesetId = GetCampaignRulesetId(GetCurrentCampaignId())
	if (rulesetId == 24 or rulesetId == 22 or rulesetId == 15) then
		return false
	end
	return true
end

local function RequiredPoints(championSkillId)
	if not DoesChampionSkillHaveJumpPoints(championSkillId) then return 1 end
	local firstJumpPoint
	_, firstJumpPoint = GetChampionSkillJumpPoints(championSkillId)
	return firstJumpPoint
end

-- ---------------------------------------------------------------------------------------------------------------------

local function OnShopOpen()
    PAR.debugln("PARepair.OnShopOpen")
    local PARepairSavedVars = PAR.SavedVars
	
	-- we check if Professional Upkeep is slotted
	local ProUpkeep
	for index = 1, 12 do
		if GetSlotBoundId(index, HOTBAR_CATEGORY_CHAMPION) == 1 then
			ProUpkeep = true   
		end
	end
	
	if not ProUpkeep then
		local canProUpKeepBeSlotted = true
		if GetNumPointsSpentOnChampionSkill(1) < RequiredPoints(1) then
			canProUpKeepBeSlotted = nil
		end
	end
	
	if not ProUpkeep and canProUpKeepBeSlotted then
	   -- We wait 1 second for Jack Of All Trades to slot Professional Upkeep
	   if JackOfAllTrades and JackOfAllTrades.savedVariables and JackOfAllTrades.savedVariables.enable and JackOfAllTrades.savedVariables.enable.professionalUpkeep and IsCPEnabledInCampaign() then	
		  zo_callLater(function() OnShopOpen() end, 1000) 
		  return
	   end	
	end 

	-- anti spam
	PARepairSavedVars.LastOnShopOpen = PARepairSavedVars.LastOnShopOpen or 0
	if GetTimeStamp() <= PARepairSavedVars.LastOnShopOpen + 1 then
	   return
	end 
	
    if PARProfileManager.hasActiveProfile() then
        -- check if store can repair and if there is something to repair
        if CanStoreRepair() and GetRepairAllCost() > 0 then

            -- check if equipped items shall be repaired
            if PARepairSavedVars.autoRepairEnabled and PARepairSavedVars.RepairEquipped.repairWithGold then
                _repairItems(BAG_WORN, PARepairSavedVars.RepairEquipped.repairWithGoldDurabilityThreshold)
            end
            -- check if backpack items shall be repaired
            if PARepairSavedVars.autoRepairInventoryEnabled and PARepairSavedVars.RepairInventory.repairWithGold then
                _repairItems(BAG_BACKPACK, PARepairSavedVars.RepairInventory.repairWithGoldDurabilityThreshold)
            end
        
		end

		-- Check if we can buy something
		if not IsStoreEmpty() then
			 -- Check global Buy Repair Kits setting
			 if PARepairSavedVars.autoBuyRepairKitsEnabled then
			     -- Check if Equipment repair kits should be bought
			     if PARepairSavedVars.AutoBuyRepairKits.buyEquipmentRepairKits then
				     _buyEquipmentRepairKits()
			     end
			     -- Check if Cyrodiil repair kits should be bought
			     if PARepairSavedVars.AutoBuyRepairKits.buyCyrodiilRepairKits then
				     _buyCyrodiilRepairKits()
			     end
			 end
			 -- Check global Buy Soul Gems & Lockpicks setting
			 if PARepairSavedVars.autoBuySoulGemsEnabled then
			     -- Check if full Soul gems should be bought
			     if PARepairSavedVars.AutoBuySoulGems.buyFullSoulGems then
				     _buyFullSoulGems()
			     end
			     -- Check if empty Soul gems should be bought
			     if PARepairSavedVars.AutoBuySoulGems.buyEmptySoulGems then
				     _buyEmptySoulGems()
			     end
			     -- Check if Lockpicks gems should be bought
			     if PARepairSavedVars.AutoBuySoulGems.buyLockpicks then
				     _buyLockpicks()
			     end
				 
			 end
			 -- Check global Buy Siege Items setting
			 if PARepairSavedVars.autoBuySiegeItemsEnabled then
			     -- Check if each Siege Item should be bought
                 local siegeItems = PA.Repair.SiegeWeapons[GetUnitAlliance("player")]
                 for key, value in ipairs(siegeItems) do  -- keep ipairs so they display in order 
				     if PARepairSavedVars["AutoBuySiegeItems"]["buy"..value.settingName] then
					      local threshold = PARepairSavedVars["AutoBuySiegeItems"]["buy"..value.settingName.."Threshold"]
						  local priority = PARepairSavedVars["AutoBuySiegeItems"]["buy"..value.settingName.."Priority"]
						 _buySiegeItems(value.itemId, threshold, priority)
					 end
				 end
			 end
			 
		end
    end
	PARepairSavedVars.LastOnShopOpen = GetTimeStamp()
end

-- Export
PA.Repair = PA.Repair or {}
PA.Repair.OnShopOpen = OnShopOpen