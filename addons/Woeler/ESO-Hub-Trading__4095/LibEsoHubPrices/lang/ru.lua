-- Localization kindly provided by A5ha via ESOUI.com


local strings = {
	-- Localization Start

	-- Item Tooltip

	EHP_STRING_TOOLTIP_TITLE = "ESO-Hub.com - '<<C:1>>'",
	EHP_STRING_TOOLTIP_TITLE_DURATION = " (За последние 14 дней)",
	EHP_STRING_TOOLTIP_AVERAGE = "Средняя: <<1>>",
	EHP_STRING_TOOLTIP_LISTINGS = "<<1>> - <<2>> из <<3>> <<4>>",
	EHP_STRING_TOOLTIP_SUGGESTED_SINGLE = "Рекомендуемо: <<1>>",
	EHP_STRING_TOOLTIP_SUGGESTED_RANGE = "Рекомендуемо: <<1>> - <<2>>",
	EHP_STRING_TOOLTIP_TIMESTAMP = "Данные обновлены: <<1>>, <<2>>",

	-- Settings

	EHP_STRING_SETTING_ACCOUNTWIDE = "Настройки для всей учетной записи",
	EHP_STRING_SETTING_INVENTORY = "Инвентарь",
	EHP_STRING_SETTING_INVENTORY_TOOLTIP = "Отображение предлагаемых аукционных цен в инвентаре вместо их продажной стоимости NPC.",
	EHP_STRING_SETTING_INVENTORY_TOOLTIP_DISABLED = "Отображение предлагаемых аукционных цен в инвентаре вместо их продажной стоимости NPC.\nУстановка отключена из-за конфликтующего параметра в: <<1>>\nПосле отключения конфликтующих параметров требуется перезагрузка пользовательского интерфейса для включения этого параметра.",
	-- EHP_STRING_SETTING_USESALESDATA                   = "Use sales data",
	-- EHP_STRING_SETTING_USESALESDATA_TOOLTIP           = "Use data from item sales instead of data from item listings.",
	EHP_STRING_SETTING_LISTINGS_TOOLTIP = "Лоты в карточке предмета",
	EHP_STRING_SETTING_LISTINGS_TOOLTIP_TOOLTIP = "Показывать цены лотов в карточке предмета",
	EHP_STRING_SETTING_SALES_TOOLTIP = "Продажи в карточке предмета",
	EHP_STRING_SETTING_SALES_TOOLTIP_TOOLTIP = "Показывать цены продаж в карточке предмета",
	EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT = "Контекстное меню: Отправить в чат",
	EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT_TOOLTIP = "Добавить в контекстное меню предмета, возможность отправки цен в чат",
	EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE = "Контекстное меню: Просмотреть онлайн",
	EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE_TOOLTIP = "Добавить в контекстное меню предмета, возможность перейти на сайт ESO-Hub.com, на страницу предмета",

	-- Inventory Context Menu

	EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS = "Цена лотов в чат",
	EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES = "Цена продаж в чат",
	EHP_STRING_CONTEXTMENU_POSTTOCHAT_FORMAT = "ESO-Hub.com Цены для <<1>>: <<2>> (<<3>> <<4>>)", -- <<1>> itemLink, <<2>> suggested/average price, <<3>> number of listings <<4>> 'sales' or 'listings')
	EHP_STRING_SALES = "Продано",
	EHP_STRING_LISTINGS = "Лоты",
	EHP_STRING_CONTEXTMENU_VIEWONLINE = "Просмотреть на ESO-Hub.com",
	EHP_STRING_CONTEXTMENU_VIEWONLINE_URLFORMAT = "https://ESO-Hub.com/<<1>>/trading-addon-redirect/<<2>>", -- <<1>> language, <<2>> Reduced Itemlink

	-- Slash Commands

	EHP_STRING_SLASHCOMMAND_HELP1 = "[LibEsoHubPrices] Доступные слеш-команды:",
	EHP_STRING_SLASHCOMMAND_HELP2 = "/ehp accountwide (on/off): Настройки для всего аккаунта",
	-- EHP_STRING_SLASHCOMMAND_HELP3 = "/ehp usesales (on/off): Использовать цены продаж вместо лотов",
	EHP_STRING_SLASHCOMMAND_HELP4 = "/ehp inventory (none/listings/sales): Переключение режима для инвентаря (Не показывать/Лоты/Продажи)", -- do not translate (none/listings/sales)
	EHP_STRING_SLASHCOMMAND_HELP5 = "/ehp listingstooltip (on/off): Настройка отображения лотов для карточек предметов",
	EHP_STRING_SLASHCOMMAND_HELP6 = "/ehp salestooltip (on/off): Настройка отображения продаж для карточек предметов",
	EHP_STRING_SLASHCOMMAND_HELP7 = "/ehp contextmenu chat (on/off): Настройка возможности отправки цен в чат для контекстного меню предмета",
	EHP_STRING_SLASHCOMMAND_HELP8 = "/ehp contextmenu online (on/off): Настройка возможности просмотра предмета на ESO-Hub.com для контекстного меню предмета",
	EHP_STRING_SLASHCOMMAND_HELP9 = "/ehp: Показать эту помощь по командам",

	EHP_STRING_SETTING_MESSAGE_INVENTORY = "Переопределение значений у предметов в инвентаре",
	EHP_STRING_SETTING_MESSAGE_LISTING_TOOLTIP = "Показать цены лотов в карточке предмета",
	EHP_STRING_SETTING_MESSAGE_SALES_TOOLTIP = "Показать цены продаж в карточке предмета",
	EHP_STRING_SETTING_MESSAGE_ACCOUNTWIDE = "Настройки для всей учетной записи",
	-- EHP_STRING_SETTING_MESSAGE_SALES                  = "Использовать цены продаж вместо лотов",
	EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_POSTTOCHAT = "Добавить в контекстное меню предмета, возможность отправки цен в чат",
	EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_VIEWONLINE = "Добавить в контекстное меню предмета, возможность перейти на сайт ESO-Hub.com, на страницу предмета",

	EHP_STRING_ON = "Вкл",
	EHP_STRING_OFF = "Выкл",

	-- Localization End
}

for stringId, stringValue in pairs(strings) do
	if _G[stringId] then
		SafeAddString(_G[stringId], stringValue, 1)
	else
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end
end
