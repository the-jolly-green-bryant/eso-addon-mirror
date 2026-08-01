--[[
Author: Ayantir
Updated by Lykeion
Filename: ru.lua
Version: 6.0.0
Translate: Ankou_RMV
]]--

local strings = {

	SI_BINDING_NAME_SUPERSTAR_SHOW_PANEL			= "Открыть SuperStar",

	SUPERSTAR_RESPECFAV_SP								= "Применить навыки",
	SUPERSTAR_RESPECFAV_CP								= "Применить очки героя",
	SUPERSTAR_SAVEFAV										= "Сохранить в избранное",
	SUPERSTAR_VIEWFAV										= "Смотреть навыки",
	SUPERSTAR_VIEWHASH									= "Смотреть билд",
    SUPERSTAR_UPDATEHASH                                = "Обновить билд",
	SUPERSTAR_REMFAV										= "Удалить билд",
	SUPERSTAR_FAVNAME										= "Название билда",

	SUPERSTAR_CSA_RESPECDONE_TITLE					= "Изменение билда завершено",
	SUPERSTAR_CSA_RESPECDONE_POINTS					= "<<1>> навыков назначено",
	SUPERSTAR_CSA_RESPEC_INPROGRESS					= "Изменение билда в процессе",
	SUPERSTAR_CSA_RESPEC_TIME							= "Эта операция займет примерно <<1>> <<1[minutes/minute/minutes/минут]>>",

	SUPERSTAR_RESPEC_SPTITLE							= "Вы хотите применить |cFF0000навыки|r из билда :\n\n <<1>>",
	SUPERSTAR_RESPEC_CPTITLE							= "Вы хотите применить |cFF0000очки героя|r из билда :\n\n <<1>>",

	SUPERSTAR_RESPEC_ERROR1								= "Невозможно изменить навыки, у вас другой класс",
	SUPERSTAR_RESPEC_ERROR2								= "Внимание: Текущее количество очков навыков меньше, чем требуется для шаблона. Перевооружение может быть неполным",
	SUPERSTAR_RESPEC_ERROR3								= "Внимание: Заданная раса в этом билде отличается от вашей, расовые навыки не будут применены",
	SUPERSTAR_RESPEC_ERROR5								= "Невозможно изменить очки героя, вы еще не являетесь героем",
	SUPERSTAR_RESPEC_ERROR6								= "Невозможно изменить очки героя, не хватает очков",

	SUPERSTAR_RESPEC_SKILLLINES_MISSING				= "Внимание: Выбранное древо навыков не разблокировано, и не может быть применено",
	SUPERSTAR_RESPEC_CPREQUIRED						= "Этот билд применит <<1>> очков героя",

	SUPERSTAR_RESPEC_INPROGRESS1						= "Классовые навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS2						= "Оружейные навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS3						= "Доспешные навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS4						= "Общие навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS5						= "Гильдейские навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS6						= "Военные навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS7						= "Расовые навыки применены",
	SUPERSTAR_RESPEC_INPROGRESS8						= "Ремесленые навыки применены",

	SUPERSTAR_IMPORT_MENU_TITLE						= "Импорт",
	SUPERSTAR_FAVORITES_MENU_TITLE					= "Избранное",
	SUPERSTAR_RESPEC_MENU_TITLE						= "Изменения",
	SUPERSTAR_SCRIBING_MENU_TITLE				= "Чаропись Симулятор",

	SUPERSTAR_XML_BUTTON_SHARE				= "Поделиться SuperStar (/sss)",
	SUPERSTAR_XML_BUTTON_SHARE_LINK				= "Поделиться ссылкой на игру (/ssl)",

	SUPERSTAR_DIALOG_SPRESPEC_TITLE					= "Применить очки навыков",
	SUPERSTAR_DIALOG_SPRESPEC_TEXT					= "Применить очки навыков из выбранного билда ?",

	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE		= "Сбросить Билдер Навыков",
	SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT		= "Вы хотите Сбросить Билдер Навыков в котором содержатся характеристики и/или Очки Героя.\n\nЭто сбросит их значения.\n\nЕсли вы хотите изменить навык, нажмите правой кнопкой мыши на его иконке.",

	SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT			= "Вы хотите изменить Очки Героя.\n\nЭто изменение будет бесплатным.",


	SUPERSTAR_QUEUE_SCRIBING						= "Очередь на Чаропись",
	SUPERSTAR_CLEAR_QUEUE							= "Очистить очередь",

	SUPERSTAR_DIALOG_QUEUE_REJECTED_TITLE			= "Очередь Отклонено",
	SUPERSTAR_DIALOG_QUEUE_REJECTED_TEXT			= "Поставленное в очередь умение будет автоматически создано при следующем использовании Алтарь чарописи\nСтарые навыки, поставленные в очередь, будут заменены новыми навыками, использующими тот же Гримуар\n\nНекоторые из текущих выбранных навыков еще не разблокированы, и вы не можете добавить их в очередь Чарописи",
	SUPERSTAR_DIALOG_QUEUE_FOR_SCRIBING_TEXT		= "Поставленное в очередь умение будет автоматически создано при следующем использовании Алтарь чарописи\nСтарые навыки, поставленные в очередь, будут заменены новыми навыками, использующими тот же Гримуар\n\nВы собираетесь поставить в очередь свои текущие выбранные навыки для создания",
	SUPERSTAR_DIALOG_CLEAR_QUEUE_TEXT		        = "Сейчас вы очистите навыки, которые были добавлены в очередь Чарописи\n\nПри следующем использовании Алтарь чарописи ни одно умение не будет автоматически создано.",
	SUPERSTAR_DIALOG_MAJOR_UPDATE_TEXT              = "SuperStar обновлён для версии 50!\n\nАддон теперь поддерживает отображение <<1>>.\nФункция обмена ссылками SuperStar также была переработана. Она стала более стабильной и готовой к предстоящим переработкам классов.",

-- Chatbox Info:
	SUPERSTAR_CHATBOX_PRINT			        		= "Нажмите, чтобы посмотреть",
	SUPERSTAR_CHATBOX_QUEUE_INFO			        = "|c215895[Super|cCC922FStar]|r <<1>> навыки в очереди, <<2>> чернила, ожидаемые к употреблению, Собственный <<3>>",
	SUPERSTAR_CHATBOX_QUEUE_WARN			        = "|c215895[Super|cCC922FStar]|r <<1>> навыки в очереди, <<2>> чернила, ожидаемые к употреблению, Собственный <<3>>",
	SUPERSTAR_CHATBOX_QUEUE_ABORTED		            = "|c215895[Super|cCC922FStar]|r Авто чаропись была прервана из-за прерывания. Очередь была опустошена|r",
	SUPERSTAR_CHATBOX_QUEUE_CANCELED		        = "|c215895[Super|cCC922FStar]|r Авто Чаропись была отменена из-за отсутствия чернил. Нужны <<1>>, есть <<2>>",
	SUPERSTAR_CHATBOX_TEMPLATE_OUTDATED		        = "|c215895[Super|cCC922FStar]|r Шаблон устарел, пожалуйста, создайте его заново",
	SUPERSTAR_CHATBOX_SUPERSTAR_OUTDATED		    = "|c215895[Super|cCC922FStar]|r Неразрешимые ссылки SuperStar. Возможно, вы или другая сторона используете не последнюю версию SuperStar, или некоторые символы в ссылке были заблокированы системой цензуры чата",

	SUPERSTAR_XML_SKILL_BUILD				= 		"создатель навыков",
	SUPERSTAR_XML_SKILL_BUILD_EXPLAIN				= "Выберите расу здесь, чтобы начать создание сборки навыков. Вы можете сохранить сборку как шаблон для последующих сбросов.\n\nПолная поддержка системы подклассов! Свободно добавляйте любые ветки навыков класса в вашу сборку. SuperStar автоматически определит и применит все доступные навыки класса при сбросе.",
	SUPERSTAR_SCENE_SKILL_RACE_LABEL					= "Раса",

	SUPERSTAR_XML_CUSTOMIZABLE							= "Изменяемый",
	SUPERSTAR_XML_GRANTED								= "Получено",
	SUPERSTAR_XML_TOTAL									= "Всего",
	SUPERSTAR_XML_BUTTON_FAV							= "В избранное",
	SUPERSTAR_XML_BUTTON_FAV_WITH_CP				= "сохранить с помощью CP",
	SUPERSTAR_XML_BUTTON_REINIT						= "Сбросить",
	SUPERSTAR_XML_BUTTON_EXPORT						= "Экспорт",
	SUPERSTAR_XML_NEWBUILD								= "Новый билд :",
	SUPERSTAR_XML_BUTTON_RESPEC						= "Применить",
	SUPERSTAR_XML_BUTTON_START						= "Начать",
	SUPERSTAR_XML_IMPORT_EXPLAIN						= "Импортируйте билды в этом меню\n\nБилды могут содержать очки героя, навыков и характеристик.",
	SUPERSTAR_XML_FAVORITES_EXPLAIN					= "Вы можете использовать сохраненные шаблоны для автоматической перестройки. Рекомендуется заранее сохранить базовую сборку в арсенале, чтобы каждый раз можно было применять другой шаблон. \n\nОбратите внимание, что если перестройка включает в себя очки чемпиона, она будет стоить золота",

	SUPERSTAR_XML_SKILLPOINTS							= "Очки Навыков",
	SUPERSTAR_XML_CHAMPIONPOINTS						= "Очки Героя",

	SUPERSTAR_XML_DMG										= "Урон",
	SUPERSTAR_XML_CRIT									= "Крит / %",
	SUPERSTAR_XML_PENE									= "Пробивание",
	SUPERSTAR_XML_RESIST									= "Сопр / %",

	--SUPERSTAR_MAELSTROM_WEAPON							= "Вихрь",
	SUPERSTAR_DESC_ENCHANT_MAX							= " Максимум",

	SUPERSTAR_DESC_ENCHANT_SEC							= " секунд",
	SUPERSTAR_DESC_ENCHANT_SEC_SHORT					= " сек",

	SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG				= "Магический урон",
	SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT		= "Маг ур.",

	SUPERSTAR_DESC_ENCHANT_BASH						= "удар",
	SUPERSTAR_DESC_ENCHANT_BASH_SHORT				= "удар",

	SUPERSTAR_DESC_ENCHANT_REDUCE						= " и снижает",
	SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT				= " и",

	SUPERSTAR_IMPORT_ATTR_DISABLED					= "Вкл. характеристики",
	SUPERSTAR_IMPORT_ATTR_ENABLED						= "Искл. характеристики",
	SUPERSTAR_IMPORT_SP_DISABLED						= "Вкл. Очки навыков",
	SUPERSTAR_IMPORT_SP_ENABLED						= "Искл. Очки навыков",
	SUPERSTAR_IMPORT_CP_DISABLED						= "Вкл. Очки героя",
	SUPERSTAR_IMPORT_CP_ENABLED						= "Искл. Очки героя",
	SUPERSTAR_IMPORT_BUILD_OK							= "Смотреть навыки этого билда",
	SUPERSTAR_IMPORT_BUILD_NO_SKILLS					= "Этот билд не имеет навыков",
	SUPERSTAR_IMPORT_BUILD_NOK							= "Билд некорректный, проверьте хеш-данные",
	SUPERSTAR_IMPORT_BUILD_LABEL						= "Импорт билда: вставьте хеш-данные ниже",
	SUPERSTAR_IMPORT_MYBUILD							= "Мой билд",

	--SUPERSTAR_XML_SWITCH_PLACEHOLDER					= "Смените оружие для отображения",

	SUPERSTAR_XML_FAVORITES_HEADER_NAME		= "Название",
	SUPERSTAR_XML_FAVORITES_HEADER_CP		= "ОГ",
	SUPERSTAR_XML_FAVORITES_HEADER_SP		= "ОН",
	SUPERSTAR_XML_FAVORITES_HEADER_ATTR		= "Хар",

	SUPERSTAR_EQUIP_SET_BONUS			= "Набор",

}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
