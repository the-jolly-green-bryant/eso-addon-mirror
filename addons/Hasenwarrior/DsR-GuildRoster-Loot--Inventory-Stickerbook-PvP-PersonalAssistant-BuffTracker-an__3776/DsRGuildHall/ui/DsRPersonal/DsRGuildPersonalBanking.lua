-- Create namespace
DsRGuildPersonalBanking = {}
local DsRGuildPersonalBanking = DsRGuildPersonalBanking or {}

DsRGuildPersonalBanking.name = "DsRGuildPersonalBanking"

DsRGuildPersonalBanking.ourBagCache = {
	[BAG_BACKPACK] = {},
	[BAG_BANK] = {},
	[BAG_SUBSCRIBER_BANK] = {},
}

local DSRPB = DsRGuildPersonalBanking

-------------------------------------------------------------------------------------------------------------------------------------------------
-- General Functions
-------------------------------------------------------------------------------------------------------------------------------------------------
	local function FindEmptySlotInBag(targetBag)
		for slotIndex = 0, (GetBagSize(targetBag) - 1) do
			if not SHARED_INVENTORY.bagCache[targetBag][slotIndex] and not DsRGuildPersonalBanking.ourBagCache[targetBag][slotIndex] then
				DsRGuildPersonalBanking.ourBagCache[targetBag][slotIndex] = true
				return slotIndex
			end
		end
		return nil
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function _findFirstEmptySlotAndTargetBagFromSourceBag(sourceBagId)
		local targetBagId
		local targetSlotIndex
	
		if sourceBagId == BAG_BACKPACK then
			targetBagId = BAG_BANK
			targetSlotIndex = FindEmptySlotInBag(targetBagId)
			if targetSlotIndex == nil and IsESOPlusSubscriber() then
				targetBagId = BAG_SUBSCRIBER_BANK
				targetSlotIndex = FindEmptySlotInBag(targetBagId)
			end
		elseif sourceBagId == BAG_BANK or (sourceBagId == BAG_SUBSCRIBER_BANK and IsESOPlusSubscriber()) then
			targetBagId = BAG_BACKPACK
			targetSlotIndex = FindEmptySlotInBag(targetBagId)
		end
	
		if targetBagId ~= nil and targetSlotIndex ~= nil then
			return targetBagId, targetSlotIndex
		end
		return targetBagId, nil
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function FilterUnwantedItems(itemData)
	    local isStolen    = itemData.stolen
	    local isJunk      = itemData.isJunk
	    local isProtected = itemData.isPlayerLocked
	    if isStolen or isJunk or isProtected then
	      	return false
	    else
	      	return true
	    end
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function MoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
		else
			RequestMoveItem(sourceBag, sourceSlot, targetBag, emptySlot, stackCount)
		end
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function isItemLinkForCompanion(itemLink)
		local actorCategory = GetItemLinkActorCategory(itemLink)
		return actorCategory == GAMEPLAY_ACTOR_CATEGORY_COMPANION
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function IsScribingScriptKnown(itemLink)
		local craftedAbilityScriptId = GetItemLinkItemUseReferenceId(itemLink) or 0
		local craftedAbilityScriptData = SCRIBING_DATA_MANAGER:GetCraftedAbilityScriptData(craftedAbilityScriptId)
		local isUnlocked = craftedAbilityScriptData:IsUnlocked()
		return isUnlocked
	end 

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function IsScribingGrimoireKnown(itemLink)
		local craftedAbilityId = GetItemLinkItemUseReferenceId(itemLink) or 0
		local craftedAbilityData = SCRIBING_DATA_MANAGER:GetCraftedAbilityData(craftedAbilityId)
		local isUnlocked = craftedAbilityData:IsUnlocked()
		return isUnlocked
	end	

	-------------------------------------------------------------------------------------------------------------------------------------------------
	local function _getItemLinkLearnableStatus(itemLink) 
		local itemType, specializedItemType = GetItemLinkItemType(itemLink)
		local itemFilterType = GetItemLinkFilterTypeInfo(itemLink)
		local itemUseType = GetItemLinkItemUseType(itemLink)

		if isItemLinkForCompanion(itemLink) then return nil end
		-- Recipe
		if specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD then
			if IsItemLinkRecipeKnown(itemLink) then return true end
			return false
		elseif specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 then
			if IsItemLinkRecipeKnown(itemLink) then return true end
			return false
		-- Stilkapitel / Stilbuch
		elseif itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
			if IsItemLinkBook(itemLink) then
				if IsItemLinkBookKnown(itemLink) then return true end
				return false
			end
		-- Stilseite
		elseif specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE or specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER then
			local containerCollectibleId = GetItemLinkContainerCollectibleId(itemLink)
			local collectibleName = GetCollectibleName(containerCollectibleId)
			if collectibleName ~= nil and collectibleName ~= "" then
				local isValidForPlayer = IsCollectibleValidForPlayer(containerCollectibleId)
				if isValidForPlayer then
					local isUnlocked = IsCollectibleUnlocked(containerCollectibleId)
					if isUnlocked then return true end
					return false
				end
			end
		-- Scribing Scripts	
		elseif itemUseType == ITEM_USE_TYPE_CRAFTED_ABILITY_SCRIPT then
			if IsScribingScriptKnown(itemLink) then return true end
			return false
		-- Scribing Grimoires
		elseif itemUseType == ITEM_USE_TYPE_CRAFTED_ABILITY then
			if IsScribingGrimoireKnown(itemLink) then return true end
			return false
		end
		return nil
	end

	-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(sourceBag, sourceSlot, targetBag, stackCount)
		local targetBagId, firstEmptySlot = _findFirstEmptySlotAndTargetBagFromSourceBag(sourceBag)
		if targetBagId ~= nil and firstEmptySlot ~= nil then
			MoveItem(sourceBag, sourceSlot, targetBagId, firstEmptySlot, stackCount)
			if stackCount > 0 then
				if targetBagId == BAG_BACKPACK then
					d(zo_strformat(" |c9fb6cd[DsR-Banking]|r " .. GetString(DsRGuildPersonal_BankingWithdrawTransaction), GetItemLink(sourceBag, sourceSlot), stackCount))
				else
					d(zo_strformat(" |c9fb6cd[DsR-Banking]|r " .. GetString(DsRGuildPersonal_BankingDepositTransaction), GetItemLink(sourceBag, sourceSlot), stackCount))
				end
			end
			return true
		else 
			local errorStringId = SI_INVENTORY_ERROR_INVENTORY_FULL
			ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK, errorStringId)
			return false
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Gold
-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.CurrencyGold(event_code, bank_bag)
		local currentChar 	= GetUnitName("player")
		local Icon			= zo_iconFormat("/esoui/art/currency/currency_gold.dds", 16, 16)

		if (bank_bag == BAG_BANK and DsRGuildPersonal.ACCconfig.CurrencyOnOff) then
			local amount = GetCarriedCurrencyAmount(CURT_MONEY)

			if DsRGuildPersonal.GetSettings()["Banking"]["Gold"] == "" then return end

			local diff = (amount - DsRGuildPersonal.GetSettings()["Banking"]["Gold"])
			if (diff > 0) then
				DepositCurrencyIntoBank(CURT_MONEY, diff)
				local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
				d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Deposit))
			elseif (diff < 0) then
				diff = -diff

				local bank_amount = GetBankedCurrencyAmount(CURT_MONEY)
				if (bank_amount > 0) then
					if bank_amount < diff then
						WithdrawCurrencyFromBank(CURT_MONEY, bank_amount)
						local bank_amount = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. bank_amount .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					else
						WithdrawCurrencyFromBank(CURT_MONEY, diff)
						local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					end
				end
			end
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- AP
-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.CurrencyAP(event_code, bank_bag)
		local currentChar 	= GetUnitName("player")
		local Icon			= zo_iconFormat("/esoui/art/currency/alliancepoints_64.dds", 18, 18)

		if (bank_bag == BAG_BANK and DsRGuildPersonal.ACCconfig.CurrencyOnOff) then
			local amount = GetCarriedCurrencyAmount(CURT_ALLIANCE_POINTS)

			if DsRGuildPersonal.GetSettings()["Banking"]["AP"] == "" then return end

			local diff = (amount - DsRGuildPersonal.GetSettings()["Banking"]["AP"])
			if (diff > 0) then
				DepositCurrencyIntoBank(CURT_ALLIANCE_POINTS, diff)
				local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
				d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Deposit))
			elseif (diff < 0) then
				diff = -diff

				local bank_amount = GetBankedCurrencyAmount(CURT_ALLIANCE_POINTS)
				if (bank_amount > 0) then
					if bank_amount < diff then
						WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, bank_amount)
						local bank_amount = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. bank_amount .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					else
						WithdrawCurrencyFromBank(CURT_ALLIANCE_POINTS, diff)
						local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					end
				end
			end
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- TelVar
-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.CurrencyTelVar(event_code, bank_bag)
		local currentChar 	= GetUnitName("player")
		local Icon			= zo_iconFormat("/esoui/art/hud/telvar_meter_currency.dds", 18, 18)

		if (bank_bag == BAG_BANK and DsRGuildPersonal.ACCconfig.CurrencyOnOff) then
			local amount = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)

			if DsRGuildPersonal.GetSettings()["Banking"]["TelVar"] == "" then return end

			local diff = (amount - DsRGuildPersonal.GetSettings()["Banking"]["TelVar"])
			if (diff > 0) then
				DepositCurrencyIntoBank(CURT_TELVAR_STONES, diff)
				local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
				d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Deposit))
			elseif (diff < 0) then
				diff = -diff

				local bank_amount = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
				if (bank_amount > 0) then
					if bank_amount < diff then
						WithdrawCurrencyFromBank(CURT_TELVAR_STONES, bank_amount)
						local bank_amount = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. bank_amount .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					else
						WithdrawCurrencyFromBank(CURT_TELVAR_STONES, diff)
						local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					end
				end
			end
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- WritVouchers
-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.CurrencyWritVouchers(event_code, bank_bag)
		local currentChar 	= GetUnitName("player")
		local Icon			= zo_iconFormat("/esoui/art/icons/icon_writvoucher.dds", 16, 16)

		if (bank_bag == BAG_BANK and DsRGuildPersonal.ACCconfig.CurrencyOnOff) then
			local amount = GetCarriedCurrencyAmount(CURT_WRIT_VOUCHERS)

			if DsRGuildPersonal.GetSettings()["Banking"]["writvoucher"] == "" then return end

			local diff = (amount - DsRGuildPersonal.GetSettings()["Banking"]["writvoucher"])
			if (diff > 0) then
				DepositCurrencyIntoBank(CURT_WRIT_VOUCHERS, diff)
				local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
				d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Deposit))
			elseif (diff < 0) then
				diff = -diff

				local bank_amount = GetBankedCurrencyAmount(CURT_WRIT_VOUCHERS)
				if (bank_amount > 0) then
					if bank_amount < diff then
						WithdrawCurrencyFromBank(CURT_WRIT_VOUCHERS, bank_amount)
						local bank_amount = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. bank_amount .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					else
						WithdrawCurrencyFromBank(CURT_WRIT_VOUCHERS, diff)
						local diffNumber = ZO_CommaDelimitNumber( diff ):gsub("%,","%.")
						d(" |c9fb6cd[DsR-Banking]|r " .. diffNumber .. Icon .. " ".. GetString(DsRGuildPersonal_Withdraw))
					end
				end
			end
		end
	end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Deposit or Withdraw (SoulGem, LockPick)
-------------------------------------------------------------------------------------------------------------------------------------------------
	function DsRGuildPersonalBanking.BankingItemDepositOrWithdraw(event_code, bank_bag) 
		local bagpackCache = SHARED_INVENTORY:GenerateFullSlotData(FilterUnwantedItems, BAG_BACKPACK)
		
		local itemQuantitySoulFilled_InBag  = 0
		local itemQuantitySoulEmpty_InBag   = 0
		local itemQuantityLockPick_InBag    = 0
		local itemQuantityTool_InBag        = 0

		local itemQuantitySoulFilled_InBank = 0
		local itemQuantitySoulEmpty_InBank  = 0
		local itemQuantityLockPick_InBank   = 0
		local itemQuantityTool_InBank       = 0

		local soulGem_ItemId		= 33271
		local soulGemEmpty_ItemId	= 33265
	
		local sumINVDeposit = {
			[ITEMTYPE_SOUL_GEM] 			= 0,
			[SPECIALIZED_ITEMTYPE_SOUL_GEM] = 0,
			[ITEMTYPE_LOCKPICK] 			= 0,
			[ITEMTYPE_TOOL]     			= 0,
		}
		local sumINVWhitedraw 	= {
			[ITEMTYPE_SOUL_GEM] 			= 0,
			[SPECIALIZED_ITEMTYPE_SOUL_GEM] = 0,
			[ITEMTYPE_LOCKPICK] 			= 0,
			[ITEMTYPE_TOOL]     			= 0,
		}
		local keepINV 	= {
			[ITEMTYPE_SOUL_GEM] 			= DsRGuildPersonal.GetSettings()["Banking"]["SliderSoulgem"],
			[SPECIALIZED_ITEMTYPE_SOUL_GEM] = DsRGuildPersonal.GetSettings()["Banking"]["SliderSoulgemEmpty"],
			[ITEMTYPE_LOCKPICK] 			= DsRGuildPersonal.GetSettings()["Banking"]["SliderLockPick"],
			[ITEMTYPE_TOOL]     			= DsRGuildPersonal.GetSettings()["Banking"]["SliderTool"],
		}
	
		for bagSlot, data in pairs(bagpackCache) do
			local itemId = GetItemId(BAG_BACKPACK, data.slotIndex)
			local itemType, specializedItemType = GetItemType(BAG_BACKPACK, data.slotIndex)

			if itemId == soulGem_ItemId then
				itemQuantitySoulFilled_InBag  	   	= GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
				sumINVDeposit[ITEMTYPE_SOUL_GEM]   	= sumINVDeposit[ITEMTYPE_SOUL_GEM] + itemQuantitySoulFilled_InBag
				sumINVWhitedraw[ITEMTYPE_SOUL_GEM] 	= sumINVWhitedraw[ITEMTYPE_SOUL_GEM] + itemQuantitySoulFilled_InBag
			elseif itemId == soulGemEmpty_ItemId then
				itemQuantitySoulEmpty_InBag  					= GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
				sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM] 	= sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM] + itemQuantitySoulEmpty_InBag
				sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM] 	= sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM] + itemQuantitySoulEmpty_InBag
			elseif itemType == ITEMTYPE_LOCKPICK then
				itemQuantityLockPick_InBag  		= GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
				sumINVDeposit[ITEMTYPE_LOCKPICK] 	= sumINVDeposit[ITEMTYPE_LOCKPICK] + itemQuantityLockPick_InBag
				sumINVWhitedraw[ITEMTYPE_LOCKPICK] 	= sumINVWhitedraw[ITEMTYPE_LOCKPICK] + itemQuantityLockPick_InBag
			elseif itemType == ITEMTYPE_TOOL then
				itemQuantityTool_InBag  		    = GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
				sumINVDeposit[ITEMTYPE_TOOL] 	    = sumINVDeposit[ITEMTYPE_TOOL] + itemQuantityTool_InBag
				sumINVWhitedraw[ITEMTYPE_TOOL] 	    = sumINVWhitedraw[ITEMTYPE_TOOL] + itemQuantityTool_InBag
			end
		end

		-------------------------------------------------------------------------------------------------------------------------------------------------
		-- Deposit to Bank
		-------------------------------------------------------------------------------------------------------------------------------------------------	
		for bagSlot, data in pairs(bagpackCache) do
			local itemID 	= GetItemId(BAG_BACKPACK, data.slotIndex)
			local itemLink 	= GetItemLink(BAG_BACKPACK, data.slotIndex)
			local itemTrait = GetItemTrait(BAG_BACKPACK, data.slotIndex) 
			local itemType, specializedItemType = GetItemType(BAG_BACKPACK, data.slotIndex)

			if itemID == soulGem_ItemId then
				itemQuantitySoulFilled_InBag  = GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
			elseif itemID == soulGemEmpty_ItemId then
				itemQuantitySoulEmpty_InBag  = GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
			elseif itemType == ITEMTYPE_LOCKPICK then
				itemQuantityLockPick_InBag  = GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
			elseif itemType == ITEMTYPE_TOOL then
				itemQuantityTool_InBag  = GetSlotStackSize(BAG_BACKPACK, data.slotIndex)
			end

			if DsRGuildPersonal.ACCconfig.CurrencyOnOff then
				-- SoulGem FILLED
				if itemID == soulGem_ItemId and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM] then
					if tonumber(sumINVDeposit[ITEMTYPE_SOUL_GEM]) > tonumber(keepINV[ITEMTYPE_SOUL_GEM]) then
						local stackCountSoulGemFILLED = sumINVDeposit[ITEMTYPE_SOUL_GEM] - keepINV[ITEMTYPE_SOUL_GEM]
						if itemQuantitySoulFilled_InBag < stackCountSoulGemFILLED then
							stackCountSoulGemFILLED = itemQuantitySoulFilled_InBag
						end
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, stackCountSoulGemFILLED)
						sumINVDeposit[ITEMTYPE_SOUL_GEM] = sumINVDeposit[ITEMTYPE_SOUL_GEM] - stackCountSoulGemFILLED
					end
				end
				-- SoulGem EMPTY
				if itemID == soulGemEmpty_ItemId and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM] then
					if tonumber(sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM]) > tonumber(keepINV[SPECIALIZED_ITEMTYPE_SOUL_GEM]) then
						local stackCountSoulGemEMPTY = sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM] - keepINV[SPECIALIZED_ITEMTYPE_SOUL_GEM]
						if itemQuantitySoulEmpty_InBag < stackCountSoulGemEMPTY then
							stackCountSoulGemEMPTY = itemQuantitySoulEmpty_InBag
						end
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, stackCountSoulGemEMPTY)
						sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM] = sumINVDeposit[SPECIALIZED_ITEMTYPE_SOUL_GEM] - stackCountSoulGemEMPTY
					end
				end
				-- LockPick
				if itemType == ITEMTYPE_LOCKPICK and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK] then
					if tonumber(sumINVDeposit[ITEMTYPE_LOCKPICK]) > tonumber(keepINV[ITEMTYPE_LOCKPICK]) then
						local stackCountLockPick = sumINVDeposit[ITEMTYPE_LOCKPICK] - keepINV[ITEMTYPE_LOCKPICK]
						if itemQuantityLockPick_InBag < stackCountLockPick then
							stackCountLockPick = itemQuantityLockPick_InBag
						end
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, stackCountLockPick)
						sumINVDeposit[ITEMTYPE_LOCKPICK] = sumINVDeposit[ITEMTYPE_LOCKPICK] - stackCountLockPick
					end
				end
				-- ReparKits
				if itemType == ITEMTYPE_TOOL and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL] then
					if tonumber(sumINVDeposit[ITEMTYPE_TOOL]) > tonumber(keepINV[ITEMTYPE_TOOL]) then
						local stackCountTool = sumINVDeposit[ITEMTYPE_TOOL] - keepINV[ITEMTYPE_TOOL]
						if itemQuantityTool_InBag < stackCountTool then
							stackCountTool = itemQuantityTool_InBag
						end
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, stackCountTool)
						sumINVDeposit[ITEMTYPE_TOOL] = sumINVDeposit[ITEMTYPE_TOOL] - stackCountTool
					end
				end
				-- Unbekannte Meisterschriebe
				if ( itemID == 217917 or itemID == 217918 or itemID == 217919 or itemID == 217920 or itemID == 217921 or itemID == 217922 or itemID == 217923 ) and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Meisterschriebe
				if itemType == ITEMTYPE_MASTER_WRIT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Unbekannte Fundberichte
				if ( itemID == 219853 or itemID == 219849 or itemID == 219854 or itemID == 219850 or itemID == 219851 or itemID == 219852 ) and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end	
				-- Fundberichte
				if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Ungeöffnete Schatzkarten
				if itemID == 224681 and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Schatzkarten
				if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Rezeptfragment
				if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Runenkistenfragment
				if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end
				-- Sammlungsfragment
				if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] == 2 then
					DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
				end

				if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
					local known      = _getItemLinkLearnableStatus(itemLink)
					local CharName   = GetUnitName("player")
					
					if DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
					else
						-- Scribing
						if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and known == true and DsRGuildPersonal.GetSettings()["Banking"]["DepoScribingKnown"] then
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
						end
						-- Recipe
						if ( specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD ) and known == true and DsRGuildPersonal.GetSettings()["Banking"]["DepoRecipeKnown"] then
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
						end
						-- Einrichtungsblaupause / Einrichtungsskizze / Einrichtungsanleitung
						if ( specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 ) and known == true and DsRGuildPersonal.GetSettings()["Banking"]["DepoBlueprintKnown"] then
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
						end
						-- Stilseite / Stilkapitel / Stilbuch
						if ( specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE ) and known == true and DsRGuildPersonal.GetSettings()["Banking"]["DepoStileKnown"]then
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
						end
					end
				end
			end

			-- AVABanking
			if ( itemType == ITEMTYPE_SIEGE or itemType == ITEMTYPE_AVA_REPAIR ) and DsRGuildPersonal.ACCconfig.BankingAvAOnOff then
				local siegeItems   = DsRGuildPersonalGlobals.SiegeWeapons[GetUnitAlliance("player")]
				for key, value in ipairs(siegeItems) do
					if itemID == value.itemId then
						if DsRGuildPersonal.GetSettings()["BankingAvA"]["depo"..value.settingName] == 2 then
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(BAG_BACKPACK, data.slotIndex, BAG_BANK, data.stackCount)
						end
					end
				end
			end
		end
		
		-------------------------------------------------------------------------------------------------------------------------------------------------
		-- Withdraw from Bank
		-------------------------------------------------------------------------------------------------------------------------------------------------
		local bags = {BAG_BANK}
		if (IsESOPlusSubscriber()) then
            table.insert(bags, BAG_SUBSCRIBER_BANK)
        end

		for _, bag in pairs(bags) do
            for bankSlot, data in pairs(SHARED_INVENTORY.bagCache[bag]) do
				local itemID 	= GetItemId(bag, data.slotIndex)
				local itemLink 	= GetItemLink(bag, data.slotIndex)
				local itemTrait = GetItemTrait(bag, data.slotIndex) 
				local itemType, specializedItemType = GetItemType(bag, data.slotIndex)

				if itemID == soulGem_ItemId then
					itemQuantitySoulFilled_InBank = GetSlotStackSize(bag, data.slotIndex)
				elseif itemID == soulGemEmpty_ItemId then
					itemQuantitySoulEmpty_InBank = GetSlotStackSize(bag, data.slotIndex)
				elseif itemType == ITEMTYPE_LOCKPICK then
					itemQuantityLockPick_InBank = GetSlotStackSize(bag, data.slotIndex)
				elseif itemType == ITEMTYPE_TOOL then
					itemQuantityTool_InBank = GetSlotStackSize(bag, data.slotIndex)
				end

				if DsRGuildPersonal.ACCconfig.CurrencyOnOff then
					-- SoulGem FILLED
					if itemID == soulGem_ItemId and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_SOUL_GEM]then
						if tonumber(sumINVWhitedraw[ITEMTYPE_SOUL_GEM]) < tonumber(keepINV[ITEMTYPE_SOUL_GEM]) then
							local stackCountSoulGemFILLED = keepINV[ITEMTYPE_SOUL_GEM] - sumINVWhitedraw[ITEMTYPE_SOUL_GEM]
							if itemQuantitySoulFilled_InBank < stackCountSoulGemFILLED then
								stackCountSoulGemFILLED = itemQuantitySoulFilled_InBank
							end
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, stackCountSoulGemFILLED)
							sumINVWhitedraw[ITEMTYPE_SOUL_GEM] = sumINVWhitedraw[ITEMTYPE_SOUL_GEM] + stackCountSoulGemFILLED
						end
					end
					-- SoulGem EMPTY
					if itemID == soulGemEmpty_ItemId and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][SPECIALIZED_ITEMTYPE_SOUL_GEM]then
						if tonumber(sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM]) < tonumber(keepINV[SPECIALIZED_ITEMTYPE_SOUL_GEM]) then
							local stackCountSoulGemEMPTY = keepINV[SPECIALIZED_ITEMTYPE_SOUL_GEM] - sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM]
							if itemQuantitySoulEmpty_InBank < stackCountSoulGemEMPTY then
								stackCountSoulGemEMPTY = itemQuantitySoulEmpty_InBank
							end
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, stackCountSoulGemEMPTY)
							sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM] = sumINVWhitedraw[SPECIALIZED_ITEMTYPE_SOUL_GEM] + stackCountSoulGemEMPTY
						end
					end
					-- LockPick
					if itemType == ITEMTYPE_LOCKPICK and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_LOCKPICK]then
						if tonumber(sumINVWhitedraw[ITEMTYPE_LOCKPICK]) < tonumber(keepINV[ITEMTYPE_LOCKPICK]) then
							local stackCountLockPick = keepINV[ITEMTYPE_LOCKPICK] - sumINVWhitedraw[ITEMTYPE_LOCKPICK]
							if itemQuantityLockPick_InBank < stackCountLockPick then
								stackCountLockPick = itemQuantityLockPick_InBank
							end
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, stackCountLockPick)
							sumINVWhitedraw[ITEMTYPE_LOCKPICK] = sumINVWhitedraw[ITEMTYPE_LOCKPICK] + stackCountLockPick
						end
					end
					-- RapairKit
					if itemType == ITEMTYPE_TOOL and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesSoulLock"][ITEMTYPE_TOOL]then
						if tonumber(sumINVWhitedraw[ITEMTYPE_TOOL]) < tonumber(keepINV[ITEMTYPE_TOOL]) then
							local stackCountTool = keepINV[ITEMTYPE_TOOL] - sumINVWhitedraw[ITEMTYPE_TOOL]
							if itemQuantityTool_InBank < stackCountTool then
								stackCountTool = itemQuantityTool_InBank
							end
							DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, stackCountTool)
							sumINVWhitedraw[ITEMTYPE_TOOL] = sumINVWhitedraw[ITEMTYPE_TOOL] + stackCountTool
						end
					end
					-- Unbekannte Meisterschriebe
					if ( itemID == 217917 or itemID == 217918 or itemID == 217919 or itemID == 217920 or itemID == 217921 or itemID == 217922 or itemID == 217923 ) and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end					
					-- Meisterschriebe
					if itemType == ITEMTYPE_MASTER_WRIT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][ITEMTYPE_MASTER_WRIT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Unbekannte Fundberichte
					if ( itemID == 219853 or itemID == 219849 or itemID == 219854 or itemID == 219850 or itemID == 219851 or itemID == 219852 ) and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end	
					-- Fundberichte
					if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Ungeöffnete Schatzkarten
					if itemID == 224681 and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Schatzkarten
					if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Rezeptfragment
					if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Runenkistenfragment
					if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end
					-- Sammlungsfragment
					if specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT and DsRGuildPersonal.GetSettings()["Banking"]["BankingtypesVoucher"][SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT] == 3 then
						DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
					end

					if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD or specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
						local known      = _getItemLinkLearnableStatus(itemLink)
						-- local CharName   = GetUnitName("player")
						-- if DsRGuildPersonalSettings["Default"][GetDisplayName()][tostring(CharName)]["Banking"]["DepoRecipeAll"] then
						-- 	DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, 1)
						-- else
							-- Scribing
							if itemType == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and known == false and DsRGuildPersonal.GetSettings()["Banking"]["DepoScribingUnknown"] then
								DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, 1)
							end
							-- Recipe
							if ( specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK or specializedItemType == SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD ) and known == false and DsRGuildPersonal.GetSettings()["Banking"]["DepoRecipeUnknown"] then
								DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, 1)
							end
							-- Einrichtungsblaupause / Einrichtungsskizze / Einrichtungsanleitung
							if ( specializedItemType == 172 or specializedItemType == 173 or specializedItemType == 174 or specializedItemType == 175 or specializedItemType == 176 or specializedItemType == 177 or specializedItemType == 178 ) and known == false and DsRGuildPersonal.GetSettings()["Banking"]["DepoBlueprintUnknown"] then
								DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, 1)
							end
							-- Stilseite / Stilkapitel / Stilbuch
							if ( specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK or specializedItemType == SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER or specializedItemType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE ) and known == false and DsRGuildPersonal.GetSettings()["Banking"]["DepoStileUnknown"] then
								DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, 1)
							end
						-- end
					end
				end

				-- AVABanking
				if ( itemType == ITEMTYPE_SIEGE or itemType == ITEMTYPE_AVA_REPAIR ) and DsRGuildPersonal.ACCconfig.BankingAvAOnOff then
					local siegeItems   = DsRGuildPersonalGlobals.SiegeWeapons[GetUnitAlliance("player")]
					for key, value in ipairs(siegeItems) do
						if itemID == value.itemId then
							if DsRGuildPersonal.GetSettings()["BankingAvA"]["depo"..value.settingName] == 3 then
								DsRGuildPersonalBanking.TryPlaceItemInEmptySlot(bag, data.slotIndex, BAG_BACKPACK, data.stackCount)
							end
						end
					end
				end
			end
		end
	end
