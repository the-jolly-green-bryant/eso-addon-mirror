local KelaPadUIListingData = {
	name = "KelaPadUIListingData",	
}
local SearchAdditionalDelay = 1000
KELA_LISTING_DATA_RETENTION_PERIOD = 30
KELA_LISTING_DATA_HISTORY_PERIOD = ZO_ONE_DAY_IN_SECONDS
KPUI_ICON_TRADED = "|t14:14:KelaPadUI/kpui_textures/traded.dds|t"
KPUI_ICON_SOLD = "|t14:14:KelaPadUI/kpui_textures/sold.dds|t"
KPUI_ICON_RECALLED = "|t14:14:KelaPadUI/kpui_textures/recalled.dds|t"

KELA_ATT_GUILD_STAT = {}

--настройка категорий для статистики продаж по типу
KELA_TRADE_CATEGORY_MISCELLANEOUS				= 1
KELA_TRADE_CATEGORY_WEAPONS						= 2
KELA_TRADE_CATEGORY_ARMOR						= 3
KELA_TRADE_CATEGORY_JEWELRY 					= 4
KELA_TRADE_CATEGORY_ALCHEMY_REAGENTS			= 5
KELA_TRADE_CATEGORY_ALCHEMY_BASE				= 6
KELA_TRADE_CATEGORY_ALCHEMY_POTION				= 7
KELA_TRADE_CATEGORY_ALCHEMY_POISON				= 8
KELA_TRADE_CATEGORY_PROVISIONING_MATERIAL		= 9
KELA_TRADE_CATEGORY_PROVISIONING_DRINK			= 10
KELA_TRADE_CATEGORY_PROVISIONING_FOOD			= 11
KELA_TRADE_CATEGORY_CRAFTING_RAW				= 12
KELA_TRADE_CATEGORY_CRAFTING_MATERIAL			= 13
KELA_TRADE_CATEGORY_CRAFTING_BOOSTER			= 14
KELA_TRADE_CATEGORY_CRAFTING_TRAIT				= 15
KELA_TRADE_CATEGORY_CRAFTING_STYLE_MATERIAL		= 16
KELA_TRADE_CATEGORY_STYLE_MOTIF					= 17
KELA_TRADE_CATEGORY_MASTER_WRIT					= 18
KELA_TRADE_CATEGORY_RECIPES						= 19
KELA_TRADE_CATEGORY_FURNISHING_MATERIAL			= 20
KELA_TRADE_CATEGORY_FURNISHING					= 21
KELA_TRADE_CATEGORY_SIEGES						= 22
KELA_TRADE_CATEGORY_ENCHANTING_RUNE				= 23
KELA_TRADE_CATEGORY_ENCHANTING_GLYPH			= 24
KELA_TRADE_CATEGORY_TOOL						= 25
KELA_TRADE_CATEGORY_LOCKPICK					= 26
KELA_TRADE_CATEGORY_LURE						= 27
KELA_TRADE_CATEGORY_SOUL_GEM					= 28
KELA_TRADE_CATEGORY_FISH						= 29
KELA_TRADE_CATEGORY_TROPHY						= 30
KELA_TRADE_CATEGORY_COLLECTIBLE					= 31
KELA_TRADE_CATEGORY_TREASURE					= 32
KELA_TRADE_CATEGORY_TRASH						= 33

local ITEM_TYPE_TO_CATEGORY_MAP = {
	--оружие
	[ITEMTYPE_WEAPON]						= KELA_TRADE_CATEGORY_WEAPONS,
	--алхимические ингредиенты
    [ITEMTYPE_REAGENT] 						= KELA_TRADE_CATEGORY_ALCHEMY_REAGENTS,
	--алхимические растворители
    [ITEMTYPE_POTION_BASE] 					= KELA_TRADE_CATEGORY_ALCHEMY_BASE,
    [ITEMTYPE_POISON_BASE] 					= KELA_TRADE_CATEGORY_ALCHEMY_BASE,
	--зелья
    [ITEMTYPE_POTION] 						= KELA_TRADE_CATEGORY_ALCHEMY_POTION,
	--яды
	[ITEMTYPE_POISON] 						= KELA_TRADE_CATEGORY_ALCHEMY_POISON,
	--ингредиенты для снабжения
    [ITEMTYPE_INGREDIENT] 					= KELA_TRADE_CATEGORY_PROVISIONING_MATERIAL,
    [ITEMTYPE_ADDITIVE]						= KELA_TRADE_CATEGORY_PROVISIONING_MATERIAL,
    [ITEMTYPE_SPICE] 						= KELA_TRADE_CATEGORY_PROVISIONING_MATERIAL,
    [ITEMTYPE_FLAVORING] 					= KELA_TRADE_CATEGORY_PROVISIONING_MATERIAL,
	--питьё
    [ITEMTYPE_DRINK] 						= KELA_TRADE_CATEGORY_PROVISIONING_DRINK,		
	--еда
    [ITEMTYPE_FOOD] 						= KELA_TRADE_CATEGORY_PROVISIONING_FOOD,
	--сырьё для ремесла
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] 	= KELA_TRADE_CATEGORY_CRAFTING_RAW,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] 		= KELA_TRADE_CATEGORY_CRAFTING_RAW,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL]	 	= KELA_TRADE_CATEGORY_CRAFTING_RAW,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL]	= KELA_TRADE_CATEGORY_CRAFTING_RAW,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] 	= KELA_TRADE_CATEGORY_CRAFTING_RAW,
	--ремесленные материалы
    [ITEMTYPE_BLACKSMITHING_MATERIAL] 		= KELA_TRADE_CATEGORY_CRAFTING_MATERIAL,
    [ITEMTYPE_CLOTHIER_MATERIAL] 			= KELA_TRADE_CATEGORY_CRAFTING_MATERIAL,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] 	= KELA_TRADE_CATEGORY_CRAFTING_MATERIAL,
    [ITEMTYPE_WOODWORKING_MATERIAL] 		= KELA_TRADE_CATEGORY_CRAFTING_MATERIAL,
	--усилители
    [ITEMTYPE_BLACKSMITHING_BOOSTER] 		= KELA_TRADE_CATEGORY_CRAFTING_BOOSTER,
    [ITEMTYPE_CLOTHIER_BOOSTER] 			= KELA_TRADE_CATEGORY_CRAFTING_BOOSTER,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] 		= KELA_TRADE_CATEGORY_CRAFTING_BOOSTER,
    [ITEMTYPE_WOODWORKING_BOOSTER] 			= KELA_TRADE_CATEGORY_CRAFTING_BOOSTER,	
	--особенности экипировки
    [ITEMTYPE_ARMOR_TRAIT] 					= KELA_TRADE_CATEGORY_CRAFTING_TRAIT,
    [ITEMTYPE_WEAPON_TRAIT] 				= KELA_TRADE_CATEGORY_CRAFTING_TRAIT,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] 			= KELA_TRADE_CATEGORY_CRAFTING_TRAIT,
    [ITEMTYPE_JEWELRY_TRAIT] 				= KELA_TRADE_CATEGORY_CRAFTING_TRAIT,
	-- материалы стилей
    [ITEMTYPE_STYLE_MATERIAL] 				= KELA_TRADE_CATEGORY_CRAFTING_STYLE_MATERIAL,
    [ITEMTYPE_RAW_MATERIAL] 				= KELA_TRADE_CATEGORY_CRAFTING_STYLE_MATERIAL,
	--мотивы стилей
    [ITEMTYPE_RACIAL_STYLE_MOTIF] 			= KELA_TRADE_CATEGORY_STYLE_MOTIF,
	--мастерские заказы
	[ITEMTYPE_MASTER_WRIT] 					= KELA_TRADE_CATEGORY_MASTER_WRIT,
	--рецепты и чертежи
    [ITEMTYPE_RECIPE] 						= KELA_TRADE_CATEGORY_RECIPES,
	--материалы для обстановки
	[ITEMTYPE_FURNISHING_MATERIAL] 			= KELA_TRADE_CATEGORY_FURNISHING_MATERIAL,	
	--обстановка
	[ITEMTYPE_FURNISHING] 					= KELA_TRADE_CATEGORY_FURNISHING,
	--военное
    [ITEMTYPE_SIEGE] 						= KELA_TRADE_CATEGORY_SIEGES,
    [ITEMTYPE_AVA_REPAIR] 					= KELA_TRADE_CATEGORY_SIEGES,
	--руны
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] 		= KELA_TRADE_CATEGORY_ENCHANTING_RUNE,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] 		= KELA_TRADE_CATEGORY_ENCHANTING_RUNE,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] 		= KELA_TRADE_CATEGORY_ENCHANTING_RUNE,
	--глифы
    [ITEMTYPE_GLYPH_WEAPON] 				= KELA_TRADE_CATEGORY_ENCHANTING_GLYPH,
    [ITEMTYPE_GLYPH_ARMOR] 					= KELA_TRADE_CATEGORY_ENCHANTING_GLYPH,
    [ITEMTYPE_GLYPH_JEWELRY] 				= KELA_TRADE_CATEGORY_ENCHANTING_GLYPH,
	--инструменты
    [ITEMTYPE_TOOL] 						= KELA_TRADE_CATEGORY_TOOL,
	[ITEMTYPE_GROUP_REPAIR]					= KELA_TRADE_CATEGORY_TOOL,
	--отмычки
    [ITEMTYPE_LOCKPICK] 					= KELA_TRADE_CATEGORY_LOCKPICK,
	--наживка
    [ITEMTYPE_LURE] 						= KELA_TRADE_CATEGORY_LURE,
	--камни душ
    [ITEMTYPE_SOUL_GEM] 					= KELA_TRADE_CATEGORY_SOUL_GEM,
	--рыба
	[ITEMTYPE_FISH]							= KELA_TRADE_CATEGORY_FISH,
	--трофеи
	[ITEMTYPE_TROPHY]						= KELA_TRADE_CATEGORY_TROPHY,
	--коллекционные предметы
	[ITEMTYPE_COLLECTIBLE]					= KELA_TRADE_CATEGORY_COLLECTIBLE,
	--сокровища
	[ITEMTYPE_TREASURE]						= KELA_TRADE_CATEGORY_TREASURE,
	--мусор
	[ITEMTYPE_TRASH]						= KELA_TRADE_CATEGORY_TRASH,
}
local ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP = {
    [EQUIP_TYPE_CHEST] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_FEET] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_HAND] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_HEAD] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_LEGS] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_SHOULDERS] 	= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_WAIST] 		= KELA_TRADE_CATEGORY_ARMOR,
    [EQUIP_TYPE_NECK] 		= KELA_TRADE_CATEGORY_JEWELRY,
    [EQUIP_TYPE_RING] 		= KELA_TRADE_CATEGORY_JEWELRY,
}
function KelaGetItemTradeCategory(itemLink)
    local category = KELA_TRADE_CATEGORY_MISCELLANEOUS 
	local itemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_ARMOR then
		local equipType = GetItemLinkEquipType(itemLink)
		category = ARMOR_EQUIP_TYPE_TO_CATEGORY_MAP[equipType]
    elseif ITEM_TYPE_TO_CATEGORY_MAP[itemType] ~= nil then 
		category = ITEM_TYPE_TO_CATEGORY_MAP[itemType]
	end
	return category
end

-- обрабатываем добавление/удаление товара в таблицу
function KelaAddToListingTable(BAG_BACKPACK, listingIndex, stackCount, desiredPrice)
	local listingTime, itemLink, currentGuildId, guildName 
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	listingTime = GetTimeStamp()
	itemLink = GetItemLink(BAG_BACKPACK, listingIndex)
	-- itemLinkName = GetItemLinkName(itemLink)
	currentGuildId = GetSelectedTradingHouseGuildId()
	if currentGuildId then guildName = GetGuildName(currentGuildId) end
	KelaSetValueIfNil(kpuiSVListingData["listingTable"], listingTime, {})
	kpuiSVListingData["listingTable"][listingTime] = {
		["itemLink"] = itemLink,
		-- ["itemLinkName"] = itemLinkName, 
		["stackCount"] = stackCount, 
		["guildId"] = currentGuildId,
		["guildName"] = guildName,
		["desiredPrice"] = desiredPrice,
		["result"] = KPUI_ICON_TRADED, 
		["seller"] = kelaPlayerAccountName, 
		}
end		
function KelaRemoveFromListingTable(listingIndex, stackCount, desiredPrice, timeRemaining, itemSoldLink, seller, timeSinceEvent, guild)

	local listingTime, removingTime, itemLink, currentGuildId, guildName, resultIcon
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	local unknownMustAdd = false
	if timeSinceEvent then 
		removingTime = GetTimeStamp() - timeSinceEvent
	else
		removingTime = GetTimeStamp()
	end
	-- если есть ссылка на предмет, то пришла информация о продаже с ТТС/ATT, если нет, то удаляет игрок
	if not itemSoldLink then 
		itemLink = GetTradingHouseListingItemLink(listingIndex) 
		resultIcon = KPUI_ICON_RECALLED
		unknownMustAdd = true
		listingTime = removingTime - (ZO_ONE_MONTH_IN_SECONDS - timeRemaining)
	else
		itemLink = itemSoldLink
		resultIcon = KPUI_ICON_SOLD
		unknownMustAdd = (kelaPlayerAccountName == seller)
		listingTime = removingTime
	end
	-- itemLinkName = GetItemLinkName(itemLink)
	
	if type(guild) == "string" then 
		guildName = guild
		
		for i = 1, GetNumGuilds() do
			local id = GetGuildId(i)
			local name = GetGuildName(id)
			if name ~= "" and name == guildName then
				currentGuildId = id
				break
			end
		end		
	
	else
		if type(guild) == "number" then 
			currentGuildId = guild
		else
			currentGuildId = GetSelectedTradingHouseGuildId()
		end	
		if currentGuildId then guildName = GetGuildName(currentGuildId) end	
	end

	if guildName == nil then return end

	local blnRemoved
	for startTime, listingItem in pairs(kpuiSVListingData["listingTable"]) do
	
		local currentSeller
		if seller == nil or seller == listingItem["seller"] then
			currentSeller = true			
		end


		if KelaCompareLink(itemLink, listingItem["itemLink"]) and listingItem["stackCount"] == stackCount and listingItem["desiredPrice"] == desiredPrice and listingItem["guildName"] == guildName and currentSeller then
			if listingItem["result"] == KPUI_ICON_TRADED then
				KelaSetValueIfNil(listingItem, "period", removingTime - startTime)
				listingItem["result"] = resultIcon
			end
			blnRemoved = true		
			break
		end
	end	
	-- неизвестный листинг (до мода, вероятно)
	if not blnRemoved and unknownMustAdd then
		KelaSetValueIfNil(kpuiSVListingData["listingTable"], listingTime, {})
		kpuiSVListingData["listingTable"][listingTime] = {
			["itemLink"] = itemLink,
			-- ["itemLinkName"] = itemLinkName, 
			["stackCount"] = stackCount, 
			["guildId"] = currentGuildId,
			["guildName"] = guildName,
			["desiredPrice"] = desiredPrice, 
			["period"] = removingTime - listingTime, 
			["result"] = resultIcon, 
			["seller"] = kelaPlayerAccountName, 
			}	
	end
end
function KelaGetItemLinkListingTable(itemLink)
	local listingItemsTable = {}
	for listingTime, listingItem in pairs(kpuiSVListingData["listingTable"]) do
		if KelaCompareLink(itemLink, listingItem["itemLink"]) then
			KelaSetValueIfNil(listingItemsTable, listingTime, {})
			listingItemsTable[listingTime] = listingItem
		end
	end	
	return listingItemsTable
end

-- очищаем старые записи
local function CheckingForRetentionPeriod()
	local checkingTimeStamp = GetTimeStamp() - (KELA_LISTING_DATA_RETENTION_PERIOD * ZO_ONE_DAY_IN_SECONDS) 
	for listingTime, data in pairs(kpuiSVListingData["listingTable"]) do
		if listingTime < checkingTimeStamp then 
			listingTime = nil
		end
	end	
end

local function UpdateGuildList()
	local guildsTable = kpuiSVListingData["guildsTable"]
	--Get a list of current guilds
	for i = 1, GetNumGuilds() do
		local guildId = GetGuildId(i)
		local guildName = GetGuildName(guildId)
		if (guildName ~= "") then
			if guildsTable[guildName] == nil then
				KelaSetValueIfNil(guildsTable, guildName, {})
				guildsTable[guildName]["guildId"] = guildId
			end
		end
	end
end

function KelaUpdateGuildATTStat()
	local ArkadiusTradeToolsSales
	if ArkadiusTradeTools then
		ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
	else
		zo_callLater(KelaUpdateGuildATTStat, 1000)
		return	
	end
	KELA_ATT_GUILD_STAT = {}
	local salesTables = ArkadiusTradeToolsSales.SalesTables
	local serverName = GetWorldName()
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	for t = 1, #salesTables do
		for eventId, sale in pairs(salesTables[t][serverName].sales) do	
			local eventTimeStamp = sale["timeStamp"]
			-- собираем статистику гильдий при каждом запуске во временную таблицу
			local period = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) * ZO_ONE_DAY_IN_SECONDS
			if eventTimeStamp > GetTimeStamp() - period then
				local guildName =  sale["guildName"]
				local itemTradeCategory = KelaGetItemTradeCategory(sale["itemLink"])
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT, itemTradeCategory, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory], guildName, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "price", 0)
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "quantity", 0)
				KELA_ATT_GUILD_STAT[itemTradeCategory][guildName] = {
					["price"] = sale["price"] + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["price"], 
					["quantity"] = sale["quantity"] + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["quantity"],  					
				}
			end
		end
	end
end

function KelaSetupATTFunctions()
	local ArkadiusTradeToolsSales
	if ArkadiusTradeTools then
		ArkadiusTradeToolsSales = ArkadiusTradeTools.Modules.Sales
	else
		zo_callLater(KelaSetupATTFunctions, 1000)
		return	
	end
	local salesTables = ArkadiusTradeToolsSales.SalesTables
	local serverName = GetWorldName()
	local kelaPlayerAccountName = GetUnitDisplayName('player')
	for t = 1, #salesTables do
		for eventId, sale in pairs(salesTables[t][serverName].sales) do	
			local eventTimeStamp = sale["timeStamp"]
			-- проверяем на новые продажи нашего товара	
			if sale["sellerName"] == kelaPlayerAccountName then
				local secsSinceEvent = GetTimeStamp() - eventTimeStamp
				local olderThanTimeStamp = GetTimeStamp() - KELA_LISTING_DATA_RETENTION_PERIOD * ZO_ONE_DAY_IN_SECONDS
				if (eventTimeStamp > olderThanTimeStamp) then
					KelaRemoveFromListingTable(nil, sale["quantity"], sale["price"], nil, sale["itemLink"], sale["sellerName"], secsSinceEvent, sale["guildName"])
				end
			end
			-- собираем статистику гильдий при каждом запуске во временную таблицу
			local period = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) * ZO_ONE_DAY_IN_SECONDS
			if eventTimeStamp > GetTimeStamp() - period then
				local guildName =  sale["guildName"]
				local itemTradeCategory = KelaGetItemTradeCategory(sale["itemLink"])
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT, itemTradeCategory, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory], guildName, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "price", 0)
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "quantity", 0)
				KELA_ATT_GUILD_STAT[itemTradeCategory][guildName] = {
					["price"] = sale["price"] + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["price"], 
					["quantity"] = sale["quantity"] + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["quantity"],  					
				}
			end
		end
	end

	SecurePostHook(ArkadiusTradeToolsSales, "AddEvent", function(control, guildId, category, eventIndex, ...)
		local eventType, secsSinceEvent, seller, buyer, quantity, itemLink, price, tax = GetGuildEventInfo(guildId, category, eventIndex)
		local kelaPlayerAccountName = GetUnitDisplayName('player')
		local guildsTable = kpuiSVListingData["guildsTable"]
		local guildName = GetGuildName(guildId)
		if guildsTable[guildName] == nil then UpdateGuildList() end
		local guildRecord = guildsTable[guildName]
		if (eventType ~= GUILD_EVENT_ITEM_SOLD) then return false end
		local timeStamp = GetTimeStamp()
		local eventTimeStamp = timeStamp - secsSinceEvent - 1
		if guildRecord then
			local olderThanTimeStamp
			if seller == kelaPlayerAccountName then
				--за период хранения продаж
				olderThanTimeStamp = timeStamp - KELA_LISTING_DATA_RETENTION_PERIOD * ZO_ONE_DAY_IN_SECONDS
				if (eventTimeStamp < olderThanTimeStamp) then
					return false
				end
				KelaRemoveFromListingTable(nil, quantity, price, nil, itemLink, seller, secsSinceEvent, guildId)
			end
			-- добавляем в статистику гильдий во временную таблицу
			local period = KelaGetSetting_Number(SETTING_TYPE_KELA, KELA_SETTING_PANEL_TRADE_ATT_PERIOD) * ZO_ONE_DAY_IN_SECONDS
			if eventTimeStamp > GetTimeStamp() - period then
				local itemTradeCategory = KelaGetItemTradeCategory(itemLink)
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT, itemTradeCategory, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory], guildName, {})
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "price", 0)
				KelaSetValueIfNil(KELA_ATT_GUILD_STAT[itemTradeCategory][guildName], "quantity", 0)
				KELA_ATT_GUILD_STAT[itemTradeCategory][guildName] = {
					["price"] = price + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["price"], 
					["quantity"] = quantity + KELA_ATT_GUILD_STAT[itemTradeCategory][guildName]["quantity"],  					
				}
			end
		end
	end)
	-- CHAT_SYSTEM:AddMessage("DONE KelaSetupATTFunctions")
end


local function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= KelaPadUIListingData.name) then
        return
    end
	if TamrielTradeCentre ~= nil and ArkadiusTradeTools ~= nil then
		kpuiSVListingData = ZO_SavedVars:NewAccountWide('kpuiSavedVariablesListingData', 0.10, nil, {})
		-- kpuiSVListingData["listingTable"] = nil
		-- kpuiSVListingData["guildsTable"] = nil
		KelaSetValueIfNil(kpuiSVListingData, "listingTable", {})
		KelaSetValueIfNil(kpuiSVListingData, "guildsTable", {})
		CheckingForRetentionPeriod()
		UpdateGuildList()
		KelaSetupATTFunctions()
		KelaUpdateGuildATTStat()
	end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(KelaPadUIListingData.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
