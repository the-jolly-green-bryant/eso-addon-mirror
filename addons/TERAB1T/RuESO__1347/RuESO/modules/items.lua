function RuESO_doubleNamesItems(RuESO)
	if RuESO:GetLanguage() == "ru" then
		
		-- Tooltips
		local rsd = RuESO.Settings.Data
		
		local function GetWornLink(slot, bagId)
			return GetItemLink(bagId, slot)
		end
		
		local function GetChatLink(aLink)
			return aLink
		end
		
		local function CheckAlchemyName(...)
			local link, prospectiveAlchemyResult = GetAlchemyResultingItemLink(...)
			if prospectiveAlchemyResult ~= PROSPECTIVE_ALCHEMY_RESULT_KNOWN then
				return ""
			else
				return link
			end
		end
		
		local function splitItemName(itemName, itemNameRaw)
			local finalName = ""
			if string.match(itemName, " " .. itemNameRaw .. " ") then
				local prefix, affix = string.match(itemName, "^(.*) " .. itemNameRaw .. " (.*)$")
				
				if prefix and rsd.Prefixes[prefix:sub(1, #prefix - 4)] then
					finalName = rsd.Prefixes[prefix:sub(1, #prefix - 4)] .. " "
				end
				
				finalName = finalName .. rsd.Parts[itemNameRaw]
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				end
				
				return finalName
			elseif string.match(itemName, " " .. itemNameRaw .. "$") then
				local prefix = string.match(itemName, "^(.*) " .. itemNameRaw .. "$")
				
				if prefix and rsd.Prefixes[prefix:sub(1, #prefix - 4)] then
					finalName = rsd.Prefixes[prefix:sub(1, #prefix - 4)] .. " "
				end
				
				finalName = finalName .. rsd.Parts[itemNameRaw]
				
				return finalName
			elseif string.match(itemName, "^" .. itemNameRaw .. " ") then
				local affix = string.match(itemName, "^" .. itemNameRaw .. " (.*)$")
				
				finalName = finalName .. rsd.Parts[itemNameRaw]
				
				if affix and rsd.Affixes[affix] then
					finalName = finalName .. " " .. rsd.Affixes[affix]
				end
				
				return finalName
			end
			
			return rsd.Parts[itemNameRaw]
		end
		
		local function modifyTooltip(lnk)
			if RuESO.Settings.ShowItemsNamesTooltip ~= RuESO.DropdownParameters["ru"] or RuESO.Settings.ShowItemsEnchantsTooltip ~= "ru" or RuESO.Settings.ShowItemsTraitsTooltip ~= "ru" or RuESO.Settings.ShowItemsSetsTooltip ~= "ru" then
				local rusName, rusTrait, rusEnchant, rusSet
				local itmType = GetItemLinkItemType(lnk)
				-- Names
				
				local itmId = GetItemLinkItemId(lnk)
				local itmName = GetItemLinkName(lnk)
				rusName = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itmName)
				local itmNameRaw = rsd.Items[itmId]
				local itmNameRawRu = ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:" .. itmId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
				local itmNameFinal = ""
				
				local finalName, finalEnchant, finalTrait, finalSet
				
				if itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then						
					if itmNameRaw then
						for index,value in pairs(rsd.EnchantPrefixes) do
							if string.match(ZO_CachedStrFormat("<<z:1>>", itmName), "^" .. index) then
								itmNameFinal = value .. " "
								break
							end
						end
						
						finalName = itmNameFinal .. itmNameRaw
					end
				elseif itmType == ITEMTYPE_POISON or itmType == ITEMTYPE_POTION then
					if rsd.Potions[ZO_CachedStrFormat("<<z:1>>", itmName)] then
						finalName = rsd.Potions[ZO_CachedStrFormat("<<z:1>>", itmName)]
					elseif rsd.Items[itmId] then
						finalName = rsd.Items[itmId]
					end
				elseif itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON then
					if itmNameRawRu and rsd.Parts[ZO_CachedStrFormat("<<z:1>>", itmNameRawRu)] then
						finalName = splitItemName(ZO_CachedStrFormat("<<z:1>>", itmName), itmNameRawRu)
					elseif rsd.Items[itmId] then
						finalName = rsd.Items[itmId]
					end
				elseif itmType == ITEMTYPE_CONTAINER then
					if rsd.Items[itmId] then
						local loweredItemName = ZO_CachedStrFormat("<<z:1>>", itmName)
						if loweredItemName ~= itmNameRawRu then
							local prefix = string.match(loweredItemName, "^([^ ]+) ")
							
							if prefix and rsd.Prefixes[prefix:sub(1, #prefix - 4)] then
								finalName = rsd.Prefixes[prefix:sub(1, #prefix - 4)] .. " " .. rsd.Items[itmId]
							else
								finalName = rsd.Items[itmId]
							end
						else
							finalName = rsd.Items[itmId]
						end
					end
				else
					if rsd.Items[itmId] then
						finalName = rsd.Items[itmId]
					end
				end
				
				-- Enchantments
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_GLYPH_ARMOR or itmType == ITEMTYPE_GLYPH_JEWELRY or itmType == ITEMTYPE_GLYPH_WEAPON then
					if ruesoEnchants[GetItemLinkFinalEnchantId(lnk)] then
						local hasCharges, enchantHeader = GetItemLinkEnchantInfo(lnk)
						rusEnchant = string.match(enchantHeader, ": (.*)$")
						finalEnchant = ruesoEnchants[GetItemLinkFinalEnchantId(lnk)]
					end
				end
				
				-- Traits
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON or itmType == ITEMTYPE_ARMOR_TRAIT or itmType == ITEMTYPE_JEWELRY_TRAIT or itmType == ITEMTYPE_WEAPON_TRAIT then
					local traitType = GetItemLinkTraitType(lnk)
					if rsd.Traits[traitType] then
						rusTrait = GetString("SI_ITEMTRAITTYPE", traitType)
						finalTrait = rsd.Traits[traitType]
					end
				end
				
				-- Sets
				
				if itmType == ITEMTYPE_ARMOR or itmType == ITEMTYPE_WEAPON then
					local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(lnk, false)
					rusSet = setName
					
					if rsd.Sets[setId] then
						finalSet = rsd.Sets[setId]
					end
				end
				
				if itmType == ITEMTYPE_CONTAINER then
					local numSetIds = GetItemLinkNumContainerSetIds(lnk)
					
					if numSetIds > 0 then
						for i = 1, numSetIds do
							local hasSet, _, _, _, _, setId = GetItemLinkContainerSetInfo(lnk, i)
							
							if rsd.Sets[setId] then
								finalSet = rsd.Sets[setId]
							end
						end
					end
				end
				
				if RuESO.Settings.ShowItemsNamesTooltip ~= "ru" and finalName and rusName then
					if RuESO.Settings.ShowItemsNamesTooltip == "ruen" then
						finalName = string.format("%s (%s)", rusName, finalName)
					elseif RuESO.Settings.ShowItemsNamesTooltip == "enru" then
						finalName = string.format("%s (%s)", finalName, rusName)
					end
					
					SafeAddString(SI_TOOLTIP_ITEM_NAME, finalName, 10)
				end
				
				if RuESO.Settings.ShowItemsEnchantsTooltip ~= "ru" and finalEnchant and rusEnchant then
					if RuESO.Settings.ShowItemsEnchantsTooltip == "ruen" then
						finalEnchant = string.format("%s (%s)", rusEnchant, finalEnchant)
					elseif RuESO.Settings.ShowItemsEnchantsTooltip == "enru" then
						finalEnchant = string.format("%s (%s)", finalEnchant, rusEnchant)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, ZO_CachedStrFormat(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, finalEnchant), 10)
				end
				
				if RuESO.Settings.ShowItemsTraitsTooltip ~= "ru" and finalTrait and rusTrait then
					if RuESO.Settings.ShowItemsTraitsTooltip == "ruen" then
						finalTrait = string.format("%s (%s)", rusTrait, finalTrait)
					elseif RuESO.Settings.ShowItemsTraitsTooltip == "enru" then
						finalTrait = string.format("%s (%s)", finalTrait, rusTrait)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, finalTrait, 10)
					SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER):gsub("<<2>>", finalTrait), 10)
				end
				
				if RuESO.Settings.ShowItemsSetsTooltip ~= "ru" and finalSet and rusSet then
					if RuESO.Settings.ShowItemsSetsTooltip == "ruen" then
						finalSet = string.format("«%s» (%s)", rusSet, finalSet)
					elseif RuESO.Settings.ShowItemsSetsTooltip == "enru" then
						finalSet = string.format("«%s» (%s)", finalSet, rusSet)
					else
						finalSet = string.format("«%s»", finalSet)
					end
					
					SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, GetString(SI_ITEM_FORMAT_STR_SET_NAME):gsub("«<<1>>»", finalSet), 10)
				end
			end
		end
		
		local function itemTooltipHook(tooltipControl, method, linkFunc)
			local origMethod = tooltipControl[method]
			tooltipControl[method] = function(self, ...)
				
				if linkFunc then
					local lnk = linkFunc(...)
					modifyTooltip(lnk)
				end
				
				origMethod(self, ...)
					
				SafeAddString(SI_TOOLTIP_ITEM_NAME, RuESO.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
			end
		end
		
		local function comparativeTooltipHook(tooltip, gameDataType, ...)
			if gameDataType == TOOLTIP_GAME_DATA_EQUIPPED_INFO then
				local slotIndex, actorCategory = ...
				local itemLink = GetWornLink(slotIndex, GetWornBagForGameplayActorCategory(actorCategory))
				modifyTooltip(itemLink)				
			elseif gameDataType == TOOLTIP_GAME_DATA_STOLEN then
				SafeAddString(SI_TOOLTIP_ITEM_NAME, RuESO.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
				SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
			end
		end
		
		--itemTooltipHook(AntiquityTooltip, "SetAntiquitySetFragment", AntiqTest)
		itemTooltipHook(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
		itemTooltipHook(ItemTooltip, "SetBagItem", GetItemLink)
		itemTooltipHook(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
		itemTooltipHook(ItemTooltip, "SetLink", GetChatLink)
		itemTooltipHook(ItemTooltip, "SetLootItem", GetLootItemLink)
		itemTooltipHook(ItemTooltip, "SetStoreItem", GetStoreItemLink)
		itemTooltipHook(ItemTooltip, "SetTradeItem", GetTradeItemLink)
		itemTooltipHook(ItemTooltip, "SetTradingHouseItem", GetTradingHouseSearchResultItemLink)
		itemTooltipHook(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
		itemTooltipHook(ItemTooltip, "SetWornItem", GetWornLink)
		itemTooltipHook(ItemTooltip, "SetReward", GetItemRewardItemLink)
		itemTooltipHook(PopupTooltip, "SetLink", GetChatLink)
		itemTooltipHook(ItemTooltip, "SetItemUsingEnchantment", GetEnchantedItemResultingItemLink)
		itemTooltipHook(ItemTooltip, "SetAction", GetSlotItemLink)
		itemTooltipHook(ItemTooltip, "SetItemSetCollectionPieceLink", GetChatLink)
		
		ZO_PreHookHandler(ComparativeTooltip1, "OnAddGameData", comparativeTooltipHook)
		ZO_PreHookHandler(ComparativeTooltip2, "OnAddGameData", comparativeTooltipHook)
		
		itemTooltipHook(ZO_AlchemyTopLevelTooltip, "SetPendingAlchemyItem", CheckAlchemyName)
		itemTooltipHook(ZO_EnchantingTopLevelTooltip, "SetPendingEnchantingItem", GetEnchantingResultingItemLink)
		itemTooltipHook(ZO_ProvisionerTopLevelTooltip, "SetProvisionerResultItem", GetRecipeResultItemLink)
		itemTooltipHook(ZO_SmithingTopLevelCreationPanelResultTooltip, "SetPendingSmithingItem", GetSmithingPatternResultLink)
		itemTooltipHook(ZO_SmithingTopLevelImprovementPanelResultTooltip, "SetSmithingImprovementResult", GetSmithingImprovedItemLink)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetPendingRetraitItem", GetResultingItemLinkAfterRetrait)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelRetraitPanelResultTooltip, "SetBagItem", GetItemLink)
		itemTooltipHook(ZO_RetraitStation_KeyboardTopLevelReconstructPanelOptionsPreviewTooltip, "SetItemSetCollectionPieceLink", GetChatLink)
		
		-- Gamepad PreHooks
		
		local function GamepadTooltipPreHook(tooltip, ...)
			modifyTooltip(itemLink)
		end
		
		local function GamepadTooltipPostHook()
			SafeAddString(SI_TOOLTIP_ITEM_NAME, RuESO.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"], 10)
			SafeAddString(SI_ITEM_FORMAT_STR_SET_NAME, RuESO.StringsBackup["SI_ITEM_FORMAT_STR_SET_NAME"], 10)
		end
		
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),    "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),   "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		ZO_PreHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", function(tooltip, ...)   modifyTooltip(({...})[1]) end)
		
		ZO_PreHook(ZO_GamepadSmithingCreation,    "SetupResultTooltip", function(tooltip, ...)   modifyTooltip(GetSmithingPatternResultLink(...)) end)
		ZO_PreHook(ZO_GamepadSmithingImprovement,    "SetupResultTooltip", function(tooltip, ...)   modifyTooltip(GetSmithingImprovedItemLink(...)) end)
		ZO_PreHook(ZO_GamepadAlchemy,    "UpdateTooltip", function(tooltip)   modifyTooltip(CheckAlchemyName(tooltip:GetAllCraftingBagAndSlots())) end)
		
		ZO_PreHook(ZO_GamepadEnchanting,    "UpdateTooltip", function(tooltip)
			if tooltip:IsCraftable() then
				modifyTooltip(GetEnchantingResultingItemLink(tooltip:GetAllCraftingBagAndSlots()))
			elseif tooltip:IsExtractable() and tooltip.extractionSlot:HasOneItem() then
				modifyTooltip(GetItemLink(tooltip.extractionSlot:GetItemBagAndSlot(1)))
			end
		end)
		
		ZO_PreHook(ZO_GamepadProvisioner,    "RefreshRecipeDetails", function(tooltip, selectedData)
			if selectedData then
				modifyTooltip(GetRecipeResultItemLink(selectedData.recipeListIndex, selectedData.recipeIndex))
				local prePostHook = tooltip.ingredientsBar.Clear
				ZO_PostHook(tooltip.ingredientsBar, "Clear", function()
					GamepadTooltipPostHook()
					tooltip.ingredientsBar.Clear = prePostHook
				end)
			end
		end)
		
		ZO_PreHook(ZO_GamepadSmithingExtraction,    "RefreshTooltip", function(tooltip)
			if tooltip.extractionSlot:HasOneItem() then
				local bagId, slotIndex = tooltip.extractionSlot:GetItemBagAndSlot(1)
				modifyTooltip(GetItemLink(bagId, slotIndex))
			end
		end)
		
		local prePostHookSm = ZO_GamepadSmithingImprovement.Refresh
		ZO_PreHook(ZO_GamepadSmithingImprovement, "Refresh", function(tooltip, ...)
			ZO_GamepadSmithingImprovement.Refresh = prePostHookSm
			ZO_PreHook(tooltip.sourceTooltip.tip, "LayoutImproveSourceSmithingItem", function(tlt, ...)
				local bagId, slotIndex = ...
				modifyTooltip(GetItemLink(bagId, slotIndex))
			end)
			
			ZO_PostHook(tooltip.sourceTooltip.tip, "LayoutImproveSourceSmithingItem", function(tlt, ...)
				GamepadTooltipPostHook()
			end)
		end)
		
		ZO_PreHook(ZO_RetraitStation_Retrait_Gamepad, "LayoutSourceItemTooltip", function(tooltip, itemData)
			if itemData then
				modifyTooltip(GetItemLink(itemData.bagId, itemData.slotIndex))
			end
		end)
		
		ZO_PreHook(ZO_RetraitStation_Retrait_Gamepad, "LayoutResultItemTooltip", function(tooltip, traitData)
			local itemData = tooltip.inventory:CurrentSelection()
			if itemData and traitData then
				local bagId = itemData.bagId
				local slotIndex = itemData.slotIndex
				local resultItemLink = GetResultingItemLinkAfterRetrait(bagId, slotIndex, traitData.trait)
				modifyTooltip(resultItemLink)
			end
		end)
		
		ZO_PreHook(ZO_RetraitStation_Reconstruct_Gamepad,    "RefreshResultTooltip", function(tooltip)
			if tooltip.itemSetPieceData and tooltip:IsOptionsModeShowing() then
				modifyTooltip(tooltip.itemSetPieceData:GetItemLink())
			end
		end)
		
		-- Gamepad PostHooks
		
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP),   "LayoutItem", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP),   "LayoutItem", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", function()   GamepadTooltipPostHook() end)
		
		ZO_PostHook(ZO_GamepadSmithingCreation,    "SetupResultTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadSmithingImprovement,    "SetupResultTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadAlchemy,    "UpdateTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadEnchanting,    "UpdateTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadProvisioner,    "RefreshRecipeDetails", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_GamepadSmithingExtraction,    "RefreshTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Retrait_Gamepad,    "LayoutSourceItemTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Retrait_Gamepad,    "LayoutResultItemTooltip", function()   GamepadTooltipPostHook() end)
		ZO_PostHook(ZO_RetraitStation_Reconstruct_Gamepad,    "RefreshResultTooltip", function()   GamepadTooltipPostHook() end)
		
		-- Third-party Compatibility
		
		-- Tamriel Trade Centre
		if RuESO:IsAddonRunning("TamrielTradeCentre") then
			if TamrielTradeCentre_ItemInfo then
				ZO_PreHook(TamrielTradeCentre_ItemInfo, "New", function() SafeAddString(SI_TOOLTIP_ITEM_NAME, RuESO.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10) end)
			end
			
			if TamrielTradeCentre_MasterWritInfo then
				ZO_PreHook(TamrielTradeCentre_MasterWritInfo, "New", function() SafeAddString(SI_TOOLTIP_ITEM_NAME, RuESO.StringsBackup["SI_TOOLTIP_ITEM_NAME"], 10) end)
			end
		end
		
		-- Item Set Browser
		if ItemBrowser then
			itemTooltipHook(ExtendedJournalItemTooltip, "SetLink", GetChatLink)
		end

		-- Wish List
		if WishList then
			itemTooltipHook(WishListTooltip, "SetLink", GetChatLink)
		end
	end
	RuESO_doubleNamesItems = nil
end