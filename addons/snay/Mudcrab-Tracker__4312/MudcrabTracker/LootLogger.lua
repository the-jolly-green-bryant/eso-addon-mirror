local MT = MudcrabTracker
local clientLang = GetCVar("language.2")
local localizedStrings = {
	["en"] = {
		LOOTED_ITEMS_SUMMARY = "Looted Items Summary:",
		TOTAL_ESTIMATED_VALUE = "Total Estimated Value: %d gold",
		LOOTED_ITEM_ENTRY = "- %d x %s (%d gold)",
		NO_LOOT_DATA = "No loot data available.",
		LOOT_LOGGING_DISABLED = "Loot logging is currently disabled. Start logging with /crabslootstart",
		NO_ITEMS_LOOTED = "No items have been looted yet.",
		LOOT_LOGGING_STARTED = "Mudcrab Loot Logging Started. Happy hunting!",
		LOOT_LOGGING_STOPPED = "Mudcrab Loot Logging Stopped.",
		LOOT_LOGGING_PAUSED = "Mudcrab Loot Logging Paused.",
		LOOTED_ITEM = "Looted %d x %s (Total: %d)",
	},
	["de"] = {
		LOOTED_ITEMS_SUMMARY = "Zusammenfassung der geraubten Gegenstände:",
		TOTAL_ESTIMATED_VALUE = "Geschätzter Gesamtwert: %d Gold",
		LOOTED_ITEM_ENTRY = "- %d x %s (%d Gold)",
		NO_LOOT_DATA = "Keine Beutedaten verfügbar.",
		LOOT_LOGGING_DISABLED = "Die Beuteprotokollierung ist derzeit deaktiviert. Starten Sie die Protokollierung mit /crabslootstart",
		NO_ITEMS_LOOTED = "Es wurden noch keine Gegenstände geraubt.",
		LOOT_LOGGING_STARTED = "Mudcrab Beuteprotokollierung gestartet. Viel Erfolg bei der Jagd!",
		LOOT_LOGGING_STOPPED = "Mudcrab Beuteprotokollierung gestoppt.",
		LOOT_LOGGING_PAUSED = "Mudcrab Beuteprotokollierung pausiert.",
		LOOTED_ITEM = "Geraubt %d x %s (Insgesamt: %d)",
	},
	["ru"] = {
		LOOTED_ITEMS_SUMMARY = "Сводка по добытым предметам:",
		TOTAL_ESTIMATED_VALUE = "Общая оценочная стоимость: %d золота",
		LOOTED_ITEM_ENTRY = "- %d x %s (%d золота)",
		NO_LOOT_DATA = "Нет данных о добыче.",
		LOOT_LOGGING_DISABLED = "Журнал добычи в настоящее время отключен. Начните запись с помощью /crabslootstart",
		NO_ITEMS_LOOTED = "Пока ничего не добыто.",
		LOOT_LOGGING_STARTED = "Журнал добычи грязекрабов запущен. Удачной охоты!",
		LOOT_LOGGING_STOPPED = "Журнал добычи грязекрабов остановлен.",
		LOOT_LOGGING_PAUSED = "Журнал добычи грязекрабов приостановлен.",
		LOOTED_ITEM = "Добыто %d x %s (Всего: %d)",
	},
}
local L = localizedStrings[clientLang] or localizedStrings["en"]

local function GetItemLink(itemId, linkStyle)
	return string.format(
		"|H%d:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		linkStyle or LINK_STYLE_DEFAULT,
		itemId
	)
end

MT.LootLogger = {
	trackedItemIds = {
		71239, -- Rubedo Hide Scraps
		77591, -- Mudcrab Chitin
		114894, -- Decorative Wax
	},

	onLootReceived = function(
		_, --eventId,
		_, --receivedBy,
		itemName,
		quantity,
		_, --soundCategory,
		_, --lootType,
		lootedBySelf,
		_, --isPickpocketLoot,
		_, --questItemIcon,
		itemId,
		_ --isStolen
	)
		local isTracked = false
		for _, trackedId in ipairs(MT.LootLogger.trackedItemIds) do
			if trackedId == itemId then
				isTracked = true
				break
			end
		end

		if lootedBySelf == false or itemId == nil or not isTracked then
			return
		end

		if MT.db == nil then
			return
		end

		if MT.db.lootedItems == nil then
			MT.db.lootedItems = {}
		end
		if MT.db.lootedItems[itemId] == nil then
			MT.db.lootedItems[itemId] = 0
		end
		MT.db.lootedItems[itemId] = MT.db.lootedItems[itemId] + quantity
		MT.print(string.format(L.LOOTED_ITEM, quantity, itemName, MT.db.lootedItems[itemId]))
	end,

	startLogging = function()
		EVENT_MANAGER:RegisterForEvent("MudcrabTracker_LootLogger", EVENT_LOOT_RECEIVED, MT.LootLogger.onLootReceived)
		MT.db.lootLoggerEnabled = true
	end,

	stopLogging = function()
		EVENT_MANAGER:UnregisterForEvent("MudcrabTracker_LootLogger", EVENT_LOOT_RECEIVED)
		MT.LootLogger.reportLoot()
		MT.db.lootedItems = {}
		MT.db.lootLoggerEnabled = false
	end,

	pauseLogging = function()
		EVENT_MANAGER:UnregisterForEvent("MudcrabTracker_LootLogger", EVENT_LOOT_RECEIVED)
		MT.db.lootLoggerEnabled = false
	end,

	reportLoot = function()
		if MT.db == nil or MT.db.lootedItems == nil then
			MT.print(L.NO_LOOT_DATA)
			return
		end
		if MT.db.lootLoggerEnabled == false then
			MT.print(L.LOOT_LOGGING_DISABLED)
			return
		end
		if next(MT.db.lootedItems) == nil then
			MT.print(L.NO_ITEMS_LOOTED)
			return
		end
		local isLibPriceAvailable = LibPrice ~= nil
		MT.print(L.LOOTED_ITEMS_SUMMARY)
		local totalValue = 0
		for itemId, quantity in pairs(MT.db.lootedItems) do
			local itemLink = GetItemLink(itemId)
			if isLibPriceAvailable then
				local itemPrice = LibPrice.ItemLinkToPriceGold(itemLink) or 0
				local itemValue = itemPrice * quantity
				totalValue = totalValue + itemValue
				MT.print(string.format(L.LOOTED_ITEM_ENTRY, quantity, itemLink, itemValue))
			else
				MT.print("- " .. quantity .. " x " .. itemLink)
			end
		end
		if isLibPriceAvailable then
			MT.print(string.format(L.TOTAL_ESTIMATED_VALUE, totalValue))
		end
	end,

	init = function()
		if MT.db == nil then
			return
		end
		if MT.db.lootLoggerEnabled then
			MT.LootLogger.startLogging()
		end
		SLASH_COMMANDS["/crabslootstart"] = function()
			MT.LootLogger.startLogging()
			MT.print(L.LOOT_LOGGING_STARTED)
		end
		SLASH_COMMANDS["/crabslootstop"] = function()
			MT.LootLogger.stopLogging()
			MT.print(L.LOOT_LOGGING_STOPPED)
		end
		SLASH_COMMANDS["/crabslootpause"] = function()
			MT.LootLogger.pauseLogging()
			MT.print(L.LOOT_LOGGING_PAUSED)
		end
		SLASH_COMMANDS["/crabslootreport"] = function()
			MT.LootLogger.reportLoot()
		end
	end,
}
