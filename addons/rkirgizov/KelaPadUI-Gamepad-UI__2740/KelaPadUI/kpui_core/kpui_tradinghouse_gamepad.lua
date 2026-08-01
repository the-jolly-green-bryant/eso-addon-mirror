local lib = LIB_ITEM_LINK
local colors = kpuiConst.Colors	
-- KPUI_ATTGraph = nil

KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX = 1
KELA_CURRENT_SEARCH_TABLE = {}
KELA_TRADINGHOUSE_ITEMCOUNT = 0
KELA_TRADINGHOUSE_SEARCH_WAIT = false

KELA_TRADINGHOUSE_CURRENTSCENE = ""
KELA_TRADINGHOUSE_CURRENT_SELECTEDDATA = {}

local hookCraftingStationAlready = false
local hookCraftingStationKeybindAlready = false
local hookProvisionerTooltipAlready = false
local hookCreationTooltipAlready = false
local hookDeconstructTooltipAlready = false
local hookRefineTooltipAlready = false
local hookAlchemyTooltipAlready = false
local hookEnchantingTooltipAlready = false

				
local hookTradingHouseAlready = false
local hookBankingAlready = false
local hookStoregAlready = false
local hookATTAlready = false

-- local KELA_QUALITY_NORMAL = 366
-- local KELA_QUALITY_FINE = 367
-- local KELA_QUALITY_SUPERIOR = 368
-- local KELA_QUALITY_EPIC = 369
-- local KELA_QUALITY_LEGENDARY = 370

KELA_TRADING_TOOLTIP_TYPE_SMITHING = 1
KELA_TRADING_TOOLTIP_TYPE_TRADINGHOUSE = 2

KELA_SMITHING_IMPROVED_TOOLTIP_TYPE = 0

local function KelaCreateColorizedResumePrice(index)
	local label = GetString("KELA_TRADING_RESUMEPRICE", index)
	if index == 5 then 
		color = colors.COLOR_DEALGREAT
	elseif index == 4 then 
		color = colors.COLOR_DEALGOOD
	elseif index == 3 then 
		color = colors.COLOR_DEALNORMAL
	elseif index == 2 then 
		color = colors.COLOR_WHITE
	elseif index == 1 then 
		return label
	end
	return color:Colorize(label)
end	


function KelaIsSceneTradingHouse(currentScene)
	return (currentScene == "TRADING_HOUSE_CREATE_LISTING_GAMEPAD" or currentScene == "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS" or currentScene == "GAMEPAD_TRADING_HOUSE_LISTINGS" or currentScene == "GAMEPAD_TRADING_HOUSE_SELL")
end




-- local subIdToQuality = { }
local function GetItemLinks(itemLink)

	local function GetQualityItemLink(itemId, itemQuality, itemLevel, itemChampionPoints, enchantId)
		if itemId == nil or itemId == 0 then return end
		-- LibItemLink
		-- Generates an item link
		--- itemId = any itemId of a valid item
		--- itemQuality = number - any valid quality type like ITEM_QUALITY_NORMAL (optional)
		--- itemLevel = number 1-50 - if it's not a champion item, define the level (optional)
		--- itemChampionPoints = number 0-160 - if you want to create a cp item (optional)
		--- itemStyle = number - choose a motif style (optional)
		--- isCrafted = boolean - if it's a crafted item (optional)
		--- enchantId = number 1-unknown - if you want to add any enchantment to your item (optional)
		--- enchantQuality = number - any valid quality type like ITEM_QUALITY_LEGENDARY (optional)
		--- linkStyle = if you want some brackets or not (optional)
		return lib:BuildItemLink(tonumber(itemId), tonumber(itemQuality), tonumber(itemLevel), tonumber(itemChampionPoints), nil, nil, tonumber(enchantId))	
	end
	
	local resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink
	local minLevel, minChampionPoints
	local referenceEnchantID
	local itemType = GetItemLinkItemType(itemLink) 
	local itemId = GetItemLinkItemId(itemLink)
	local referenceQuality = GetItemLinkQuality(itemLink)
	
	-- CHAT_SYSTEM:AddMessage(GetString("SI_ITEMTYPE", itemType))
	
	-- if itemType == ITEMTYPE_RECIPE or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL then
		if itemType == ITEMTYPE_RECIPE then
			resultItemLink = GetItemLinkRecipeResultItemLink(itemLink)
		else
			resultItemLink = GetItemLinkRefinedMaterialItemLink(itemLink)
		end
	-- end

	
	if itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON then
		minLevel, minChampionPoints = GetItemLinkGlyphMinLevels(itemLink)
		referenceEnchantID = GetItemLinkFinalEnchantId(itemLink)
	elseif itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
		minLevel = GetItemLinkRequiredLevel(itemLink)
		minChampionPoints = GetItemLinkRequiredChampionPoints(itemLink)
		referenceEnchantID = GetItemLinkFinalEnchantId(itemLink)
	end

	if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_JEWELRY or itemType == ITEMTYPE_GLYPH_WEAPON or itemType == ITEMTYPE_WEAPON then		
		if referenceQuality ~= ITEM_QUALITY_NORMAL then normalItemLink = GetQualityItemLink(itemId, ITEM_QUALITY_NORMAL, minLevel, minChampionPoints, referenceEnchantID) end
		if referenceQuality ~= ITEM_QUALITY_MAGIC then fineItemLink = GetQualityItemLink(itemId, ITEM_QUALITY_MAGIC, minLevel, minChampionPoints, referenceEnchantID) end
		if referenceQuality ~= ITEM_QUALITY_ARCANE then superiorItemLink = GetQualityItemLink(itemId, ITEM_QUALITY_ARCANE, minLevel, minChampionPoints, referenceEnchantID) end
		if referenceQuality ~= ITEM_QUALITY_ARTIFACT then epicItemLink = GetQualityItemLink(itemId, ITEM_QUALITY_ARTIFACT, minLevel, minChampionPoints, referenceEnchantID) end
		if referenceQuality ~= ITEM_QUALITY_LEGENDARY then legendaryItemLink = GetQualityItemLink(itemId, ITEM_QUALITY_LEGENDARY, minLevel, minChampionPoints, referenceEnchantID) end
	end	

	return resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink

end
local function GetBuyInfo(tblBuyingItems, itemUID)
	local strBuyInfo = ""
	local guildName = tblBuyingItems[itemUID]["guildName"]
	local buyingTime = colors.COLOR_WHITE:Colorize(KelaTimeStampToDateTimeString(tblBuyingItems[itemUID]["buyingTimeStamp"]))
	local buyPrice = tblBuyingItems[itemUID]["buyPrice"]
	local buyPricePerUnit = tblBuyingItems[itemUID]["buyPricePerUnit"]
	local buyStackCount = KelaLocalizedFormatNumber(buyPrice/buyPricePerUnit)
	local iconCoin = zo_iconFormat(GetCurrencyGamepadIcon(CURT_MONEY), 20, 20)
	strBuyInfo = "* "..GetString(KELA_TRADING_BOUGHT)..buyingTime..GetString(KELA_TRADING_BOUGHT_FOR)..colors.COLOR_WHITE:Colorize(KelaLocalizedFormatNumber(buyPrice)..iconCoin)
	-- if buyPrice ~= buyPricePerUnit then
		strBuyInfo = strBuyInfo.." ("..buyStackCount.."*"..KelaLocalizedFormatNumber(buyPricePerUnit)..")"
	-- end					
	if guildName ~= "" then
		local guildColor = colors.COLOR_WHITE
		if ArkadiusTradeTools ~= nil then
			guildColor = ArkadiusTradeTools:GetGuildColor(guildName)
		end
		guildName = guildColor:Colorize(guildName)					
		strBuyInfo = strBuyInfo.." в гильдии "..guildName
	end

	local colorQuality
	local strQuality = ""
	local displayQuality = tblBuyingItems[itemUID]["displayQuality"]
	local itemType = GetItemLinkItemType(itemLink)
	if displayQuality and (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON) then 
		colorQuality = GetItemQualityColor(displayQuality) 
		strBuyInfo = strBuyInfo.." ("..colorQuality:Colorize(GetString("SI_ITEMDISPLAYQUALITY", displayQuality))..")"
	end	
	return strBuyInfo
end
local function HideTradingTooltipControls()
	if ctlItemTypeGuildStat then ctlItemTypeGuildStat:SetHidden(true) end	
	if ctlTradingInfo then ctlTradingInfo:SetHidden(true) end						
	if KPUI_ATTGraph then KPUI_ATTGraph:SetHidden(true) end	
	if ctlPreviousListings then ctlPreviousListings:SetHidden(true) end		
	if ctlOtherQualityInfo then ctlOtherQualityInfo:SetHidden(true) end				
	if ctlProductMaterialInfoRow then ctlProductMaterialInfoRow:SetHidden(true) end	
	if ctlCraftingInfo then ctlCraftingInfo:SetHidden(true) end			
end
local function HideImprovementTooltipControls(hide)
	local function hideSource()
		if ctlSourceInfo then ctlSourceInfo:SetHidden(true) end	
		if ctlSourceGraph then ctlSourceGraph:SetHidden(true) end					
		if ctlSourceNotes then ctlSourceNotes:SetHidden(true) end
		if ctlSourceListings then ctlSourceListings:SetHidden(true) end	
		if ctlSourceOther then ctlSourceOther:SetHidden(true) end	
	end
	local function hideResult()
		if ctlResultInfo then ctlResultInfo:SetHidden(true) end						
		if ctlResultGraph then ctlResultGraph:SetHidden(true) end	
		if ctlResultNotes then ctlResultNotes:SetHidden(true) end
		if ctlResultListings then ctlResultListings:SetHidden(true) end	
		if ctlResultOther then ctlResultOther:SetHidden(true) end	
	end
	if hide == "source" then
		hideSource()
	elseif hide == "result" then
		hideResult()
	else
		hideSource()
		hideResult()
	end
end
local function HideProvisionerTooltipControls()
	if ctlProvisionerInfo then ctlProvisionerInfo:SetHidden(true) end	
	if ctlProvisionerGraph then ctlProvisionerGraph:SetHidden(true) end						
	if ctlProvisionerListings then ctlProvisionerListings:SetHidden(true) end				
end
local function HideCreationTooltipControls()
	if ctlCreationInfo then ctlCreationInfo:SetHidden(true) end	
	if ctlCreationGraph then ctlCreationGraph:SetHidden(true) end						
	if ctlCreationListings then ctlCreationListings:SetHidden(true) end					
	if ctlCreationOther then ctlCreationOther:SetHidden(true) end				
end
local function HideAlchemyTooltipControls()
	if ctlAlchemyInfo then ctlAlchemyInfo:SetHidden(true) end	
	if ctlAlchemyGraph then ctlAlchemyGraph:SetHidden(true) end						
	if ctlAlchemyListings then ctlAlchemyListings:SetHidden(true) end					
end
local function HideEnchantingTooltipControls()
	if ctlEnchantingInfo then ctlEnchantingInfo:SetHidden(true) end	
	if ctlEnchantingGraph then ctlEnchantingGraph:SetHidden(true) end						
	if ctlEnchantingListings then ctlEnchantingListings:SetHidden(true) end	
	if ctlEnchantingOther then ctlEnchantingOther:SetHidden(true) end		
end

-- функции добавления модулей в информационное окошко
local function AddClearLine(tooltip, lastControl, x, y)
	-- пустая строка
	if not x then x = 0 end
	if not y then y = 0 end
	local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
	bodySection:AddLine(" ")
	-- bodySection:AddLine(" ")
	tooltip:AddSection(bodySection)
	bodySection:ClearAnchors()
	bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, x, y)
	bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, x, y)					
	return bodySection
end
local function SetSmithTradingInfo (ctlSmithTradingInfo, lastControl, priceInfoTTC, priceInfoATT, currentScene, selectedData, stackCount)
	ctlSmithTradingInfo:ClearAnchors()
	ctlSmithTradingInfo:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 15)
	ctlSmithTradingInfo:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 15)
	ctlSmithTradingInfo:SetHidden(false)
	return ctlSmithTradingInfo.SetItemInfo(priceInfoTTC, priceInfoATT, currentScene, selectedData, stackCount)
end
local function SetSmithGraph (ctlSmithGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, stackCount)
	ctlSmithGraph:ClearAnchors()
	ctlSmithGraph:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 10, 0)
	ctlSmithGraph:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, -10, 0)
	KelaUpdateATTGraph(itemLink, ctlSmithGraph, priceInfoATT.SuggestedPrice, priceInfoTTC.SuggestedPrice)
	ctlSmithGraph:SetHidden(false)
	local stackCountGuild
	if priceInfoATT.Vouchers ~= 0 then
		stackCountGuild = priceInfoATT.Vouchers
	else
		stackCountGuild = stackCount
	end
	return ctlSmithGraph.SetGuildSalesInfo(priceInfoATT.GuildsInfo, priceInfoATT.GuildsPrice, stackCountGuild, ctlSmithGraph)	
end
local function SetSmithNotes (tooltip, lastControl, strBuyInfo, ModFontSize)
	if not ModFontSize then ModFontSize = 20 end
	local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
	bodySection:AddLine(strBuyInfo, {fontSize = ModFontSize})
	tooltip:AddSection(bodySection)
	bodySection:ClearAnchors()
	bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
	bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
	return bodySection
end
local function SetSmithListings (ctlSmithListings, lastControl, listingItemsTable)
	ctlSmithListings:SetHidden(false)					
	return ctlSmithListings.SetPreviousListings(listingItemsTable, lastControl)
end
local function SetSmithQualityPrices(tooltip, ctlSmithOQInfo, lastControl, itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink) --, traitInformation, tooltip)
	lastControl = AddClearLine(tooltip, lastControl, 0, 15)
	ctlSmithOQInfo:SetHidden(false)	
	return ctlSmithOQInfo.SetOtherQualityPrices(itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink, lastControl)
end
local function SetProductionPrices(ctlProductionInfo, lastControl, resultItemLink, priceInfoTTC, priceInfoATT)
	ctlProductionInfo:SetHidden(false)	
	return ctlProductionInfo.SetRawProductPrices(resultItemLink, priceInfoTTC, priceInfoATT, lastControl)
end
local function SetCraftingComponents(ctlCraftingInfo, lastControl, craftingComponentPrices)
	ctlCraftingInfo:SetHidden(false)	
	return ctlCraftingInfo.SetItemPrices(craftingComponentPrices, lastControl)
end

--проверка настройки и торгового модуля
local function IsKPUITradingHouseSettingEnabled(setting)
	if setting then 
		return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ENABLED)	and KelaGetSetting_Bool(SETTING_TYPE_KELA, setting)		
	else
		return KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ENABLED)
	end
end
function KelaSetupCraftingStation()

	if not hookCraftingStationAlready then

		-- крафт алхимии
		ZO_PreHook(ZO_GamepadAlchemy, "UpdateTooltip", function(control, ...)
				local ingredientsBar = control.control:GetNamedChild("SlotContainer")
				-- настройка
				if not hookAlchemyTooltipAlready then
					control.tooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
					control.tooltip.tip:SetStyles(control.tooltip.tip:GetStyle("tooltip"))
					ingredientsBar:ClearAnchors()
					ingredientsBar:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PROVISIONER_INGREDIENTS_BAR_OFFSET_X, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET + 30)
					control.tooltip:ClearAnchors()
					control.tooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -25)	
					if not ctlAlchemyTooltip then ctlAlchemyTooltip = CreateControlFromVirtual("$(parent)TradingTip", control.tooltip, "KPUI_CraftingTooltip") end
					ctlAlchemyTooltip:ClearAnchors()
					ctlAlchemyTooltip:SetAnchor(BOTTOMLEFT, control.tooltip, BOTTOMRIGHT, 38)
					ctlAlchemyTooltip:SetHidden(true)
					GAMEPAD_ALCHEMY_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
						if newState == SCENE_HIDDEN then
							if ctlAlchemyTooltip then 
								ctlAlchemyTooltip.tip:ClearLines()
								ctlAlchemyTooltip:SetHidden(true) 
							end
						end
					end)
					hookAlchemyTooltipAlready = true
				end	
			-- if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ENABLED) then
				if control:IsCraftable() then
					control.tooltip:SetHidden(false)
					control.tooltip.tip:ClearLines()
					local solventBagId, solventSlotIndex, reagent1BagId, reagent1SlotIndex, reagent2BagId, reagent2SlotIndex, reagent3BagId, reagent3SlotIndex = control:GetAllCraftingBagAndSlots()
					local itemLink, prospectiveAlchemyResult = GetAlchemyResultingItemLink(solventBagId, solventSlotIndex, reagent1BagId, reagent1SlotIndex, reagent2BagId, reagent2SlotIndex, reagent3BagId, reagent3SlotIndex)
					local solventType = GetItemType(solventBagId, solventSlotIndex)
					local itemTypeString = GetString(solventType == ITEMTYPE_POTION_BASE and SI_ITEM_FORMAT_STR_POTION or SI_ITEM_FORMAT_STR_POISON)
					control.tooltip.tip:LayoutAlchemyPreview(itemLink, itemTypeString, prospectiveAlchemyResult)
					if ctlAlchemyTooltip and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then 
						if itemLink and prospectiveAlchemyResult > 1 then
							control.tooltip:ClearAnchors()
							control.tooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, -254, -25)
							local maxIterations = GetMaxIterationsPossibleForAlchemyItem(control:GetAllCraftingBagAndSlots())
							ZO_Tooltip:LayoutAlchemyTradingTooltip(ctlAlchemyTooltip, itemLink, maxIterations)
							ctlAlchemyTooltip:SetHidden(false) 
						else
							control.tooltip:ClearAnchors()
							control.tooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -25)						
							ctlAlchemyTooltip.tip:ClearLines()
							ctlAlchemyTooltip:SetHidden(true) 
						end
					else
						control.tooltip:ClearAnchors()
						control.tooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -25)						
						if ctlAlchemyTooltip then					
							ctlAlchemyTooltip.tip:ClearLines()
							ctlAlchemyTooltip:SetHidden(true) 					
						end
					end
				else
					control.tooltip:SetHidden(true)
					if ctlAlchemyTooltip and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then 
						ctlAlchemyTooltip.tip:ClearLines()
						ctlAlchemyTooltip:SetHidden(true) 
					end
				end
				return true
			-- else
				-- control.tooltip:ClearAnchors()
				-- control.tooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -25)	
			-- end
		end)

		-- зачарование
		ZO_PreHook(ZO_GamepadEnchanting, "UpdateTooltip", function(control, ...)
			local ingredientsBar = control.control:GetNamedChild("RuneSlotContainer")
			local function KelaOnSelectedDataChangedCallback (list, selectedData)
				if selectedData and selectedData.bagId and selectedData.slotIndex then
					local SHOW_COMBINED_COUNT = true
					GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, selectedData.bagId, selectedData.slotIndex, SHOW_COMBINED_COUNT)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
						local itemLink = GetItemLink(selectedData.bagId, selectedData.slotIndex)
						local itemUniqueId = GetItemUniqueId(selectedData.bagId, selectedData.slotIndex)
						local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl
						KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_ENCHANTING_EXTRACTION", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 7, nil, itemUniqueId)		
					end
				else
					GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end					
			end
			-- настройка
			if not hookEnchantingTooltipAlready then
				control.resultTooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
				control.resultTooltip.tip:SetStyles(control.resultTooltip.tip:GetStyle("tooltip"))
				ingredientsBar:ClearAnchors()
				ingredientsBar:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PROVISIONER_INGREDIENTS_BAR_OFFSET_X, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET + 30)
				if not ctlEnchantingTooltip then ctlEnchantingTooltip = CreateControlFromVirtual("$(parent)TradingTip", control.resultTooltip, "KPUI_CraftingTooltip") end
				ctlEnchantingTooltip:SetHidden(true)
				GAMEPAD_ENCHANTING_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
					if newState == SCENE_HIDDEN then
						if ctlEnchantingTooltip and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then 
							ctlEnchantingTooltip.tip:ClearLines()
							ctlEnchantingTooltip:SetHidden(true) 
						end
					end
				end)
				GAMEPAD_ENCHANTING_EXTRACTION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
					if newState == SCENE_SHOWING then
						control.inventory.list:SetOnSelectedDataChangedCallback(KelaOnSelectedDataChangedCallback)
						KelaOnSelectedDataChangedCallback (control.inventory.list, control.inventory.list:GetSelectedData())
					elseif newState == SCENE_HIDDEN then
						control.inventory.list:RemoveOnSelectedDataChangedCallback(KelaOnSelectedDataChangedCallback)
					end
				end)	
				hookEnchantingTooltipAlready = true
			end	
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				control.resultTooltip:ClearAnchors()
				control.resultTooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, -254, -25)
				if ctlEnchantingTooltip then
					ctlEnchantingTooltip:ClearAnchors()
					ctlEnchantingTooltip:SetAnchor(BOTTOMLEFT, control.resultTooltip, BOTTOMRIGHT, 38)
				end
			else
				control.resultTooltip:ClearAnchors()
				control.resultTooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -25)
				if ctlEnchantingTooltip then ctlEnchantingTooltip:SetHidden(true) end
			end
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				control.extractionSlotContainer:ClearAnchors()
				control.extractionSlotContainer:SetAnchor(CENTER, GuiRoot, CENTER, 740, 300)
			else
				control.extractionSlotContainer:ClearAnchors()
				control.extractionSlotContainer:SetAnchor(CENTER, GuiRoot, CENTER, 370, 300)			
			end
			if control:IsCraftable() then
				control.resultTooltip:SetHidden(false)
				control.resultTooltip.tip:ClearLines()
				control.resultTooltip.tip:LayoutEnchantingPreview(control:GetAllCraftingBagAndSlots())
				if ctlEnchantingTooltip and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then 
					local itemLink = GetEnchantingResultingItemLink(control:GetAllCraftingBagAndSlots())				
					local maxIterations = GetMaxIterationsPossibleForEnchantingItem(control:GetAllCraftingBagAndSlots())				
					ZO_Tooltip:LayoutEnchantingTradingTooltip(ctlEnchantingTooltip, itemLink, maxIterations)
					ctlEnchantingTooltip:SetHidden(false) 
				end
			elseif control:IsExtractable() and control.extractionSlot:HasOneItem() then
			else
				control.resultTooltip:SetHidden(true)
				if ctlEnchantingTooltip and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then 
					ctlEnchantingTooltip.tip:ClearLines()
					ctlEnchantingTooltip:SetHidden(true) 
				end
			end
			return true
		end)

		-- крафт по рецептам
		ZO_PreHook(ZO_GamepadProvisioner, "RefreshRecipeDetails", function(control, selectedData, ...)
			-- настройка
			if not hookProvisionerTooltipAlready then
				control.resultTooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
				control.resultTooltip.tip:SetStyles(control.resultTooltip.tip:GetStyle("tooltip"))
				if not ctlProvisionerTooltip then ctlProvisionerTooltip = CreateControlFromVirtual("$(parent)TradingTip", control.resultTooltip, "KPUI_CraftingTooltip") end
				ctlProvisionerTooltip:ClearAnchors()
				ctlProvisionerTooltip:SetAnchor(BOTTOMLEFT, control.resultTooltip, BOTTOMRIGHT, 26)
				ctlProvisionerTooltip:SetHidden(false)
				hookProvisionerTooltipAlready = true
			end	
			local ingredientsBar = control.control:GetNamedChild("IngredientsBar")
			ingredientsBar:ClearAnchors()
			control.resultTooltip:ClearAnchors()
			ingredientsBar:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PROVISIONER_INGREDIENTS_BAR_OFFSET_X, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET + 80)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				control.resultTooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, -248, -75)
			else
				control.resultTooltip:SetAnchor(BOTTOM, ingredientsBar, TOP, 0, -75)
			end
		end)
		SecurePostHook(ZO_GamepadProvisioner, "RefreshRecipeDetails", function(control, selectedData, ...)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				if selectedData then
					local recipeListIndex, recipeIndex = selectedData.recipeListIndex, selectedData.recipeIndex
					-- торговая подсказка
					if ctlProvisionerTooltip then 
						ZO_Tooltip:LayoutProvisionerTradingTooltip(ctlProvisionerTooltip, recipeListIndex, recipeIndex, selectedData)
						ctlProvisionerTooltip:SetHidden(false)
					end
				end
			else
				if ctlProvisionerTooltip then ctlProvisionerTooltip:SetHidden(true) end
			end
		end)

		-- создание аммуниции
		ZO_PreHook(ZO_GamepadSmithingCreation, "SetupResultTooltip", function(control, selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex, ...)
			-- настройка
			if not hookCreationTooltipAlready then
				control.resultTooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
				control.resultTooltip.tip:SetStyles(control.resultTooltip.tip:GetStyle("tooltip"))
				if not ctlCreationTooltip then ctlCreationTooltip = CreateControlFromVirtual("$(parent)TradingTip", control.resultTooltip, "KPUI_CraftingTooltip") end
				ctlCreationTooltip:ClearAnchors()
				ctlCreationTooltip:SetAnchor(LEFT, control.resultTooltip, RIGHT, 26)				
				ctlCreationTooltip:SetHidden(true)
				hookCreationTooltipAlready = true
			end	
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				control.resultTooltip:ClearAnchors()
				control.resultTooltip:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)				
				ctlCreationTooltip:SetHidden(false)
			else
				control.resultTooltip:ClearAnchors()
				control.resultTooltip:SetAnchor(CENTER, GuiRoot, LEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_SHOWN, ZO_GAMEPAD_PANEL_FLOATING_CENTER_OFFSET_Y)	
				ctlCreationTooltip:SetHidden(true)
			end
			control.resultTooltip.tip:LayoutPendingSmithingItem(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
				local itemLink = GetSmithingPatternResultLink(selectedPatternIndex, selectedMaterialIndex, selectedMaterialQuantity, selectedStyleId, selectedTraitIndex)
				if itemLink and itemLink ~= "" then 
					ZO_Tooltip:LayoutSmithingCreationTooltip(ctlCreationTooltip, itemLink) 
				end
			end
			return true
		end)

		-- разбор и переработка
		SecurePostHook(ZO_GamepadSmithingExtraction, "UpdateSelection", function(control, ...)
			control.slotContainer:ClearAnchors()
			-- if CRAFT_ADVISOR_MANAGER:HasActiveWrits() then
				-- control.slotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, GAMEPAD_SMITHING_EXTRACTION_CRAFTING_QUEST_OFFSET_X, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
			-- else
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
					control.slotContainer:SetAnchor(CENTER, GuiRoot, CENTER, 740, 300)
				else
					control.slotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_2_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)				
				end
			-- end
			-- настройка
			if (SCENE_MANAGER:IsShowing("gamepad_smithing_deconstruct") and not hookDeconstructTooltipAlready) or (SCENE_MANAGER:IsShowing("gamepad_smithing_refine") and not hookRefineTooltipAlready) then
				control.slotContainer:GetNamedChild("ExtractionSlot"):GetNamedChild("Name"):SetFont("ZoFontGamepadCondensed34")
				control.tooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
				control.tooltip.tip:SetStyles(control.tooltip.tip:GetStyle("tooltip"))

				control.inventory.list:RemoveAllOnSelectedDataChangedCallbacks()
				control.inventory.list:SetOnSelectedDataChangedCallback(function(list, selectedData)
					KEYBIND_STRIP:UpdateKeybindButtonGroup(control.keybindStripDescriptor)
					control.itemActions:SetInventorySlot(selectedData)
					if selectedData and selectedData.bagId and selectedData.slotIndex then
						local SHOW_COMBINED_COUNT = true
						GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_LEFT_TOOLTIP, selectedData.bagId, selectedData.slotIndex, SHOW_COMBINED_COUNT)
						if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
							local itemLink = GetItemLink(selectedData.bagId, selectedData.slotIndex)
							local itemUniqueId = GetItemUniqueId(selectedData.bagId, selectedData.slotIndex)
							local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl
							KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
							KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_SMITHING_EXTRACTION", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 7, nil, itemUniqueId)		
						else
							KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						end
					else
						GAMEPAD_TOOLTIPS:ClearLines(GAMEPAD_LEFT_TOOLTIP)
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end)
				if SCENE_MANAGER:IsShowing("gamepad_smithing_deconstruct") then
					hookDeconstructTooltipAlready = true
				elseif SCENE_MANAGER:IsShowing("gamepad_smithing_refine") then 
					hookRefineTooltipAlready = true
				end
			end
		end)
		ZO_PreHook(ZO_GamepadSmithingExtraction, "RefreshTooltip", function(control, ...)
			if control.extractionSlot:HasOneItem() then
			else
				control.tooltip:SetHidden(true)
			end
			return true
		end)

		--	сцена улучшения
		ZO_PreHook(ZO_GamepadSmithingImprovement, "UpdateSelection", function(control, ...)
			-- Настройка
			if not hookCraftingStationKeybindAlready then
				control.sourceTooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES				
				control.resultTooltip.tip.styleNamespace = ZO_TOOLTIP_STYLES
				control.sourceTooltip.tip:SetStyles(control.sourceTooltip.tip:GetStyle("tooltip"))
				control.resultTooltip.tip:SetStyles(control.resultTooltip.tip:GetStyle("tooltip"))	
				-- set up inventory keybinds and tooltips
				control.inventory.list:RemoveAllOnSelectedDataChangedCallbacks()
				control.inventory.list:SetOnSelectedDataChangedCallback(function(list, selectedData)
					KEYBIND_STRIP:UpdateKeybindButtonGroup(control.keybindStripDescriptor)
					control.itemActions:SetInventorySlot(selectedData)
					if selectedData and selectedData.bagId and selectedData.slotIndex then
						local itemUniqueId = GetItemUniqueId(selectedData.bagId, selectedData.slotIndex)
						ZO_Tooltip:LayoutSmithingTradingTooltip(control.sourceTooltip, selectedData.bagId, selectedData.slotIndex, nil, itemUniqueId, selectedData)
						control:Refresh()
						-- selectedData.quality is deprecated, included here for addon backwards compatibility
						local functionalQuality = selectedData.functionalQuality or selectedData.quality
						control:ColorizeText(control:GetBoosterRowForQuality(functionalQuality))
						control.selectedItem = selectedData
						if not control:HasSelections() then
							control.resultTooltip:SetHidden(true)
							control.slotContainer:SetHidden(true)
							control:EnableQualityBridge(false)
						end
						control:SetInventoryActive(true)
						if control.shouldActivateTabBar then
							ZO_GamepadGenericHeader_Activate(control.owner.header)
						end
						control.spinner:Deactivate()
						GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(control.resultTooltip)
						GAMEPAD_CRAFTING_RESULTS:SetTooltipAnimationSounds(ZO_SharedSmithingImprovement_GetImprovementTooltipSounds())
						GAMEPAD_CRAFTING_RESULTS:ClearSecondaryTooltipAnimationControls()
						GAMEPAD_CRAFTING_RESULTS:AddSecondaryTooltipAnimationControl(control.sourceTooltip)
						GAMEPAD_CRAFTING_RESULTS:AddSecondaryTooltipAnimationControl(control.qualityBridge)
					else
						control.sourceTooltip.tip:ClearLines()
						control.sourceTooltip:SetHidden(true)
						GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(nil)
						control:ClearBoosterRowHighlight()
						control.selectedItem = nil
						control:Refresh()
					end
				end)
				KelaPadUI.kelaCraftingKeybindStripDescriptor =
					{
						-- Переключение подсказки
						{
							alignment = KEYBIND_STRIP_ALIGN_CENTER,	
							name = function()
								return GetString(KELA_TRADING_VIEW_MODE)
							end,
							keybind = "UI_SHORTCUT_RIGHT_STICK",
							visible = function() return true end,
							callback = function() 
								local bagId, slotIndex
								if control.improvementSlot:HasItem() then
									bagId, slotIndex = control.improvementSlot:GetBagAndSlot()
								end
								if KELA_SMITHING_IMPROVED_TOOLTIP_TYPE == 0 then
									KELA_SMITHING_IMPROVED_TOOLTIP_TYPE = 1
								else
									KELA_SMITHING_IMPROVED_TOOLTIP_TYPE = 0
								end
								control:SetupResultTooltip(bagId, slotIndex, GetCraftingInteractionType())
							end,
						},		
					}			
				GAMEPAD_SMITHING_IMPROVEMENT_SCENE:RegisterCallback("StateChange", function(oldState, newState) 
					-- states: hiding, showing, shown, hidden
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
						if(newState == "showing") then
							KEYBIND_STRIP:AddKeybindButtonGroup(KelaPadUI.kelaCraftingKeybindStripDescriptor)
						elseif(newState == "hiding") then
							KEYBIND_STRIP:RemoveKeybindButtonGroup(KelaPadUI.kelaCraftingKeybindStripDescriptor)
						end
					end
				end) 
				hookCraftingStationKeybindAlready = true
			end	
			if control.selectedItem then
				-- control.selectedItem.quality is deprecated, included here for addon backwards compatibility
				local functionalQuality = control.selectedItem.functionalQuality or control.selectedItem.quality
				control:ColorizeText(control:GetBoosterRowForQuality(functionalQuality))
			else
				control:ClearBoosterRowHighlight()
			end
			control.inventory:PerformFullRefresh()
			return true
		end)
		ZO_PreHook(ZO_GamepadSmithingImprovement, "SetupResultTooltip", function(control, itemToImproveBagId, itemToImproveSlotIndex, craftingSkillType, ...)
			-- source item
			local bagId, slotIndex
			if control.improvementSlot:HasItem() then
				bagId, slotIndex = control.improvementSlot:GetBagAndSlot()
			else
				local selectedData = control.selectedItem
				if selectedData and selectedData.bagId and selectedData.slotIndex then
					bagId = selectedData.bagId
					slotIndex = selectedData.slotIndex
				end
			end
			local itemUniqueId = GetItemUniqueId(bagId, slotIndex)
			ZO_Tooltip:LayoutSmithingTradingTooltip(control.sourceTooltip, bagId, slotIndex, nil, itemUniqueId, selectedData)
			-- result item
			local itemUniqueId = GetItemUniqueId(itemToImproveBagId, itemToImproveSlotIndex)
			ZO_Tooltip:LayoutSmithingTradingTooltip(control.resultTooltip, itemToImproveBagId, itemToImproveSlotIndex, craftingSkillType, itemUniqueId, selectedData)
			return true
		end)
		hookCraftingStationAlready = true
	end
end	

local SearchAdditionalDelay = 1000
function KelaSetupTradingHouse()
	-- ожидаем инициации баз по торговле
	if not kpuiSVBuyingData or not kpuiSVListingData then
		zo_callLater(KelaSetupTradingHouse, SearchAdditionalDelay)
		return
	end
	
	-- настраиваем гильдейский магазин
	SecurePostHook(ZO_GamepadTradingHouse, "OpenTradingHouse", function()
		if not hookTradingHouseAlready then
			-- скрываем при смене листа
			SecurePostHook(ZO_GamepadTradingHouse, "SetCurrentListObject", function(control, listObject, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
				end
			end)
			-- окно продажи
			SecurePostHook(GAMEPAD_TRADING_HOUSE_SELL, "UpdateItemSelectedTooltip", function(control, selectedData, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					if selectedData then
						local bag, index = ZO_Inventory_GetBagAndIndex(selectedData)
						
						local itemUniqueId = GetItemUniqueId(bag, index)
						-- CHAT_SYSTEM:AddMessage("itemUniqueId  "..tostring(itemUniqueId))						
						
						local itemLink = GetItemLink(bag, index)
						local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl
						KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_TRADING_HOUSE_SELL", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5, nil, itemUniqueId)		
					else
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end		
				end
			end)
			-- скрываем при выходе с листа
			SecurePostHook(GAMEPAD_TRADING_HOUSE_SELL, "OnHiding", function(control, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
				end
			end)
			-- окно активного листинга
			SecurePostHook(GAMEPAD_TRADING_HOUSE_LISTINGS, "UpdateItemSelectedTooltip", function(control, selectedData, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					if selectedData then
						local itemLink = selectedData.itemLink
						local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
						KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_TRADING_HOUSE_LISTINGS", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5)		
					else
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end
			end)
			-- ОКНО ПОИСКА
			-- добавляем кнопки фильтрации по оценке сделки
			SecurePostHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "OnShowing", function(control, ...)
				local keybind  =
				{
					alignment = KEYBIND_STRIP_ALIGN_LEFT,	
					name = "Name",
					keybind = "UI_SHORTCUT_RIGHT_STICK",
					callback = function()
							KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX = (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX == 5) and 1 or (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX + 1)
							control:Deactivate()
							control:FilterScrollList()
							ZO_SortFilterList.CommitScrollList(control)
							KELA_TRADINGHOUSE_SEARCH_WAIT = false
							control:RefreshPagingControls()
							control:UpdateKeybinds()
							control:Activate()
						end,
					ethereal = true,
				}
				control:AddUniversalKeybind(keybind)
				if not KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					local keybind  =
					{
						name = "Gamepad Interactive Sort Filter List Left Trigger",
						keybind = "UI_SHORTCUT_LEFT_TRIGGER",
						ethereal = true,
						callback = function()
							control:OnLeftTrigger()
						end,
					}
					control:AddUniversalKeybind(keybind)

					local keybind  =
					{
						name = "Gamepad Interactive Sort Filter List Right Trigger",
						keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
						ethereal = true,
						callback = function()
							control:OnRightTrigger()
						end,
					}
					control:AddUniversalKeybind(keybind)
				end
				-- убираем кнопку предпросмотра
				for k, v in pairs(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.keybindStripDescriptor) do
					if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
						if v.name == GetString(SI_CRAFTING_ENTER_PREVIEW_MODE) then 
							v.visible = function() return false end					
							break
						end
					else
						if v.name == GetString(SI_CRAFTING_ENTER_PREVIEW_MODE) then 
							v.visible = function()
								local selectedData = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS:GetSelectedData()
								return selectedData and GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS:CanPreviewTradingHouseItem(selectedData)
							end				
							break
						end					
					end
				end			
				ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "OnLeftTrigger", function(control, ...)
					if IsKPUITradingHouseSettingEnabled() then
						if not KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
							TRADING_HOUSE_SEARCH:SearchPreviousPage()
						end
						return true
					end
				end)
				ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "OnRightTrigger", function(control, ...)
					if IsKPUITradingHouseSettingEnabled() then
						if not KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
							TRADING_HOUSE_SEARCH:SearchNextPage()
						end
						return true
					end
				end)
			end)
			-- добавляем торговое сообщение
			SecurePostHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "UpdateItemSelectedTooltip", function(control, selectedData, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					if selectedData then
						local itemLink
						if selectedData.isGuildSpecificItem then
							itemLink = GetGuildSpecificItemLink(selectedData.slotIndex)
						else
							itemLink = selectedData.itemLink
						end
						local parentControl = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.control
						KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						local customScale = GetUICustomScale()
						if customScale > 0.8 then
							KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, true, 50)		
						else
							KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 45)	
						end
					else
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end
			end)
			-- оставляем видимость кнопок перелистывания на заголовках
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "RefreshPagingControls", function(control, ...)
				if IsKPUITradingHouseSettingEnabled() then
					if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
						local prevButton = control.footer.previousButton
						local nextButton = control.footer.nextButton
						prevButton:SetEnabled(false)
						nextButton:SetEnabled(false)
						prevButton:SetHidden(true)
						nextButton:SetHidden(true)
						local scrollData = ZO_ScrollList_GetDataList(control.list)
						if KELA_TRADINGHOUSE_SEARCH_WAIT == false and next(scrollData) == nil and #KELA_CURRENT_SEARCH_TABLE ~= 0 then
							control:SetEmptyText(colors.COLOR_WHITE:Colorize("0")..GetString(KELA_TRADING_TRADING_NOTEFFECTLOTS)..colors.COLOR_WHITE:Colorize(tostring(#KELA_CURRENT_SEARCH_TABLE)))		
						elseif KELA_TRADINGHOUSE_SEARCH_WAIT == true and #KELA_CURRENT_SEARCH_TABLE ~= 0 then
							control:SetEmptyText(GetString("SI_TRADINGHOUSESEARCHSTATE", 1).." "..colors.COLOR_WHITE:Colorize(tostring(#KELA_CURRENT_SEARCH_TABLE)))						
						end						
						control.footer.pageNumberLabel:SetHidden(false)
						local pageNumberLabel = tostring(#KELA_CURRENT_SEARCH_TABLE)
						if KELA_TRADINGHOUSE_ITEMCOUNT ~= 0 then 
							pageNumberLabel = tostring(KELA_TRADINGHOUSE_ITEMCOUNT).." / "..pageNumberLabel 
						end
						control.footer.pageNumberLabel:SetText(pageNumberLabel)
					else
						--IsPanelFocused ignores activated or not which matters here
						local enablePrevious = TRADING_HOUSE_SEARCH:HasPreviousPage() -- control:IsPanelFocused() 
						local enableNext = TRADING_HOUSE_SEARCH:HasNextPage() -- control:IsPanelFocused() and 
						local hideButtons = not (TRADING_HOUSE_SEARCH:HasPreviousPage() or TRADING_HOUSE_SEARCH:HasNextPage())
						local showPageNumber = not hideButtons
						local prevButton = control.footer.previousButton
						local nextButton = control.footer.nextButton
						prevButton:SetEnabled(enablePrevious)
						nextButton:SetEnabled(enableNext)
						prevButton:SetHidden(hideButtons)
						nextButton:SetHidden(hideButtons)
						local scrollData = ZO_ScrollList_GetDataList(control.list)
						if next(scrollData) == nil then
							if TRADING_HOUSE_SEARCH.numItemsOnPage == 0 then
								-- control:SetEmptyText("")
							else
								control:SetEmptyText(colors.COLOR_WHITE:Colorize("0")..GetString(KELA_TRADING_TRADING_NOTEFFECTLOTS)..colors.COLOR_WHITE:Colorize(tostring(TRADING_HOUSE_SEARCH.numItemsOnPage)))		
							end
						else
							control:SetEmptyText(GetString("SI_TRADINGHOUSESEARCHSTATE", 1))						
						end						
						if showPageNumber then
							control.footer.pageNumberLabel:SetHidden(false)
							control.footer.pageNumberLabel:SetText(tostring(#scrollData).." / "..tostring(TRADING_HOUSE_SEARCH.numItemsOnPage)..GetString(KELA_TRADING_TRADING_PAGES)..zo_strformat(SI_GAMEPAD_PAGED_LIST_PAGE_NUMBER, TRADING_HOUSE_SEARCH:GetPage() + 1)) -- Pages start at 0, offset by 1 for expected display number
						else
							control.footer.pageNumberLabel:SetHidden(true)
						end
					end
					return true	
				end
			end)
			-- текст пустого списка
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "OnSearchStateChanged", function(control, searchState, searchOutcome, ...)
				if IsKPUITradingHouseSettingEnabled() then
					local shouldActivateBrowseResults = false
					local shouldDeactivateBrowseResults = false
					if searchState == TRADING_HOUSE_SEARCH_STATE_NONE then
						control:SetEmptyText("")
						KELA_TRADINGHOUSE_SEARCH_WAIT = false
						control:RefreshPagingControls()
					elseif searchState == TRADING_HOUSE_SEARCH_STATE_WAITING then
						control:SetEmptyText(GetString("SI_TRADINGHOUSESEARCHSTATE", searchState))
					elseif searchState == TRADING_HOUSE_SEARCH_STATE_COMPLETE then
						if searchOutcome == TRADING_HOUSE_SEARCH_OUTCOME_HAS_RESULTS then
							control:DeselectListData()
							shouldActivateBrowseResults = true
							KELA_TRADINGHOUSE_SEARCH_WAIT = false
							control:RefreshPagingControls(control)
						else
							control:SetEmptyText(GetString("SI_TRADINGHOUSESEARCHOUTCOME", searchOutcome))
							shouldDeactivateBrowseResults = (searchOutcome == TRADING_HOUSE_SEARCH_OUTCOME_ALL_RESULTS_PURCHASED)
						end
					end
					control:RefreshData()
					if TRADING_HOUSE_GAMEPAD_SCENE:IsShowing() then
						if shouldActivateBrowseResults then
							if control:IsActive() then
								-- We are already activated, focus on the panel so we start on the first item entry
								control:ActivatePanelFocus()
							else
								TRADING_HOUSE_GAMEPAD:ActivateBrowseResults()
							end
						end
						if shouldDeactivateBrowseResults then
							if control:IsActive() then
								TRADING_HOUSE_GAMEPAD:DeactivateBrowseResults()
							end
						end
					end
					return true
				end
			end)
			ZO_PreHook(TRADING_HOUSE_SEARCH, "OnResponseReceived", function(control, responseType, result, ...)		
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					if control:IsWaitingForResponseType(responseType) then
						control:ClearAwaitingResponseType()
						if responseType == TRADING_HOUSE_RESULT_PURCHASE_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then
							if AreAllTradingHouseSearchResultsPurchased() then
								control:SetSearchState(TRADING_HOUSE_SEARCH_STATE_COMPLETE, TRADING_HOUSE_SEARCH_OUTCOME_ALL_RESULTS_PURCHASED)
							end
						elseif responseType == TRADING_HOUSE_RESULT_SEARCH_PENDING and result == TRADING_HOUSE_RESULT_SUCCESS then
							control.numItemsOnPage, control.page, control.hasMorePages = GetTradingHouseSearchResultsInfo()
							for tradingHouseItemIndex = 1, TRADING_HOUSE_SEARCH:GetNumItemsOnPage() do
								local itemData = ZO_TradingHouse_CreateSearchResultItemData(tradingHouseItemIndex)
								if itemData then
									table.insert(KELA_CURRENT_SEARCH_TABLE, itemData)
								end
							end	
							KELA_TRADINGHOUSE_SEARCH_WAIT = true
							GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS:RefreshPagingControls()
							if control.hasMorePages then
								control:SetSearchState(TRADING_HOUSE_SEARCH_STATE_WAITING)
								control:SearchNextPage()  
								return true
							end	
							local searchOutcome = (control.numItemsOnPage == 0) and TRADING_HOUSE_SEARCH_OUTCOME_NO_RESULTS or TRADING_HOUSE_SEARCH_OUTCOME_HAS_RESULTS
							control:SetSearchState(TRADING_HOUSE_SEARCH_STATE_COMPLETE, searchOutcome)
						end	
						control:FireCallbacks("OnResponseReceived", responseType, result)
					end
					return true
				end
			end)
			-- отмечаем покупаемый товар
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "ShowPurchaseItemConfirmation", function(control, selectedData, ...)		
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					if selectedData then
						local dialogName = selectedData.isGuildSpecificItem and "TRADING_HOUSE_CONFIRM_BUY_GUILD_SPECIFIC_ITEM" or "TRADING_HOUSE_CONFIRM_BUY_ITEM"
						if not selectedData.isGuildSpecificItem then
							SetPendingItemPurchaseByItemUniqueId(selectedData.itemUniqueId, selectedData.purchasePrice)
							-- CHAT_SYSTEM:AddMessage(tostring(selectedData.itemUniqueId).." / "..tostring(selectedData.purchasePrice))
						end
						ZO_GamepadTradingHouse_Dialogs_DisplayConfirmationDialog(selectedData, dialogName, selectedData.purchasePrice, selectedData.icon)
					end
					return true
				end
			end)
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "FilterScrollList", function(control, ...)		
				if IsKPUITradingHouseSettingEnabled() then
					local scrollData = ZO_ScrollList_GetDataList(control.list)
					-- Search results can be non-contiguous: bought items keep their index but get removed from the scroll list
					ZO_ClearTable(control.searchResultItemDataList)
					ZO_ClearNumericallyIndexedTable(scrollData)
					ZO_ClearNumericallyIndexedTable(control.previewListEntries)
					if TRADING_HOUSE_SEARCH:ShouldShowGuildSpecificItems() then
						for i = 1, GetNumGuildSpecificItems() do
							local itemData = TRADING_HOUSE_GAMEPAD:CreateGuildSpecificItemData(i, GetGuildSpecificItemInfo)
							if itemData then
								itemData.isGuildSpecificItem = true
								local dataEntry = ZO_ScrollList_CreateDataEntry(ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE, itemData)
								table.insert(scrollData, dataEntry)
							end
						end
					else
						-- onepage search
						if KelaGetSetting_Bool(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
							KELA_TRADINGHOUSE_ITEMCOUNT = 0
							for tradingHouseItemIndex, itemData in pairs(KELA_CURRENT_SEARCH_TABLE) do
								if itemData then
									local index = ZO_Inventory_GetSlotIndex(itemData)
									local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemData.itemLink)
									local valueEffectDeal = KelaGetEffectOfDeal (priceInfoTTC, priceInfoATT, itemData, "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS")
									if valueEffectDeal == "-" then 
										valueEffectDeal = KelaGetEffectIfUndefined(itemData)
									end
									if KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX == 1 or (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX == 2 and valueEffectDeal == 0) or (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX > 2 and valueEffectDeal >= KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX) then	
										local dataEntry = ZO_ScrollList_CreateDataEntry(ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE, itemData)
										control.searchResultItemDataList[index] = itemData
										table.insert(scrollData, dataEntry)
										KELA_TRADINGHOUSE_ITEMCOUNT = KELA_TRADINGHOUSE_ITEMCOUNT + 1
									end
								end
							end
						else
							for tradingHouseItemIndex = 1, TRADING_HOUSE_SEARCH:GetNumItemsOnPage() do
								local itemData = ZO_TradingHouse_CreateSearchResultItemData(tradingHouseItemIndex)
								if itemData then
									local _, _, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemData.itemLink)
									local valueEffectDeal = KelaGetEffectOfDeal (priceInfoTTC, priceInfoATT, itemData, "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS")
									if valueEffectDeal == "-" then 
										valueEffectDeal = KelaGetEffectIfUndefined(itemData)
									end
									if KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX == 1 or (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX == 2 and valueEffectDeal == 0) or (KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX > 2 and valueEffectDeal >= KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX) then	
										local dataEntry = ZO_ScrollList_CreateDataEntry(ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE, itemData)
										control.searchResultItemDataList[tradingHouseItemIndex] = itemData
										table.insert(scrollData, dataEntry)
										if control:CanPreviewTradingHouseItem(itemData) then
											table.insert(control.previewListEntries, tradingHouseItemIndex)
										end
									end
								end
							end						
						end
						KELA_TRADINGHOUSE_SEARCH_WAIT = false
						control:RefreshPagingControls()
					end
					if TRADING_HOUSE_PREVIEW_GAMEPAD_SCENE:IsShowing() then
						control:UpdatePreviewForChangedData()
					end
					return true
				end
			end)
			SecurePostHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "FilterScrollList", function(control, ...)		
				if IsKPUITradingHouseSettingEnabled() then
					control.contentHeaderData.data1HeaderText = colors.COLOR_WHITE:Colorize(zo_iconFormat(kpuiConst.stringDDS.rightStickXBOne, 44, 44)).." "..KelaCreateColorizedResumePrice(KELA_CURRENT_EFFECTDEAL_SELECTION_INDEX)
					control.contentHeaderData.data2HeaderText = ""
					control.contentHeaderData.data3HeaderText = ""
					ZO_GamepadGenericHeader_RefreshData(control.contentHeader, control.contentHeaderData)
				end
			end)
			local PRICE_THRESHOLD_DIGITS = 6
			local PRICE_THRESHOLD = zo_pow(10, PRICE_THRESHOLD_DIGITS)
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "SetupResultItemRow", function(selfControl, control, itemData, ...)		
				if IsKPUITradingHouseSettingEnabled() then
					-- icon/stack count
					control.slotIcon:SetTexture(itemData.icon)
					if itemData.stackCount and itemData.stackCount > 1 then
						control.slotStackCount:SetText(ZO_AbbreviateAndLocalizeNumber(itemData.stackCount, NUMBER_ABBREVIATION_PRECISION_TENTHS, USE_LOWERCASE_NUMBER_SUFFIXES))
						control.slotStackCount:SetHidden(false)
					else
						control.slotStackCount:SetHidden(true)
					end
					-- name
					control.nameLabel:SetText(ZO_TradingHouse_GetItemDataFormattedName(itemData))
					-- itemData.quality is deprecated, included here for addon backwards compatibility
					local displayQuality = itemData.displayQuality or itemData.quality
					control.nameLabel:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, displayQuality))
					-- time
					if not itemData.isGuildSpecificItem then
						local timeRemainingString = ZO_TradingHouse_GetItemDataFormattedTime(itemData)
						control.timeLeftLabel:SetHidden(false)
						control.timeLeftLabel:SetText(timeRemainingString)
					else
						control.timeLeftLabel:SetHidden(true)
					end
					-- unit price
					local currencyOptions = ZO_CountDigitsInNumber(itemData.purchasePricePerUnit) <= PRICE_THRESHOLD_DIGITS and ZO_GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS_CURRENCY_OPTIONS or ZO_GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS_ABBREVIATED_CURRENCY_OPTIONS
					ZO_CurrencyControl_SetSimpleCurrency(control.unitPriceLabel, CURT_MONEY, itemData.purchasePricePerUnit, currencyOptions, CURRENCY_SHOW_ALL)
					-- добавляем оценку цены по TTC, если эффект сделки  не доступен
					local colorPrice = colors.COLOR_WHITE
					if TamrielTradeCentre ~= nil then
						local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemData.itemLink)
						if trueTTC or trueATT then 				
							local valueEffectDeal, _, colorEffectDeal = KelaGetEffectOfDeal (priceInfoTTC, priceInfoATT, itemData, "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS")
							local avgPrice = priceInfoTTC.Avg
							local minPrice = priceInfoTTC.Min
							local maxPrice = priceInfoTTC.Max
							if valueEffectDeal ~= "-" then
								colorPrice = colorEffectDeal
							elseif avgPrice ~= 0 and itemData.purchasePricePerUnit ~= avgPrice then
								if itemData.purchasePricePerUnit <= minPrice + (avgPrice-minPrice)*0.1 then
									colorPrice = colors.COLOR_DEALGREAT
								elseif itemData.purchasePricePerUnit <= minPrice + (avgPrice-minPrice)*0.7 then
									colorPrice = colors.COLOR_DEALGOOD
								elseif itemData.purchasePricePerUnit <= avgPrice + (maxPrice-avgPrice)*0.3 then
									colorPrice = colors.COLOR_DEALNORMAL
								elseif itemData.purchasePricePerUnit <= avgPrice + (maxPrice-avgPrice)*0.7 then
									colorPrice = colors.COLOR_DEALBAD
								elseif itemData.purchasePricePerUnit >= avgPrice + (maxPrice-avgPrice)*0.7 then
									colorPrice = colors.COLOR_DEALTERRIBLE
								end
							end
						end
					end
					control.unitPriceLabel:SetColor(colorPrice:UnpackRGB())
					-- total price
					local notEnoughMoney = itemData.purchasePrice > GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
					local currencyOptions = itemData.purchasePrice < PRICE_THRESHOLD and ZO_GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS_CURRENCY_OPTIONS or ZO_GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS_ABBREVIATED_CURRENCY_OPTIONS
					ZO_CurrencyControl_SetSimpleCurrency(control.priceLabel, CURT_MONEY, itemData.purchasePrice, currencyOptions, CURRENCY_SHOW_ALL, notEnoughMoney)
					return true
				end
			end)
			-- очищаем таблицу результатов
			SecurePostHook(ZO_GamepadTradingHouse, "DeactivateBrowseResults", function(control, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					TRADING_HOUSE_SEARCH:ResetPageData()
					TRADING_HOUSE_SEARCH.targetPage = nil
					TRADING_HOUSE_SEARCH.useLastExecutedSearchFilters = false
					ZO_ClearTable(KELA_CURRENT_SEARCH_TABLE)
				end
			end)
			TRADING_HOUSE_GAMEPAD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					if newState == SCENE_SHOWING then
					elseif newState == SCENE_HIDDEN then
						TRADING_HOUSE_SEARCH.targetPage = nil
						TRADING_HOUSE_SEARCH.useLastExecutedSearchFilters = false
						ZO_ClearTable(KELA_CURRENT_SEARCH_TABLE)
					end
				end
			end)			
			-- при покупке и сортировке
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "BuildMasterList", function(control, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					control:SetMasterList(KELA_CURRENT_SEARCH_TABLE)
				end
			end)			
			ZO_PreHook(GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS, "RefreshSort", function(selfControl, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					local sortKey = "purchasePricePerUnit"
					if selfControl.currentSortKey == TRADING_HOUSE_SORT_EXPIRY_TIME then
						sortKey = "timeRemaining"
					elseif selfControl.currentSortKey == TRADING_HOUSE_SORT_SALE_PRICE then
						sortKey = "purchasePrice"
					end 
					if selfControl.currentSortOrder == ZO_SORT_ORDER_UP then
						table.sort(KELA_CURRENT_SEARCH_TABLE, function (a,b) return (string.lower(a[sortKey]) < string.lower(b[sortKey])) end)
					else
						table.sort(KELA_CURRENT_SEARCH_TABLE, function (a,b) return (string.lower(b[sortKey]) < string.lower(a[sortKey])) end)
					end
					selfControl:RefreshData()
					if not selfControl.control:IsHidden() then
						TRADING_HOUSE_SEARCH:ChangeSort(selfControl.currentSortKey, selfControl.currentSortOrder)
					end
					KELA_TRADINGHOUSE_SEARCH_WAIT = false
					selfControl:RefreshPagingControls()
					return true
				end
			end)		
			ZO_PreHook(TRADING_HOUSE_SEARCH, "ChangeSort", function(selfControl, sortKey, sortOrder, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_SEARCH_ONEPAGE) then
					selfControl.sortField = sortKey
					selfControl.sortOrder = sortOrder
					return true
				end
			end)
			-- TRADING_HOUSE_CREATE_LISTING_GAMEPAD
			-- окно создания продажи
			SecurePostHook(TRADING_HOUSE_CREATE_LISTING_GAMEPAD, "Showing", function(control, ...)
				if IsKPUITradingHouseSettingEnabled() then
					local itemLink = GetItemLink(control.itemBag, control.itemIndex)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
						selectedData = control.selectedData
						local itemUniqueId = GetItemUniqueId(control.itemBag, control.itemIndex)
						if itemLink then
							local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
							KPUI_GAMEPAD_TOOLTIPS:ClearTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
							KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "TRADING_HOUSE_CREATE_LISTING_GAMEPAD", itemLink, selectedData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5, nil, itemUniqueId)		
						end
					end
					local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)
					_, _, _, _, _, _, _, _, _, _, _, _, compareValuePrice = KelaGetEffectOfDeal (priceInfoTTC, priceInfoATT, selectedData)				
					-- назначаем свою цену
					if compareValuePrice and compareValuePrice ~= 0 then 
						control:SetListingPrice(math.ceil(compareValuePrice))
					end
				end
			end)
			SecurePostHook(TRADING_HOUSE_CREATE_LISTING_GAMEPAD, "Hiding", function(control, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_TRADINGHOUSE) then
					KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
				end
			end)
			SecurePostHook(TRADING_HOUSE_CREATE_LISTING_GAMEPAD, "SetListingPrice", function(selfControl, price, isPreview, ...)
				if IsKPUITradingHouseSettingEnabled() then
					local listingFee, _, profit = GetTradingHousePostPriceInfo(price)
					selfControl.validPrice = (GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) >= listingFee) and (price > 0) and (price <= MAX_PLAYER_CURRENCY)
					local HAS_ERROR = not selfControl.validPrice
					local colorValue = colors.COLOR_WHITE
					if HAS_ERROR then 
						colorValue = colors.COLOR_DEALTERRIBLE
					end
					selectedData = selfControl.selectedData
					local itemLink = GetItemLink(selfControl.itemBag, selfControl.itemIndex)
					if itemLink then
						local controlContainer = selfControl.control:GetNamedChild("Mask"):GetNamedChild("Container")
						local controlRail = controlContainer:GetNamedChild("Rail")
						local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
						local itemUniqueId = GetItemUniqueId(selfControl.itemBag, selfControl.itemIndex)
						local stackCount, buyPrice, buyPricePerUnit
						local itemType = GetItemLinkItemType(itemLink)
						if (itemType == ITEMTYPE_MASTER_WRIT) then
							stackCount = ArkadiusTradeToolsSales:GetVoucherCount(itemLink)
						else
							stackCount = selectedData.stackCount
						end
						if itemUniqueId then
							tblBuyingItems = kpuiSVBuyingData["buyingTable"]			
							itemUID = Id64ToString(itemUniqueId)
							if tblBuyingItems[itemUID] ~= nil then
								buyPricePerUnit = tonumber(tblBuyingItems[itemUID]["buyPricePerUnit"])
								buyPrice = buyPricePerUnit*stackCount
							end
						end				
						if stackCount > 1 then
							local strPrice = KelaLocalizedFormatNumber(price/stackCount, 2)
							local strPrice = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(tonumber(strPrice), true, CURT_MONEY, true)
							if not ctlListingPriceLabel then ctlListingPriceLabel = CreateControlFromVirtual("$(parent)KPUI_ListingPrice", controlContainer, "KPUI_LabelValue") end				
							ctlListingPriceLabel:ClearAnchors()
							ctlListingPriceLabel:SetAnchor(TOPLEFT, controlRail, BOTTOMLEFT, 0, -265)
							ctlListingPriceLabel:SetAnchor(TOPRIGHT, controlRail, BOTTOMRIGHT, 0, -265)
							ctlListingPriceLabel:SetHidden(false)	
							ctlListingPriceLabel:GetNamedChild("Label"):SetText(GetString(KELA_TRADING_SALE_PRICE))
							ctlListingPriceLabel:GetNamedChild("Value"):SetText(colorValue:Colorize(strPrice))
						else
							if ctlListingPriceLabel then ctlListingPriceLabel:SetHidden(true) end
						end
						if buyPrice then
							-- local strClearProfit = KelaLocalizedFormatNumber(profit-buyPrice)
							local strClearProfit = profit-buyPrice

							if not HAS_ERROR then 
								-- CHAT_SYSTEM:AddMessage(tostring(strClearProfit).." / "..tostring(buyPrice))
								if strClearProfit >= buyPrice then
									colorValue = colors.COLOR_DEALGREAT
								elseif strClearProfit >= buyPrice*0.3 then
									colorValue = colors.COLOR_DEALGOOD
								elseif strClearProfit >= 0 then

								elseif strClearProfit >= 0-(buyPrice*0.2) then
									colorValue = colors.COLOR_DEALBAD
								elseif strClearProfit <= 0-(buyPrice*0.2) then
									colorValue = colors.COLOR_DEALTERRIBLE
								end
							end
							strClearProfit = ZO_CurrencyControl_FormatCurrencyAndAppendIcon(strClearProfit, true, CURT_MONEY, true)
							if not ctlListingClearProfitAmountLabel then ctlListingClearProfitAmountLabel = CreateControlFromVirtual("$(parent)KPUI_ListingProfit", controlContainer, "KPUI_LabelValue") end				
							ctlListingClearProfitAmountLabel:ClearAnchors()
							ctlListingClearProfitAmountLabel:SetAnchor(TOPLEFT, controlRail, BOTTOMLEFT, 0, 95)
							ctlListingClearProfitAmountLabel:SetAnchor(TOPRIGHT, controlRail, BOTTOMRIGHT, 0, 95)
							ctlListingClearProfitAmountLabel:SetHidden(false)	
							ctlListingClearProfitAmountLabel:GetNamedChild("Label"):SetText(GetString(KELA_TRADING_SALE_CLEARPROFIT))
							ctlListingClearProfitAmountLabel:GetNamedChild("Value"):SetText(colorValue:Colorize(strClearProfit))
						else
							if ctlListingClearProfitAmountLabel then ctlListingClearProfitAmountLabel:SetHidden(true) end
						end
					end
				end

			end)
			-- диалоги подтверждения продажи и покупки
			function ZO_GamepadTradingHouse_Dialogs_DisplayConfirmationDialog(itemData, dialogName, displayPrice, iconFile)
				local listingIndex = itemData.slotIndex
				local stackCount = itemData.stackCount
				local itemName = itemData.name
				-- local timeRemaining = itemData.timeRemaining
				-- local pricePerUnit = itemData.purchasePricePerUnit
				-- local uniqueId = itemData.itemUniqueId
				local price = displayPrice
				-- itemData.quality is deprecated, included here for addon backwards compatibility
				local displayQuality = itemData.displayQuality or itemData.quality
				local nameColor = GetItemQualityColor(displayQuality)
				local currencyType = itemData.currencyType or CURT_MONEY
				local itemNameWithQuantity = nameColor:Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME_WITH_QUANTITY, itemName, stackCount))
				local title = itemNameWithQuantity
				if iconFile then
					local iconMarkup = zo_iconFormat(iconFile, ZO_GAMEPAD_DEFAULT_LIST_ENTRY_ICON_FULL_SIZE_DIMENSION, ZO_GAMEPAD_DEFAULT_LIST_ENTRY_ICON_FULL_SIZE_DIMENSION)
					title = string.format("%s %s", iconMarkup, itemNameWithQuantity)
				end
				local priceText = zo_strformat(SI_GAMEPAD_TRADING_HOUSE_ITEM_AMOUNT, ZO_CurrencyControl_FormatCurrency(price), ZO_Currency_GetGamepadFormattedCurrencyIcon(currencyType))
				local mainTextParams
				if stackCount > 1 then
					mainTextParams = 
					{
						title,
						"|c" .. nameColor:ToHex(),
						itemName,
						stackCount,
						priceText,
					}
				else
					mainTextParams =
					{
						title,
						nameColor:Colorize(itemName),
						priceText,
					}
				end
				if IsKPUITradingHouseSettingEnabled() then
					ZO_Dialogs_ShowGamepadDialog(dialogName, { listingIndex = listingIndex, stackCount = stackCount, uniqueId = itemData.itemUniqueId, itemName = itemName, price = price, pricePerUnit = itemData.purchasePricePerUnit, displayQuality = displayQuality, timeRemaining = itemData.timeRemaining }, { mainTextParams = mainTextParams })
				else
					ZO_Dialogs_ShowGamepadDialog(dialogName, { listingIndex = listingIndex, stackCount = stackCount, price = price }, { mainTextParams = mainTextParams })
				end
			end
			ESO_Dialogs["TRADING_HOUSE_CONFIRM_BUY_ITEM"] =
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.BASIC,
				},
				title =
				{
					text = SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_DIALOG_TITLE,
				},
				mainText = 
				{
					text = function(dialog)
					if dialog.data.stackCount > 1 then
							return SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_MULTIPLE_DIALOG_TEXT
						else
							return SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_DIALOG_TEXT
						end
					end,
				},
				buttons =
				{
					[1] =
					{
						text =      SI_TRADING_HOUSE_PURCHASE_ITEM_DIALOG_CONFIRM,
						callback =  function(dialog)
										if IsKPUITradingHouseSettingEnabled() then
											KelaAddToBuyingUniqueTable(dialog.data.uniqueId, dialog.data.itemName, dialog.data.price, dialog.data.pricePerUnit, dialog.data.listingIndex, dialog.data.displayQuality)
											for k, v in ipairs(KELA_CURRENT_SEARCH_TABLE) do
												if Id64ToString(v.itemUniqueId) == Id64ToString(dialog.data.uniqueId) then 
													local byIndex = true
													KelaRemoveValueByKey(KELA_CURRENT_SEARCH_TABLE, k, byIndex) -- ПРОВЕРЯЕМ В Ipars, remove Table[2] and shift remaining entries
													break
												end
											end
										end
										ConfirmPendingItemPurchase()
									 end
					},
					[2] =
					{
						text =      SI_TRADING_HOUSE_PURCHASE_ITEM_DIALOG_CANCEL,
						callback =  function(dialog)
										ClearPendingItemPurchase()
									end
					}
				}
			}
			local exitOnFinished = true
			ESO_Dialogs["TRADING_HOUSE_CONFIRM_SELL_ITEM"] =
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.BASIC,
				},
				title =
				{
					text = SI_GAMEPAD_TRADING_HOUSE_CONFIRM_SELL_DIALOG_TITLE,
				},
				mainText = 
				{
					text =  function(dialog)
								if dialog.data.stackCount > 1 then
									return SI_GAMEPAD_TRADING_HOUSE_CONFIRM_SELL_MULTIPLE_DIALOG_TEXT
								else
									return SI_GAMEPAD_TRADING_HOUSE_CONFIRM_SELL_DIALOG_TEXT
								end
							end,
				},
				setup = function()
					exitOnFinished = false
				end,
				finishedCallback = function(dialog)
					if exitOnFinished then
						SCENE_MANAGER:HideCurrentScene()
					end
				end,
				buttons =
				{
					[1] =
					{
						text = SI_DIALOG_YES,
						callback = function(dialog)
							local stackCount = dialog.data.stackCount
							local desiredPrice = dialog.data.price
							local listingIndex = dialog.data.listingIndex
							local timeRemaining = dialog.data.timeRemaining
							RequestPostItemOnTradingHouse(BAG_BACKPACK, listingIndex, stackCount, desiredPrice, timeRemaining)
							
							if IsKPUITradingHouseSettingEnabled() then
								KelaAddToListingTable(BAG_BACKPACK, listingIndex, stackCount, desiredPrice, timeRemaining)
							end
							
							exitOnFinished = true
						end
					},
					[2] =
					{
						text = SI_DIALOG_NO,
					}  
				}
			}
			ESO_Dialogs["TRADING_HOUSE_CONFIRM_REMOVE_LISTING"] =
			{
				gamepadInfo =
				{
					dialogType = GAMEPAD_DIALOGS.BASIC,
				},
				title =
				{
					text = SI_GAMEPAD_TRADING_HOUSE_LISTING_REMOVE_DIALOG_TITLE,
				},
				mainText = 
				{
					text =  function(dialog)
								if dialog.data.stackCount > 1 then
									return SI_GAMEPAD_TRADING_HOUSE_LISTING_REMOVE_MULTIPLE_DIALOG_TEXT
								else
									return SI_GAMEPAD_TRADING_HOUSE_LISTING_REMOVE_DIALOG_TEXT
								end
							end,
				},
				buttons =
				{
					[1] =
					{
						text =      SI_DIALOG_REMOVE,
						callback =  function(dialog)
										CancelTradingHouseListing(dialog.data.listingIndex)
										if IsKPUITradingHouseSettingEnabled() then
											KelaRemoveFromListingTable(dialog.data.listingIndex, dialog.data.stackCount, dialog.data.price, dialog.data.timeRemaining)
										end
									end
					},
					[2] =
					{
						text =       SI_DIALOG_CANCEL,
					}  
				}
			}
			hookTradingHouseAlready = true
		end
	end)
	
	-- настраиваем банкинг если открывается простой банк
	SecurePostHook(ZO_GamepadBanking, "OnOpenBank", function(control, bankBag, ...)
		if not hookBankingAlready then
			SecurePostHook(ZO_BankingCommon_Gamepad, "LayoutBankingEntryTooltip", function(control, inventoryData, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_BANK) then
					if inventoryData and inventoryData.bagId then
						local itemLink = GetItemLink(inventoryData.bagId, inventoryData.slotIndex)
						local itemUniqueId = GetItemUniqueId(inventoryData.bagId, inventoryData.slotIndex)
						if itemLink then
							local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
							KPUI_GAMEPAD_TOOLTIPS:ClearLines(KPUI_GAMEPAD_TRADING_TOOLTIP)
							KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "ZO_BankingCommon_Gamepad", itemLink, inventoryData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5, nil, itemUniqueId)			
						end
					else
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end
			end)		
			SecurePostHook(ZO_BankingCommon_Gamepad, "OnCategoryChanged", function(control, selectedData, ...)
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_BANK) then
					control:LayoutBankingEntryTooltip(selectedData)
				end
			end)
			hookBankingAlready = true
		end
	end)
	
	-- настраиваем банкинг если открывается гильдейский банк
	SecurePostHook(ZO_BankingCommon_Gamepad, "OnStateChanged", function(control, oldState, newState, ...)
		if not hookBankingAlready then
			if newState == SCENE_SHOWING then
				SecurePostHook(ZO_BankingCommon_Gamepad, "LayoutBankingEntryTooltip", function(control, inventoryData, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_BANK) then
						if inventoryData and inventoryData.bagId then
							local itemLink = GetItemLink(inventoryData.bagId, inventoryData.slotIndex)
							local itemUniqueId = GetItemUniqueId(inventoryData.bagId, inventoryData.slotIndex)
							if itemLink then
								local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
								KPUI_GAMEPAD_TOOLTIPS:ClearLines(KPUI_GAMEPAD_TRADING_TOOLTIP)
								KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "ZO_BankingCommon_Gamepad", itemLink, inventoryData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5, nil, itemUniqueId)		
							end
						else
							KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						end
					end
				end)		
				SecurePostHook(ZO_BankingCommon_Gamepad, "OnCategoryChanged", function(control, selectedData, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_BANK) then
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end	
				end)
				SecurePostHook(ZO_GuildBank_Gamepad, "ChangeGuildBank", function(control, guildBankId, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_BANK) then
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
					end
				end)
				hookBankingAlready = true
			end
		end		
	end)

	-- настраиваем магазины
	SecurePostHook(ZO_GamepadStoreManager, "OnStateChanged", function(control, oldState, newState, ...)
		if not hookStoregAlready then
			if newState == SCENE_SHOWING then
				SecurePostHook(ZO_GamepadStoreBuy, "OnSelectedItemChanged", function(control, buyData, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_STORE) then
						if buyData then
							local itemLink = buyData.itemLink
							if itemLink then
								local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
								KPUI_GAMEPAD_TOOLTIPS:ClearLines(KPUI_GAMEPAD_TRADING_TOOLTIP)
								KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "ZO_GamepadStoreBuy", itemLink, buyData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5)		
							end
						end					
					end
				end)
				SecurePostHook(ZO_GamepadStoreSell, "OnSelectedItemChanged", function(control, inventoryData, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_STORE) then
						if inventoryData and inventoryData.bagId then
							local itemLink = GetItemLink(inventoryData.bagId, inventoryData.slotIndex)
							local itemUniqueId = GetItemUniqueId(inventoryData.bagId, inventoryData.slotIndex)
							if itemLink then
								local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
								KPUI_GAMEPAD_TOOLTIPS:ClearLines(KPUI_GAMEPAD_TRADING_TOOLTIP)
								KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "ZO_GamepadStoreSell", itemLink, inventoryData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5, nil, itemUniqueId)		
							end
						else
							KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
						end	
					end
				end)
				SecurePostHook(ZO_GamepadStoreBuyback, "OnSelectedItemChanged", function(control, buyBackData, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_STORE) then
						if buyBackData then
							local itemLink = GetBuybackItemLink(buyBackData.slotIndex)						
							if itemLink then
								local parentControl = GAMEPAD_TOOLTIPS:GetTooltipInfo(GAMEPAD_LEFT_TOOLTIP).bgControl	
								KPUI_GAMEPAD_TOOLTIPS:ClearLines(KPUI_GAMEPAD_TRADING_TOOLTIP)
								KPUI_GAMEPAD_TOOLTIPS:LayoutTradingTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, "ZO_GamepadStoreBuyback", itemLink, buyBackData, KPUI_GAMEPAD_TRADING_TOOLTIP, parentControl, false, 5)		
							end
						else
							KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)	
						end
					end
				end)
				SecurePostHook(ZO_GamepadStoreManager, "HideActiveComponent", function(control, ...)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_STORE) then
						KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)	
					end
				end)
				hookStoregAlready = true
			end
		end		
	end)

	-- настраиваем график АТТ
	if ArkadiusTradeTools ~= nil and not hookATTAlready then 
		ZO_PreHook(ArkadiusTradeToolsSalesGraph, "AddDot", function(control, x, y, color)

				local drawAreaWidth, drawAreaHeight = control.drawArea:GetDimensions()
				local rangeX = control.maxX - control.minX

				local posX = x - control.minX
				local rangeY = control.maxY - control.minY
				local posY = control.maxY - y

				local left = drawAreaWidth / rangeX * posX
				local right = -(drawAreaWidth - left - 2)
				local top = drawAreaHeight / rangeY * posY
				local bottom = -(drawAreaHeight - top - 2)

				-- Serves as the index for our current surface
				control.numDots = control.numDots + 1

				if (control.numDots > control.numSurfaces) then
					control.drawArea:AddSurface(0.25, 0.75, 0.25, 0.75)
					control.numSurfaces = control.numSurfaces + 1
				else
					control.drawArea:SetSurfaceHidden(control.numDots, false)
				end

				control.drawArea:SetColor(control.numDots, color:UnpackRGBA())
				
				control.drawArea:SetPixelRoundingEnabled(false)
				if x == GetTimeStamp() then
					if color == colors.COLOR_TTC then -- then
						left = left - 8
						right = right + 2
						top = top - 1
						bottom = bottom	+ 2
						control.drawArea:SetPixelRoundingEnabled(true)
					elseif color == colors.COLOR_ATT then -- tradeSuggested == "ATT" then
						left = left - 2
						right = right + 8
						top = top - 1
						bottom = bottom	+ 2
						control.drawArea:SetPixelRoundingEnabled(true)
					end
				end
				control.drawArea:SetInsets(control.numDots, left - 2, right + 2, top - 2, bottom + 2)
				
				return true
		
		end)
		
	end

	--НАСТРОКА ДИАЛОГА ВЫБОРА ГИЛЬДИИ
	local function SetupTradingHouseGuildItem(control, data, ...)
		ZO_SharedGamepadEntry_OnSetup(control, data, ...)
		if data.isCurrentGuild then
			control.statusIndicator:AddIcon("EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_equipped.dds")
			control.statusIndicator:Show()
		end
	end
	local function SetupGuildSelectionDialog(dialog)
		local currentGuildId = GetSelectedTradingHouseGuildId()
		dialog.info.parametricList = {}
		local indexToSelect = nil
		for i = 1, GetNumGuilds() do
			local guildId = GetGuildId(i)
			local guildName = GetGuildName(guildId)
			local allianceId = GetGuildAlliance(guildId)
			local icon = GetLargeAllianceSymbolIcon(allianceId)
			local listItem = 
			{
				template = "ZO_GamepadSubMenuEntryWithStatusTemplate",
				templateData = 
				{
					 guildId = guildId,
					 guildName = guildName,
					 allianceId = allianceId,
					 fontScaleOnSelection = false,
					 setup = SetupTradingHouseGuildItem,
					 isCurrentGuild = guildId == currentGuildId
				},
				icon = icon,
				text = guildName,
			}
			table.insert(dialog.info.parametricList, listItem)
			if guildId == currentGuildId then
				indexToSelect = i
			end
		end
		if IsKPUITradingHouseSettingEnabled() then
			dialog.info.blockDialogReleaseOnPress = true
			-- Период анализа АТТ
			local function setupRow (control, data, selected, reselectingDuringRebuild, enabled, active)
				ZO_SharedGamepadEntry_OnSetup(control, data, selected, reselectingDuringRebuild, enabled, active)
				local label = control.label
				label:SetFont("ZoFontGamepad34")

				if not KPUI_SelectorContainer then KPUI_SelectorContainer = CreateControlFromVirtual("$(parent)KPUI_SelectorContainer", dialog, "KPUI_SelectorContainer") end
				KelaPadUI.selectorContainer = KPUI_SelectorContainer
				KelaPadUI.selectorContainer:ClearAnchors()
				KelaPadUI.selectorContainer:SetAnchor(TOPLEFT, control, TOPRIGHT, 0, 0)
				KelaPadUI.selectorContainer:SetAnchor(BOTTOMLEFT, control, BOTTOMRIGHT, 0, 0)			
				KelaPadUI.selectorContainer:SetHidden(false)			
				KelaPadUI.selector = ZO_CurrencySelector_Gamepad:New(KPUI_SelectorContainer:GetNamedChild("Selector"))
				KelaPadUI.selector:SetClampValues(true)
				KelaPadUI.selector:SetMaxValue(30)
				KelaPadUI.selector.control:SetHidden(false)
				KelaPadUI.selector:SetValue(KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD))
			end
			local function callbackRow(dialog)
				KelaPadUI.selector:SetValue(KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD))
				KelaPadUI.selectorContainer:SetHidden(false)
				KelaPadUI.selector.control:SetHidden(false)
				local targetControl = dialog.entryList:GetTargetControl()
				KelaPadUI.selector:Activate()
				KelaPadUI.selectorActive = true
			end
			local KelaOptionsPeriod = 
			{
				template = "Kela_GamepadFullWidthLabelEntryTemplate",
				header = "KelaPadUI",
				headerTemplate = "Kela_GamepadMenuEntryFullWidthHeaderTemplate",
				templateData =
				{
					text = GetString(KELA_SETTINGS_TRADE_ATTGRAPH_PERIOD),
					setup = setupRow,
					callback = callbackRow,
					visible = function()
							return SCENE_MANAGER:GetCurrentScene():GetName() == "gamepad_trading_house"
						end,
				},
			}
			table.insert(dialog.info.parametricList, KelaOptionsPeriod)
		end
		dialog:setupFunc()
		if indexToSelect then
			dialog.entryList:SetSelectedIndexWithoutAnimation(indexToSelect)
		end
	end
	function KelaDeactivateSelector()
		KelaPadUI.selector:SetValue(KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD))
		KelaPadUI.selector:Deactivate()
		KelaPadUI.selectorActive = false
	end
	function KelaUpdateTradingHouseTooltip()
		if TRADING_HOUSE_GAMEPAD.currentListObject:GetTradingHouseMode() == ZO_TRADING_HOUSE_MODE_LISTINGS then 
			GAMEPAD_TRADING_HOUSE_LISTINGS:UpdateItemSelectedTooltip(KELA_TRADINGHOUSE_CURRENT_SELECTEDDATA)
		elseif TRADING_HOUSE_GAMEPAD.currentListObject:GetTradingHouseMode() == ZO_TRADING_HOUSE_MODE_SELL  then					
			GAMEPAD_TRADING_HOUSE_SELL:UpdateItemSelectedTooltip(KELA_TRADINGHOUSE_CURRENT_SELECTEDDATA)
		end	
	end
    local noChoiceCallback = function(dialog)
		KelaDeactivateSelector()
		KelaPadUI.selector.control:SetHidden(true)
	end	
	ESO_Dialogs["TRADING_HOUSE_CHANGE_ACTIVE_GUILD"] =
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
		},
		setup = SetupGuildSelectionDialog,
		blockDialogReleaseOnPress = IsKPUITradingHouseSettingEnabled() and true,
		title =
		{
			text = SI_GAMEPAD_TRADING_HOUSE_GUILD_SELECTION,
		},
		buttons =
		{
			[1] =
			{
				text = SI_GAMEPAD_SELECT_OPTION,
				callback = function(dialog)
					local data = dialog.entryList:GetTargetData()
					if IsKPUITradingHouseSettingEnabled() then
						if data.guildId then
							dialog.info.blockDialogReleaseOnPress = false
							local currentGuildId = GetSelectedTradingHouseGuildId()
							if data.guildId ~= currentGuildId then
								SelectTradingHouseGuildId(data.guildId)
							end
							KelaPadUI.selector.control:SetHidden(true)
							zo_callLater(KelaUpdateTradingHouseTooltip, 150)
						else
							if KelaPadUI.selectorActive then
								local amount = KelaPadUI.selector:GetValue()
								if amount == 0 then amount = 1 end
								KelaSetSetting(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD, amount, true)
								KelaDeactivateSelector()						
							elseif data and data.callback then
								data.callback(dialog)
							end					
						end
					else
					   if data.guildId then
						   SelectTradingHouseGuildId(data.guildId)
					   end					
					end
				end
			},

			[2] =
			{
				text = SI_DIALOG_EXIT,
				callback = function(dialog)
					if IsKPUITradingHouseSettingEnabled() then
						if KelaPadUI.selectorActive then
							KelaDeactivateSelector()
						else
							KelaPadUI.selector.control:SetHidden(true)
							dialog.info.blockDialogReleaseOnPress = false
						end	
						zo_callLater(KelaUpdateTradingHouseTooltip, 150)
					end
				end
			}
		},
        noChoiceCallback = noChoiceCallback,
	}
end


function ZO_Tooltip:LayoutEnchantingTradingTooltip(tooltip, itemLink, maxIterations, itemUniqueId)
    local icon = GetItemLinkIcon(itemLink)

	tooltip.scrollTooltip:ResetToTop()
	tooltip.tip:ClearLines()
	tooltip = tooltip.tip
	local lastControl

	local stackCount = maxIterations
	if not stackCount then stackCount = 1 end
	
    if itemLink and itemLink ~= "" then
        if tooltip.icon then
            tooltip.icon:SetTexture(icon)
            tooltip.icon:SetHidden(false)
        end

		local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
		bodySection:AddLine(GetString(KELA_TRADING_TRADING_INFO))
		bodySection:AddLine(" ")
		tooltip:AddSection(bodySection)
		lastControl = bodySection
		
		-- local resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink = GetItemLinks(itemLink)		
		local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
		local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)
		-- Информация о купленной вещи
		local isByingItem = false
		local tblBuyingItems = {}
		local itemUID
		if itemUniqueId then
			tblBuyingItems = kpuiSVBuyingData["buyingTable"]			
			itemUID = Id64ToString(itemUniqueId)
			if tblBuyingItems[itemUID] ~= nil then
				isByingItem = true
			end
		end	
		-- основная информация
		if trueTTC or trueATT then
			if not ctlEnchantingInfo then ctlEnchantingInfo = CreateControlFromVirtual("$(parent)Info", tooltip, "KPUI_MainInfo") end	
			lastControl, _, isTwoRowFooter = SetSmithTradingInfo(ctlEnchantingInfo, lastControl, priceInfoTTC, priceInfoATT, nil, nil, stackCount)
			local offsetY = 15
			if isTwoRowFooter and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then offsetY = 35 end
			lastControl = AddClearLine(tooltip, lastControl, 0, offsetY)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
				if not ctlEnchantingGraph then ctlEnchantingGraph = CreateControlFromVirtual("$(parent)Graph", tooltip, "KPUI_Graph") end							
				lastControl = SetSmithGraph (ctlEnchantingGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, stackCount)		
			else
				if ctlEnchantingGraph then ctlEnchantingGraph:SetHidden(true) end	
			end
		else
			local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
			bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
			tooltip:AddSection(bodySection)
			bodySection:ClearAnchors()
			bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
			bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
			lastControl = bodySection
			lastControl = AddClearLine(tooltip, lastControl, 0, 0)
			if ctlEnchantingInfo then ctlEnchantingInfo:SetHidden(true) end	
			if ctlEnchantingGraph then ctlEnchantingGraph:SetHidden(true) end	
		end
		-- Информация о купленной вещи
		if isByingItem then
			local strBuyInfo = GetBuyInfo(tblBuyingItems, itemUID)
			lastControl = SetSmithNotes(tooltip, lastControl, strBuyInfo)			
		end	
		-- Предыдущие продажи
		if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
			if not ctlEnchantingListings then ctlEnchantingListings = CreateControlFromVirtual("$(parent)Listings", tooltip, "KPUI_PreviousListings") end	
			lastControl = SetSmithListings(ctlEnchantingListings, lastControl, listingItemsTable)
			lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
		else
			if ctlEnchantingListings then ctlEnchantingListings:SetHidden(true) end	
		end	
	else
		HideEnchantingTooltipControls()				
    end

end

function ZO_Tooltip:LayoutAlchemyTradingTooltip(tooltip, itemLink, maxIterations)
    local icon = GetItemLinkIcon(itemLink)

	tooltip.scrollTooltip:ResetToTop()
	tooltip.tip:ClearLines()
	tooltip = tooltip.tip
	local lastControl

	local stackCount = maxIterations
	if not stackCount then stackCount = 1 end
	
    if itemLink and itemLink ~= "" then
        if tooltip.icon then
            tooltip.icon:SetTexture(icon)
            tooltip.icon:SetHidden(false)
        end

		local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
		bodySection:AddLine(GetString(KELA_TRADING_TRADING_INFO))
		bodySection:AddLine(" ")
		tooltip:AddSection(bodySection)
		lastControl = bodySection
		
		local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
		local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)

		-- основная информация
		if trueTTC or trueATT then
			if not ctlAlchemyInfo then ctlAlchemyInfo = CreateControlFromVirtual("$(parent)Info", tooltip, "KPUI_MainInfo") end	
			lastControl, _, isTwoRowFooter = SetSmithTradingInfo(ctlAlchemyInfo, lastControl, priceInfoTTC, priceInfoATT, nil, nil, stackCount)
			local offsetY = 15
			if isTwoRowFooter and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then offsetY = 35 end
			lastControl = AddClearLine(tooltip, lastControl, 0, offsetY)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
				if not ctlAlchemyGraph then ctlAlchemyGraph = CreateControlFromVirtual("$(parent)Graph", tooltip, "KPUI_Graph") end							
				lastControl = SetSmithGraph (ctlAlchemyGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, stackCount)			
			else
				if ctlAlchemyGraph then ctlAlchemyGraph:SetHidden(true) end	
			end
		else
			local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
			bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
			tooltip:AddSection(bodySection)
			bodySection:ClearAnchors()
			bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
			bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
			lastControl = bodySection
			lastControl = AddClearLine(tooltip, lastControl, 0, 0)
			if ctlAlchemyInfo then ctlAlchemyInfo:SetHidden(true) end	
			if ctlAlchemyGraph then ctlAlchemyGraph:SetHidden(true) end	
		end
		-- Предыдущие продажи
		if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
			if not ctlAlchemyListings then ctlAlchemyListings = CreateControlFromVirtual("$(parent)Listings", tooltip, "KPUI_PreviousListings") end	
			lastControl = SetSmithListings(ctlAlchemyListings, lastControl, listingItemsTable)
			lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
		else
			if ctlAlchemyListings then ctlAlchemyListings:SetHidden(true) end	
		end	
	else
		HideAlchemyTooltipControls()				
    end

end

function ZO_Tooltip:LayoutProvisionerTradingTooltip(tooltip, recipeListIndex, recipeIndex, selectedData)
    local _, icon = GetRecipeResultItemInfo(recipeListIndex, recipeIndex)
    local itemLink = GetRecipeResultItemLink(recipeListIndex, recipeIndex)

	tooltip.scrollTooltip:ResetToTop()
	tooltip.tip:ClearLines()
	tooltip = tooltip.tip
	local lastControl

	local stackCount = selectedData and selectedData.stackCount
	if not stackCount then stackCount = 1 end
	
    if itemLink and itemLink ~= "" then
        if tooltip.icon then
            tooltip.icon:SetTexture(icon)
            tooltip.icon:SetHidden(false)
        end

		local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
		bodySection:AddLine(GetString(KELA_TRADING_TRADING_INFO))
		bodySection:AddLine(" ")
		tooltip:AddSection(bodySection)
		lastControl = bodySection
	
		local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
		local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)

		-- основная информация
		if trueTTC or trueATT then
			if not ctlProvisionerInfo then ctlProvisionerInfo = CreateControlFromVirtual("$(parent)ProvInfo", tooltip, "KPUI_MainInfo") end	
			lastControl, _, isTwoRowFooter = SetSmithTradingInfo(ctlProvisionerInfo, lastControl, priceInfoTTC, priceInfoATT, nil, selectedData, stackCount)
			local offsetY = 15
			if isTwoRowFooter and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then offsetY = 35 end
			lastControl = AddClearLine(tooltip, lastControl, 0, offsetY)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
				if not ctlProvisionerGraph then ctlProvisionerGraph = CreateControlFromVirtual("$(parent)ProvGraph", tooltip, "KPUI_Graph") end							
				lastControl = SetSmithGraph (ctlProvisionerGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, stackCount)
			else
				if ctlProvisionerGraph then ctlProvisionerGraph:SetHidden(true) end	
			end
		else
			local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
			bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
			tooltip:AddSection(bodySection)
			bodySection:ClearAnchors()
			bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
			bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
			lastControl = bodySection
			lastControl = AddClearLine(tooltip, lastControl, 0, 0)
			if ctlProvisionerInfo then ctlProvisionerInfo:SetHidden(true) end	
			if ctlProvisionerGraph then ctlProvisionerGraph:SetHidden(true) end	
		end
		-- Предыдущие продажи
		if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
			if not ctlProvisionerListings then ctlProvisionerListings = CreateControlFromVirtual("$(parent)SListings", tooltip, "KPUI_PreviousListings") end	
			lastControl = SetSmithListings(ctlProvisionerListings, lastControl, listingItemsTable)
			lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
		else
			if ctlProvisionerListings then ctlProvisionerListings:SetHidden(true) end	
		end	
	else
		HideProvisionerTooltipControls()				
    end

end

function ZO_Tooltip:LayoutSmithingCreationTooltip(tooltip, itemLink)

	tooltip.scrollTooltip:ResetToTop()
	tooltip.tip:ClearLines()
	tooltip = tooltip.tip
	local lastControl
	
    local icon = GetItemLinkIcon(itemLink)

    if itemLink and itemLink ~= "" then

	
		if tooltip.icon then
            tooltip.icon:SetTexture(icon)
            tooltip.icon:SetHidden(false)
        end

		local resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink = GetItemLinks(itemLink)
		local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
		local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)

		-- пустая строка
		-- AddClearLine(true)
		local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
		bodySection:AddLine(GetString(KELA_TRADING_TRADING_INFO))
		bodySection:AddLine(" ")
		tooltip:AddSection(bodySection)
		lastControl = bodySection
		
		-- основная информация
		if trueTTC or trueATT then
			if not ctlCreationInfo then ctlCreationInfo = CreateControlFromVirtual("$(parent)Info", tooltip, "KPUI_MainInfo") end	
			lastControl = SetSmithTradingInfo(ctlCreationInfo, lastControl, priceInfoTTC, priceInfoATT)
			lastControl = AddClearLine(tooltip, lastControl, 0, 15)
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
				if not ctlCreationGraph then ctlCreationGraph = CreateControlFromVirtual("$(parent)Graph", tooltip, "KPUI_Graph") end							
				lastControl = SetSmithGraph (ctlCreationGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, 1)
			else
				if ctlCreationGraph then ctlCreationGraph:SetHidden(true) end	
			end
		else
			local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
			bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
			tooltip:AddSection(bodySection)
			bodySection:ClearAnchors()
			bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
			bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
			lastControl = bodySection
			lastControl = AddClearLine(tooltip, lastControl, 0, 0)
			if ctlCreationInfo then ctlCreationInfo:SetHidden(true) end	
			if ctlCreationGraph then ctlCreationGraph:SetHidden(true) end
		end		
		-- Предыдущие продажи
		if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
			if not ctlCreationListings then ctlCreationListings = CreateControlFromVirtual("$(parent)Listings", tooltip, "KPUI_PreviousListings") end	
			lastControl = SetSmithListings(ctlCreationListings, lastControl, listingItemsTable)
			lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
		else
			if ctlCreationListings then ctlCreationListings:SetHidden(true) end	
		end	
		-- Другой уровень вещей
		if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_QUALITY) and (normalItemLink or fineItemLink or superiorItemLink or epicItemLink or legendaryItemLink) then
			local notSuccess
			if not ctlCreationOther then ctlCreationOther = CreateControlFromVirtual("$(parent)Other", tooltip, "KPUI_OtherQualityInfo") end	
			lastControl, notSuccess = SetSmithQualityPrices(tooltip, ctlCreationOther, lastControl, itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink)
			if notSuccess then 
				if ctlCreationOther then ctlCreationOther:SetHidden(true) end	
			else
				lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
			end
		else
			if ctlCreationOther then ctlCreationOther:SetHidden(true) end	
		end		
	else
		HideCreationTooltipControls()
	end
	

end

function ZO_Tooltip:LayoutSmithingTradingTooltip(tooltip, itemBagId, itemSlotIndex, craftingSkillType, itemUniqueId, selectedData)

	tooltip.scrollTooltip:ResetToTop()
	tooltip.tip:ClearLines()
	tooltip = tooltip.tip
	local lastControl
    local itemLink, icon
	local hide
	if craftingSkillType then 
		hide = "result"
		itemLink = GetSmithingImprovedItemLink(itemBagId, itemSlotIndex, craftingSkillType) 
		_, icon = GetSmithingImprovedItemInfo(itemBagId, itemSlotIndex, craftingSkillType)
	else
		hide = "source"
		itemLink = GetItemLink(itemBagId, itemSlotIndex)
		icon = GetItemLinkIcon(itemLink)
	end

    if itemLink and itemLink ~= "" then

	
		if tooltip.icon then
            tooltip.icon:SetTexture(icon)
            tooltip.icon:SetHidden(false)
        end

		if not IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_CRAFTING) then
			KELA_SMITHING_IMPROVED_TOOLTIP_TYPE = 0
		end
	
		
		if KELA_SMITHING_IMPROVED_TOOLTIP_TYPE == 0 then
			HideImprovementTooltipControls()
			if craftingSkillType then 
				tooltip:LayoutImproveResultSmithingItem(itemBagId, itemSlotIndex, craftingSkillType)
			else
				tooltip:LayoutImproveSourceSmithingItem(itemBagId, itemSlotIndex)
			end			
		elseif KELA_SMITHING_IMPROVED_TOOLTIP_TYPE == 1 then
		
		 --GetItemLinkFinalEnchantId (itemLink)

			local resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink = GetItemLinks(itemLink)
			local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
			local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)

			-- добавляем название вещи
			local name = GetItemLinkName(itemLink)
			-- Информация о купленной вещи
			local isByingItem = false
			local tblBuyingItems = {}
			local itemUID
			if itemUniqueId then
				tblBuyingItems = kpuiSVBuyingData["buyingTable"]			
				itemUID = Id64ToString(itemUniqueId)
				if tblBuyingItems[itemUID] ~= nil then
					name = name.." *"
					isByingItem = true
				end
			end		
			tooltip:AddItemTitle(itemLink, name)
			
			-- пустая строка
			-- AddClearLine(true)
			local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
			bodySection:AddLine(" ")
			tooltip:AddSection(bodySection)
			lastControl = bodySection

			-- основная информация
			if trueTTC or trueATT then
				if craftingSkillType then -- result tooltip
					if not ctlResultInfo then ctlResultInfo = CreateControlFromVirtual("$(parent)RInfo", tooltip, "KPUI_MainInfo") end	
					lastControl = SetSmithTradingInfo(ctlResultInfo, lastControl, priceInfoTTC, priceInfoATT, nil, selectedData)
					lastControl = AddClearLine(tooltip, lastControl, 0, 15)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
						if not ctlResultGraph then ctlResultGraph = CreateControlFromVirtual("$(parent)RGraph", tooltip, "KPUI_Graph") end							
						lastControl = SetSmithGraph (ctlResultGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, 1)
					else
						if ctlResultGraph then ctlResultGraph:SetHidden(true) end	
					end
				else
					if not ctlSourceInfo then ctlSourceInfo = CreateControlFromVirtual("$(parent)SInfo", tooltip, "KPUI_MainInfo") end	
					lastControl = SetSmithTradingInfo(ctlSourceInfo, lastControl, priceInfoTTC, priceInfoATT, nil, selectedData)
					lastControl = AddClearLine(tooltip, lastControl, 0, 15)
					if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
						if not ctlSourceGraph then ctlSourceGraph = CreateControlFromVirtual("$(parent)SGraph", tooltip, "KPUI_Graph") end							
						lastControl = SetSmithGraph (ctlSourceGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, 1)
					else
						if ctlSourceGraph then ctlSourceGraph:SetHidden(true) end	
					end
				end
			else
				local bodySection = tooltip:AcquireSection(tooltip:GetStyle("bodySection1"))
				bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
				tooltip:AddSection(bodySection)
				bodySection:ClearAnchors()
				bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
				bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
				lastControl = bodySection
				lastControl = AddClearLine(tooltip, lastControl, 0, 0)
				if hide == "source" then
					if ctlSourceInfo then ctlSourceInfo:SetHidden(true) end	
					if ctlSourceGraph then ctlSourceGraph:SetHidden(true) end					
				elseif hide == "result" then
					if ctlResultInfo then ctlResultInfo:SetHidden(true) end						
					if ctlResultGraph then ctlResultGraph:SetHidden(true) end
				end				
			end
			-- Информация о купленной вещи
			if isByingItem then
				local strBuyInfo = GetBuyInfo(tblBuyingItems, itemUID)
				lastControl = SetSmithNotes(tooltip, lastControl, strBuyInfo)			
			end					
			-- Предыдущие продажи
			if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
				if craftingSkillType then -- result tooltip
					if not ctlResultListings then ctlResultListings = CreateControlFromVirtual("$(parent)RListings", tooltip, "KPUI_PreviousListings") end	
					lastControl = SetSmithListings(ctlResultListings, lastControl, listingItemsTable)
				else
					if not ctlSourceListings then ctlSourceListings = CreateControlFromVirtual("$(parent)SListings", tooltip, "KPUI_PreviousListings") end	
					lastControl = SetSmithListings(ctlSourceListings, lastControl, listingItemsTable)
				end
				lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
			else
				if hide == "source" then
					if ctlSourceListings then ctlSourceListings:SetHidden(true) end	
				elseif hide == "result" then
					if ctlResultListings then ctlResultListings:SetHidden(true) end	
				end	
			end	
			-- Другой уровень вещей
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_QUALITY) and (normalItemLink or fineItemLink or superiorItemLink or epicItemLink or legendaryItemLink) then
				local notSuccess
				if craftingSkillType then -- result tooltip
					if not ctlResultOther then ctlResultOther = CreateControlFromVirtual("$(parent)ROther", tooltip, "KPUI_OtherQualityInfo") end	
					lastControl, notSuccess = SetSmithQualityPrices(tooltip, ctlResultOther, lastControl, itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink) --, traitInformation, tooltip)
				else
					if not ctlSourceOther then ctlSourceOther = CreateControlFromVirtual("$(parent)SOther", tooltip, "KPUI_OtherQualityInfo") end	
					lastControl, notSuccess = SetSmithQualityPrices(tooltip, ctlSourceOther, lastControl, itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink) --, traitInformation, tooltip)
				end
				if notSuccess then 
					if hide == "source" then
						if ctlSourceOther then ctlSourceOther:SetHidden(true) end	
					elseif hide == "result" then
						if ctlResultOther then ctlResultOther:SetHidden(true) end		
					end	
				else
					lastControl = AddClearLine(tooltip, lastControl, 0, -15)	
				end
			else
				if hide == "source" then
					if ctlSourceOther then ctlSourceOther:SetHidden(true) end	
				elseif hide == "result" then
					if ctlResultOther then ctlResultOther:SetHidden(true) end		
				end	
			end		
		else
			HideImprovementTooltipControls(hide)
		end
	else
		HideImprovementTooltipControls(hide)				
    end

	if craftingSkillType then -- result tooltip
		--Add line for tradeable loss
		if IsItemBoPAndTradeable(itemBagId, itemSlotIndex) then
			local section = tooltip:AcquireSection(tooltip:GetStyle("bodySection"))
			section:AddLine(GetString(SI_SMITHING_IMPROVEMENT_TRADE_BOP_WILL_BECOME_UNTRADEABLE), tooltip:GetStyle("bodyDescription"), tooltip:GetStyle("failed"))
			tooltip:AddSection(section)
		end
	end
	
end

function ZO_Tooltip:LayoutTradingTooltip(currentScene, itemLink, selectedData, tooltipType, parentControl, leftAnchor, offsetX, offsetY, itemUniqueId)


	KELA_TRADINGHOUSE_CURRENTSCENE = currentScene
	KELA_TRADINGHOUSE_CURRENT_SELECTEDDATA = selectedData
	
	local isCrafting

	if currentScene == "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS" and leftAnchor then
		KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_TRADING_TOOLTIP.bgType = KPUI_GAMEPAD_TOOLTIP_DARK_BG	
	-- elseif currentScene == "GAMEPAD_SMITHING_IMPROVEMENT" then
		-- isCrafting = true
	else
		KPUI_GAMEPAD_TOOLTIPS.tooltips.KPUI_GAMEPAD_TRADING_TOOLTIP.bgType = KPUI_GAMEPAD_TOOLTIP_NORMAL_BG
	end
	
	local currentSceneName = SCENE_MANAGER:GetCurrentScene():GetName()
	if currentSceneName ~= "tradingHousePreview_Gamepad" then

		if offsetX == nil then offsetX = 0 end
		if offsetY == nil then offsetY = 0 end

		local tooltypeTradingControl = KPUI_GAMEPAD_TOOLTIPS:GetTooltipInfo(tooltipType).control
		tooltypeTradingControl:ClearAnchors()
		if leftAnchor then 
			tooltypeTradingControl:SetAnchor(TOPRIGHT, parentControl, TOPLEFT, -offsetX, offsetY) 
			tooltypeTradingControl:SetAnchor(BOTTOMRIGHT, parentControl, BOTTOMLEFT, -offsetX, offsetY) 	
		-- elseif isCrafting then
			-- tooltypeTradingControl:SetAnchor(TOPRIGHT, parentControl, TOPRIGHT, -10, 53) 
			-- tooltypeTradingControl:SetAnchor(BOTTOMRIGHT, parentControl, BOTTOMRIGHT, -10, -125) 		
		else
			tooltypeTradingControl:SetAnchor(TOPLEFT, parentControl, TOPRIGHT, offsetX, offsetY) 
			tooltypeTradingControl:SetAnchor(BOTTOMLEFT, parentControl, BOTTOMRIGHT, offsetX, offsetY) 	
		end	

		local iconBank = zo_iconFormatInheritColor("esoui/art/icons/servicemappins/servicepin_bank.dds", 20, 20)
		local strGold = zo_strformat("|t20:20:<<3>>|t |<<1>> (<<2>>)|r ", ZO_CurrencyControl_FormatCurrency(GetCurrencyAmount(CURT_MONEY)), iconBank..ZO_CurrencyControl_FormatCurrency(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)), GetCurrencyGamepadIcon(CURT_MONEY))
		local iconBag = zo_iconFormatInheritColor("EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_inventory.dds", 20, 20)
		local strBackpack = iconBag.." "..zo_strformat(SI_GAMEPAD_INVENTORY_CAPACITY_FORMAT, GetNumBagUsedSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK))			
		local updatedString = ""
		if TamrielTradeCentre ~= nil then
			updatedString = TamrielTradeCentrePrice:GetPriceTableUpdatedDateString()
		end
		
		if KelaIsSceneTradingHouse(currentScene) then	
			local currentGuildId = GetSelectedTradingHouseGuildId()
			local guildName = GetGuildName(currentGuildId)
			if currentGuildId and guildName ~= "" then
				local allianceId = GetGuildAlliance(currentGuildId)
				local icon = GetLargeAllianceSymbolIcon(allianceId)				
				local guildColor = colors.COLOR_WHITE
				if ArkadiusTradeTools ~= nil then
					guildColor = ArkadiusTradeTools:GetGuildColor(guildName)
				end
				local currentListings, maxListings = GetTradingHouseListingCounts()
				guildName = zo_iconFormat(icon, 22, 22).." "..guildColor:Colorize(guildName.." ("..tostring(currentListings).."/"..tostring(maxListings)..")")
				KPUI_GAMEPAD_TOOLTIPS:SetStatusLabelText(tooltipType, guildName, strGold..", "..strBackpack, "* "..colors.COLOR_TTC:Colorize(GetString(KELA_TRADING_TTC_TITLE)).." - "..string.lower(updatedString), true)
			else
				KPUI_GAMEPAD_TOOLTIPS:SetStatusLabelText(tooltipType, "", strGold..", "..strBackpack, "* "..colors.COLOR_TTC:Colorize(GetString(KELA_TRADING_TTC_TITLE)).." - "..string.lower(updatedString), true)
			end
		else
			KPUI_GAMEPAD_TOOLTIPS:SetStatusLabelText(tooltipType, "", strGold..", "..strBackpack, "* "..colors.COLOR_TTC:Colorize(GetString(KELA_TRADING_TTC_TITLE)).." - "..string.lower(updatedString), true)
		end

		-- заполняем
		local stackCount = selectedData and selectedData.stackCount
		if not stackCount then stackCount = 1 end
		local lastControl
		if itemLink then
			local listingItemsTable = KelaGetItemLinkListingTable(itemLink)
			local resultItemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink = GetItemLinks(itemLink)
			-- название вещи
			local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
			local nameColor = GetItemQualityColor(GetItemLinkDisplayQuality(itemLink))
			local colorizedItemName = nameColor:Colorize(name)
			-- Информация о купленной вещи
			local isByingItem = false
			local tblBuyingItems = {}
			local itemUID
			if itemUniqueId then
				tblBuyingItems = kpuiSVBuyingData["buyingTable"]			
				itemUID = Id64ToString(itemUniqueId)
				if tblBuyingItems[itemUID] ~= nil then
					colorizedItemName = colorizedItemName.." *"
					isByingItem = true
				end
			end			
			local function AddTitle(lastControl)
				local bodySection = self:AcquireSection(self:GetStyle("bodySection1"))
				bodySection:AddLine(colorizedItemName, self:GetStyle("title"))
				self:AddSection(bodySection)
				if lastControl then
					bodySection:ClearAnchors()
					bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 10)
					bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 10)								
				end
				return bodySection			
			end
			-- информация о уровне выгоды в гильдиях по типу товара	
			if KelaIsSceneTradingHouse(currentScene) and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_GUILDSTAT) then
				local itemTradeCategory = KelaGetItemTradeCategory(itemLink)
				if KELA_ATT_GUILD_STAT[itemTradeCategory] then 
					local bodySection = self:AcquireSection(self:GetStyle("bodySection1"))
					bodySection:AddLine(colors.GENERAL_COLOR_NORMAL:Colorize(GetString(KELA_TRADING_TRADING_ITEMTYPE))..GetString("KELA_TRADING_ITEMTYPE_SALES_BYGUILDS", itemTradeCategory), self:GetStyle("bodyHeader"))
					self:AddSection(bodySection)			
					lastControl = bodySection
					if not ctlItemTypeGuildStat then ctlItemTypeGuildStat = CreateControlFromVirtual("$(parent)ctlItemTypeGuildStat", self, "KPUI_ItemTypeGuildStat") end	
					lastControl = ctlItemTypeGuildStat.SetItemTypeGuildStat(itemLink, itemTradeCategory, lastControl)
					ctlItemTypeGuildStat:SetHidden(false)
					lastControl = AddTitle(lastControl)
				else
					if ctlItemTypeGuildStat then ctlItemTypeGuildStat:SetHidden(true) end	
					lastControl = AddTitle()
				end
			else
				if ctlItemTypeGuildStat then ctlItemTypeGuildStat:SetHidden(true) end	
				lastControl = AddTitle()
			end
			local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemLink)
			-- основная информация
			if trueTTC or trueATT then
				if not ctlTradingInfo then ctlTradingInfo = CreateControlFromVirtual("$(parent)Info", self, "KPUI_MainInfo") end	
				lastControl, effectOfDeal, isTwoRowFooter = SetSmithTradingInfo(ctlTradingInfo, lastControl, priceInfoTTC, priceInfoATT, currentScene, selectedData, stackCount)
				local offsetY = 15
				if isTwoRowFooter and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then offsetY = 35 end
				lastControl = AddClearLine(self, lastControl, 0, offsetY)
				if effectOfDeal and effectOfDeal ~= "" then
					SafeAddString(SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_DIALOG_TEXT, GetString(KELA_TRADING_TRADING_CONFIRM_BUY).."\n\n"..effectOfDeal, 1)
					SafeAddString(SI_GAMEPAD_TRADING_HOUSE_CONFIRM_BUY_MULTIPLE_DIALOG_TEXT, GetString(KELA_TRADING_TRADING_CONFIRM_BUY_MULT).."\n\n"..effectOfDeal, 0)
				end
				if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_ATTINFO) then
					if not KPUI_ATTGraph then KPUI_ATTGraph = CreateControlFromVirtual("$(parent)ProvGraph", self, "KPUI_Graph") end							
					lastControl = SetSmithGraph (KPUI_ATTGraph, lastControl, itemLink, priceInfoTTC, priceInfoATT, stackCount)
				else
					if KPUI_ATTGraph then KPUI_ATTGraph:SetHidden(true) end	
				end
			else
				local bodySection = self:AcquireSection(self:GetStyle("bodySection1"))
				bodySection:AddLine(GetString(KELA_TRADING_TRADING_NOTINFO))
				self:AddSection(bodySection)
				bodySection:ClearAnchors()
				bodySection:SetAnchor(TOPLEFT, lastControl, BOTTOMLEFT, 0, 0)
				bodySection:SetAnchor(TOPRIGHT, lastControl, BOTTOMRIGHT, 0, 0)					
				lastControl = bodySection
				lastControl = AddClearLine(self, lastControl, 0, 0)
				if ctlTradingInfo then ctlTradingInfo:SetHidden(true) end	
				if KPUI_ATTGraph then KPUI_ATTGraph:SetHidden(true) end	
			end
			-- Информация о купленной вещи
			if isByingItem then
				local strBuyInfo = GetBuyInfo(tblBuyingItems, itemUID)
				lastControl = SetSmithNotes(self, lastControl, strBuyInfo)			
			end			
			-- Предыдущие продажи
			if next(listingItemsTable) ~= nil and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_LISTINGS) then
				if not ctlPreviousListings then ctlPreviousListings = CreateControlFromVirtual("$(parent)Listings", self, "KPUI_PreviousListings") end	
				lastControl = SetSmithListings(ctlPreviousListings, lastControl, listingItemsTable)
				lastControl = AddClearLine(self, lastControl, 0, -15)	
			else
				if ctlPreviousListings then ctlPreviousListings:SetHidden(true) end	
			end	
			-- Другой уровень вещей
			if IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_QUALITY) and (normalItemLink or fineItemLink or superiorItemLink or epicItemLink or legendaryItemLink) then
				local notSuccess
				if not ctlOtherQualityInfo then ctlOtherQualityInfo = CreateControlFromVirtual("$(parent)Other", self, "KPUI_OtherQualityInfo") end	
				lastControl, notSuccess = SetSmithQualityPrices(self, ctlOtherQualityInfo, lastControl, itemLink, normalItemLink, fineItemLink, superiorItemLink, epicItemLink, legendaryItemLink)
				if notSuccess then 
					if ctlOtherQualityInfo then ctlOtherQualityInfo:SetHidden(true) end	
				else
					lastControl = AddClearLine(self, lastControl, 0, -15)	
				end
			else
				if ctlOtherQualityInfo then ctlOtherQualityInfo:SetHidden(true) end	
			end		
			-- Продукция
			if resultItemLink and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_PRODUCTION) then
				local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(resultItemLink)
				if trueTTC or trueATT then
					if not ctlProductMaterialInfoRow then ctlProductMaterialInfoRow = CreateControlFromVirtual("$(parent)ctlProductMaterialInfoRow", self, "KPUI_ProductMaterialInfo") end	
					lastControl = SetProductionPrices(ctlProductMaterialInfoRow, lastControl, resultItemLink, priceInfoTTC, priceInfoATT)
				else
					if ctlProductMaterialInfoRow then ctlProductMaterialInfoRow:SetHidden(true) end	
				end
			else
				if ctlProductMaterialInfoRow then ctlProductMaterialInfoRow:SetHidden(true) end	
			end				
			-- таблица компонентов для крафта
			local isATTCraftingInfo, craftingComponentPrices = KelaGetCurrentATTCraftingInfo(itemLink)
			if isATTCraftingInfo and IsKPUITradingHouseSettingEnabled(KELA_SETTING_PANEL_TRADE_TOOLTIP_COMPONENTS) then 
				if not ctlCraftingComponentsInfo then ctlCraftingComponentsInfo = CreateControlFromVirtual("$(parent)ctlCraftingInfo", self, "KPUI_CraftingInfo") end	
				SetCraftingComponents(ctlCraftingComponentsInfo, lastControl, craftingComponentPrices)
			else
				if ctlCraftingComponentsInfo then ctlCraftingComponentsInfo:SetHidden(true) end					
			end
			lastControl = AddClearLine(self, lastControl, 0, -15)	
		else
			HideTradingTooltipControls()
			KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)	
		end
	else
		KPUI_GAMEPAD_TOOLTIPS:HideTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP)
	end
end



--Integration with TamrielTradeCentre and ArkadiusTradeTools
function GetATTPriceAndStatus(itemLink)
	if not ArkadiusTradeTools then
		return "", ""
	end
	
	local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
    local seconds_in_day = ArkadiusTradeToolsSales.TooltipExtension.SECONDS_IN_DAY or 60 * 60 * 24
    local days = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) or 30
	local itemSales = ArkadiusTradeToolsSales:GetItemSalesInformation(itemLink, GetTimeStamp() - days * seconds_in_day) --	30 * 86400)



	local itemQuality = GetItemLinkQuality(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	for link, sales in pairs(itemSales) do
		averagePrice = 0
		quantity = 0

		--link == itemLink
		if KelaCompareLink(link, itemLink) then
			local minPrice = math.huge
			local maxPrice = 0
			local price
			for _, sale in pairs(sales) do
				price = sale.price / sale.quantity
				if (price < minPrice) then 
					minPrice = price 
				end
				if (price > maxPrice) then 
					maxPrice = price 
				end
			end
		end

		for _, sale in pairs(sales) do
			averagePrice = averagePrice + sale.price
			quantity = quantity + sale.quantity
		end

		if (quantity > 0) then
			averagePrice = math.attRound(averagePrice / quantity, 2)
		else
			averagePrice = 0
		end

		--averagePrice = KelaLocalizedFormatNumber(averagePrice, 2)
		
		if KelaCompareLink(link, itemLink) then
			if (quantity > 0) then
				if (#sales ~= quantity) then
					statsString = zo_strformat("|cf58585<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGSYITEMS), KelaLocalizedFormatNumber(#sales, 0), KelaLocalizedFormatNumber(quantity, 0)))
				else
					statsString = zo_strformat("|cf58585<<1>>|r", string.format(GetString(KELA_MM_PRICE_XLISTINGS), KelaLocalizedFormatNumber(#sales, 0)))
				end
				return averagePrice, statsString
			end
		end
	end
	return nil, nil 
end

function KelaGetATTPriceInfo(itemLink)
	local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
	local ArkadiusTradeToolsTooltipExtension = ArkadiusTradeToolsSales.TooltipExtension


    local seconds_in_day = ArkadiusTradeToolsTooltipExtension.SECONDS_IN_DAY or 60 * 60 * 24
    local days = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) or 30

    itemLink = ArkadiusTradeToolsSales:NormalizeItemLink(itemLink)
    if itemLink == nil then return end

    local itemSales = ArkadiusTradeToolsSales:GetItemSalesInformation(itemLink, GetTimeStamp() - days * seconds_in_day)
    local itemType = GetItemLinkItemType(itemLink)
	local minPrice = 0
    local maxPrice = 0
	local averagePrice = 0
    local quantity = 0
    local vouchers = 0

	local suggestedPrice = 0
	local suggestedQuantity = 0	
	local valueGroup1 = {}
	local valueGroup2 = {}
	local valueGroup3 = {}
	local valueGroup4 = {}
	local valueGroup5 = {}

	local guildsInfo = {}
	local guildsPrice = {}
	
    for link, sales in pairs(itemSales) do

        if KelaCompareLink(link, itemLink) then
            minPrice = math.huge
            maxPrice = 0
            local price
            for _, sale in pairs(sales) do
                price = sale.price / sale.quantity
                if (price < minPrice) then minPrice = price end
                if ((price > maxPrice) and (price ~= math.huge)) then maxPrice = price end
            end
            --- There are no sales for this item ---
            if (minPrice == math.huge) then minPrice = 0 end
			for _, sale in pairs(sales) do
				averagePrice = averagePrice + sale.price
				quantity = quantity + sale.quantity
			end

			local val1 = minPrice*1.05
			local val2 = maxPrice*0.95
			local range = maxPrice - minPrice
			local borderGroup1 = range*0.25
			local borderGroup2 = range*0.50
			local borderGroup3 = range*0.75
			-- local borderGroup4 = range*0.80
			for _, sale in pairs(sales) do
				local salePrice = sale.price/sale.quantity
				if salePrice >= val1 and salePrice < borderGroup1 then
					valueGroup1[#valueGroup1 + 1] = salePrice
				elseif salePrice >= borderGroup1 and salePrice < borderGroup2 then
					valueGroup2[#valueGroup2 + 1] = salePrice
				elseif salePrice >= borderGroup2 and salePrice < borderGroup3 then
					valueGroup3[#valueGroup3 + 1] = salePrice
				-- elseif salePrice >= borderGroup3 and salePrice < borderGroup4 then
					-- valueGroup4[#valueGroup4 + 1] = salePrice
				elseif salePrice >= borderGroup3 and salePrice <= val2 then
					valueGroup4[#valueGroup4 + 1] = salePrice
				end
			end	
			
			for _, sale in pairs(sales) do
				KelaSetValueIfNil(guildsInfo, sale.guildName, 0)
				guildsInfo[sale.guildName] = guildsInfo[sale.guildName] + sale.quantity --1
			end	
			for _, sale in pairs(sales) do
				local salePrice = sale.price --/sale.quantity
				KelaSetValueIfNil(guildsPrice, sale.guildName, 0)
				guildsPrice[sale.guildName] = guildsPrice[sale.guildName] + salePrice
			end	

        end

		for guildName, countSales in pairs(guildsInfo) do
			if (countSales > 0) then
				guildsPrice[guildName] = math.attRound(guildsPrice[guildName] / countSales, 2)
			else
				guildsPrice[guildName] = 0
			end
		end

        if (quantity > 0) then
            averagePrice = math.attRound(averagePrice / quantity, 2)
        else
            averagePrice = 0
        end

		local selectedSales = valueGroup1
		if #selectedSales < #valueGroup2 then selectedSales = valueGroup2 end
		if #selectedSales < #valueGroup3 then selectedSales = valueGroup3 end
		if #selectedSales < #valueGroup4 then selectedSales = valueGroup4 end
		-- if #selectedSales < #valueGroup5 then selectedSales = valueGroup5 end
		if #selectedSales >= 3 then
			for _, price in ipairs(selectedSales) do
				suggestedPrice = suggestedPrice + price
				suggestedQuantity = suggestedQuantity + 1
			end
		end
        if (suggestedQuantity > 0) then
            suggestedPrice = math.attRound(suggestedPrice / suggestedQuantity, 2)
        else
            suggestedPrice = 0
        end

        if KelaCompareLink(link, itemLink) then
            if (quantity > 0) then
                if (itemType == ITEMTYPE_MASTER_WRIT) then
                    vouchers = ArkadiusTradeToolsSales:GetVoucherCount(itemLink)
                end
				return minPrice, maxPrice, averagePrice, suggestedPrice, vouchers, #sales, quantity, guildsInfo, guildsPrice
            end
			
        end
    end
end

function KelaGetCurrentATTCraftingInfo(itemLink)
	
	local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
    local seconds_in_day = ArkadiusTradeToolsSales.TooltipExtension.SECONDS_IN_DAY or 60 * 60 * 24
    local days = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) or 30
    local itemType = GetItemLinkItemType(itemLink)

	fromTimeStamp = GetTimeStamp() - days * seconds_in_day

	local craftingComponentPrices = {}	



	if itemType == ITEMTYPE_MASTER_WRIT then
		craftingComponentPrices = ArkadiusTradeToolsSales:GetCrafingComponentPrices(itemLink, fromTimeStamp)
		if #craftingComponentPrices > 0 then
			return true, craftingComponentPrices
		end
	elseif itemType == ITEMTYPE_RECIPE then
		local numIngredients = GetItemLinkRecipeNumIngredients(itemLink)
	    local components = {}
		local component
		if(numIngredients > 0) then
			for i = 1, numIngredients do
				local ingredientLink = GetItemLinkRecipeIngredientItemLink(itemLink, i)
				local _, _, ingredientQuantity = GetItemLinkRecipeIngredientInfo(itemLink, i)
				component = { itemLink = ingredientLink, quantity = ingredientQuantity }
				table.insert(components, component)
			end
		end	
		for i = 1, #components do
			if ((components[i].itemLink == nil) or (components[i].quantity == nil)) then
				return false
			end
		end
		for i = 1, #components do
			local component = components[i]
			component.price = ArkadiusTradeToolsSales:GetAveragePricePerItem(component.itemLink, fromTimeStamp)
		end
		if #components > 0 then
			return true, components
		end
		
	end	
	
	return false

end

function KelaUpdateATTGraph(itemLink, graphControl, priceInfoATTSuggestedPrice, priceInfoTTCSuggestedPrice)
	local ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
	local L = ArkadiusTradeToolsSales.Localization
	local attRound = math.attRound
    local seconds_in_day = ArkadiusTradeToolsSales.TooltipExtension.SECONDS_IN_DAY or 60 * 60 * 24
    local days = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) or 30
    itemLink = ArkadiusTradeToolsSales:NormalizeItemLink(itemLink)
    if itemLink == nil then return end

    local itemSales = ArkadiusTradeToolsSales:GetItemSalesInformation(itemLink, GetTimeStamp() - days * seconds_in_day)
    local averagePrice = 0
    local quantity
    local guildColors = {}

    graphControl.object:Clear()

    for link, sales in pairs(itemSales) do
        averagePrice = 0
        quantity = 0

        if KelaCompareLink(link, itemLink) then
            local minPrice = math.huge
            local maxPrice = 0
            local price

            for _, sale in pairs(sales) do
                price = sale.price / sale.quantity

                if (price < minPrice) then minPrice = price end
                if ((price > maxPrice) and (price ~= math.huge)) then maxPrice = price end
            end

            --- There are no sales for this item ---
            if (minPrice == math.huge) then
                minPrice = 0
            end


			if priceInfoTTCSuggestedPrice then
				if priceInfoTTCSuggestedPrice < minPrice then minPrice = priceInfoTTCSuggestedPrice - minPrice end
				if priceInfoTTCSuggestedPrice > maxPrice then maxPrice = priceInfoTTCSuggestedPrice + maxPrice end
			end



			graphControl.object:SetRange(GetTimeStamp() - days * seconds_in_day, GetTimeStamp(), minPrice, maxPrice)
			graphControl.object:SetXLabels(-days .. " " .. L["ATT_STR_DAYS"], -days / 2 .. " " .. L["ATT_STR_DAYS"], L["ATT_STR_NOW"])
			graphControl.object:SetYLabels(ArkadiusTradeTools:LocalizeDezimalNumber(attRound(maxPrice, 2)) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t", "", ArkadiusTradeTools:LocalizeDezimalNumber(attRound(minPrice, 2)) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t")
        end

        for _, sale in pairs(sales) do
            averagePrice = averagePrice + sale.price
            quantity = quantity + sale.quantity
            if KelaCompareLink(link, itemLink) then
                if (not guildColors[sale.guildName]) then
                    guildColors[sale.guildName] = ArkadiusTradeTools:GetGuildColor(sale.guildName)
                end

                graphControl.object:AddDot(sale.timeStamp, sale.price / sale.quantity, guildColors[sale.guildName])
            end
        end

		if priceInfoATTSuggestedPrice and priceInfoATTSuggestedPrice ~= 0 then
			graphControl.object:AddDot(GetTimeStamp(), priceInfoATTSuggestedPrice, colors.COLOR_ATT)
		end
		
		if priceInfoTTCSuggestedPrice and priceInfoTTCSuggestedPrice ~= 0 then
			graphControl.object:AddDot(GetTimeStamp(), priceInfoTTCSuggestedPrice, colors.COLOR_TTC)
		end		



    end

end

function KelaGetEffectOfDeal (priceInfoTTC, priceInfoATT, data, action, stackCount)
	
	local purchasePrice, suggestedATT, suggestedTCC

	if not stackCount then
		stackCount = 1
		if data then stackCount = data.stackCount end
	end

	if data then purchasePrice = data.purchasePrice or data.stackSellPrice end
	
	local multiplier = 1
	local IsMasterWrit = priceInfoATT and (priceInfoATT.Vouchers ~= 0)
	local colorEffectDeal
	local valueEffectDeal				
	local effectOfDeal
	local compareValuePrice
	local compareValueSuffix	
	
	if IsMasterWrit then
		multiplier = priceInfoATT.Vouchers
	end

	if priceInfoATT and priceInfoATT.SuggestedPrice then 
		suggestedATT = math.floor(priceInfoATT.SuggestedPrice)
	else
		suggestedATT = 0
	end
	if priceInfoTTC.SuggestedPrice then 
		suggestedTCC = math.floor(priceInfoTTC.SuggestedPrice)
	else
		suggestedTCC = 0
	end
	local suggestedAVG
	local suggestedATTStack
	local suggestedTCCStack
	local suggestedAVGStack
	local suggestedATTWrit
	local suggestedTCCWrit
	local suggestedAVGWrit

	suggestedATTStack = suggestedATT*stackCount
	suggestedATTWrit = suggestedATT*multiplier
	suggestedTCCStack = suggestedTCC*stackCount
	suggestedTCCWrit = suggestedTCC*multiplier

	if suggestedATT == 0 or suggestedTCC == 0 then
		suggestedAVG = 0
	else
		suggestedAVG = (suggestedATT + suggestedTCC)/2
	end
	if suggestedATTStack == 0 or suggestedTCCStack == 0 then
		suggestedAVGStack = 0
	else
		suggestedAVGStack = (suggestedATTStack + suggestedTCCStack)/2
	end
	if suggestedATTWrit == 0 or suggestedTCCWrit == 0 then
		suggestedAVGWrit = 0
	else
		suggestedAVGWrit = (suggestedATTWrit + suggestedTCCWrit)/2
	end
	
	if IsMasterWrit then
		if suggestedAVGWrit ~= 0 then
			compareValuePrice = suggestedAVGWrit 
			compareValueSuffix = colors.COLOR_WHITE:Colorize(" (AVG)")
		elseif suggestedTCCWrit ~= 0 then
			compareValuePrice = suggestedTCCWrit 
			compareValueSuffix = colors.COLOR_TTC:Colorize(" (TCC)")
		elseif suggestedATTWrit ~= 0 then
			compareValuePrice = suggestedATTWrit 
			compareValueSuffix = colors.COLOR_ATT:Colorize(" (ATT)")
		else
			compareValuePrice = 0
		end
	elseif stackCount ~= 0 then					
		if suggestedAVGStack ~= 0 then
			compareValuePrice = suggestedAVGStack 
			compareValueSuffix = colors.COLOR_WHITE:Colorize(" (AVG)")
		elseif suggestedTCCStack ~= 0 then
			compareValuePrice = suggestedTCCStack 
			compareValueSuffix = colors.COLOR_TTC:Colorize(" (TCC)")
		elseif suggestedATTStack ~= 0 then
			compareValuePrice = suggestedATTStack 
			compareValueSuffix = colors.COLOR_ATT:Colorize(" (ATT)")
		else
			compareValuePrice = 0
		end						
	else
		compareValuePrice = 0
	end
	if action then
		if action == "GAMEPAD_TRADING_HOUSE_LISTINGS" then
			colorEffectDeal = colors.COLOR_GREY
			valueEffectDeal = 0
			if compareValuePrice == 0 then 
				valueEffectDeal = "-"
			elseif compareValuePrice > purchasePrice*1.5 then 
				valueEffectDeal = 2
				colorEffectDeal = colors.COLOR_DEALBAD
			elseif compareValuePrice > purchasePrice*1.1 then 
				valueEffectDeal = 4
				colorEffectDeal = colors.COLOR_DEALGOOD
			elseif compareValuePrice > purchasePrice*0.9 then 
				valueEffectDeal = 5
				colorEffectDeal = colors.COLOR_DEALGREAT
			elseif compareValuePrice > purchasePrice*0.5 then 
				valueEffectDeal = 3
				colorEffectDeal = colors.COLOR_DEALNORMAL
			elseif compareValuePrice > 0 then 
				valueEffectDeal = 1
				colorEffectDeal = colors.COLOR_DEALTERRIBLE
			end
		end
		if action == "GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS" then
			colorEffectDeal = colors.COLOR_GREY
			valueEffectDeal = 0
			if compareValuePrice == 0 then 
				valueEffectDeal = "-"
				effectOfDeal = colors.COLOR_GREY:Colorize(GetString("KELA_TRADING_RESUMEPRICEDIALOG", 0))
			elseif compareValuePrice > purchasePrice*1.5 then 
				valueEffectDeal = 5
				colorEffectDeal = colors.COLOR_DEALGREAT
			elseif compareValuePrice > purchasePrice*1.1 then 
				valueEffectDeal = 4
				colorEffectDeal = colors.COLOR_DEALGOOD
			elseif compareValuePrice > purchasePrice*0.9 then 
				valueEffectDeal = 3
				colorEffectDeal = colors.COLOR_DEALNORMAL
			elseif compareValuePrice > purchasePrice*0.5 then 
				valueEffectDeal = 2
				colorEffectDeal = colors.COLOR_DEALBAD
			elseif compareValuePrice > 0 then 
				valueEffectDeal = 1
				colorEffectDeal = colors.COLOR_DEALTERRIBLE
			end
		
			if not effectOfDeal then effectOfDeal = colorEffectDeal:Colorize(GetString("KELA_TRADING_RESUMEPRICEDIALOG", valueEffectDeal))..compareValueSuffix end
		
		end
	end


	
	return valueEffectDeal, effectOfDeal, colorEffectDeal, suggestedTCC, suggestedATT, suggestedAVG, suggestedTCCStack, suggestedATTStack, suggestedAVGStack, suggestedTCCWrit, suggestedATTWrit, suggestedAVGWrit, compareValuePrice

end

function KelaGetEffectIfUndefined(itemData)
	local trueTTC, trueATT, priceInfoTTC, priceInfoATT = KelaGetPriceInfoTTCATT(itemData.itemLink)
	local result = 0
	local colorPrice = colors.COLOR_WHITE
	if trueTTC or trueATT then 				
		local avgPrice = priceInfoTTC.Avg
		local minPrice = priceInfoTTC.Min
		local maxPrice = priceInfoTTC.Max
		if avgPrice ~= 0 and itemData.purchasePricePerUnit ~= avgPrice then
			if itemData.purchasePricePerUnit <= minPrice + (avgPrice-minPrice)*0.1 then
				result = 5
				colorPrice = colors.COLOR_DEALGREAT
			elseif itemData.purchasePricePerUnit <= minPrice + (avgPrice-minPrice)*0.7 then
				result = 4
				colorPrice = colors.COLOR_DEALGOOD
			elseif itemData.purchasePricePerUnit <= avgPrice + (maxPrice-avgPrice)*0.3 then
				result = 3
				colorPrice = colors.COLOR_DEALNORMAL
			elseif itemData.purchasePricePerUnit <= avgPrice + (maxPrice-avgPrice)*0.7 then
				result = 2
				colorPrice = colors.COLOR_DEALBAD
			elseif itemData.purchasePricePerUnit >= avgPrice + (maxPrice-avgPrice)*0.7 then
				result = 1
				colorPrice = colors.COLOR_DEALTERRIBLE
			end
		end
	end
	return result, colorPrice
end

function KelaGetPriceInfoTTCATT (itemLink)

	local priceInfoTTC, priceInfoATT, trueTTC, trueATT
	if TamrielTradeCentre ~= nil then
		local price = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if price then 
			priceInfoTTC = price 
			trueTTC = true
		else
			priceInfoTTC = {
			Avg = 0,
			Max = 0,
			Min = 0,
			EntryCount = 0,
			AmountCount = 0,
			SuggestedPrice = 0,
			}			 
			trueTTC = false		
		end
	end
	if ArkadiusTradeTools ~= nil then 
		local minPrice, maxPrice, averagePrice, suggestedPrice, vouchers, sales, quantity, guildsInfo, guildsPrice = KelaGetATTPriceInfo(itemLink)
		if quantity then
			priceInfoATT = {
			Avg = averagePrice,
			Max = maxPrice,
			Min = minPrice,
			EntryCount = sales,
			AmountCount = quantity,
			SuggestedPrice = suggestedPrice,
			Vouchers = vouchers,
			GuildsInfo = guildsInfo,
			GuildsPrice = guildsPrice,
			}
			trueATT = true
		else
			priceInfoATT = {
			Avg = 0,
			Max = 0,
			Min = 0,
			EntryCount = 0,
			AmountCount = 0,
			SuggestedPrice = 0,
			Vouchers = 0,
			GuildsInfo = {},
			GuildsPrice = {},
			}
			trueATT = false
		end
	end
	return trueTTC, trueATT, priceInfoTTC, priceInfoATT
end
