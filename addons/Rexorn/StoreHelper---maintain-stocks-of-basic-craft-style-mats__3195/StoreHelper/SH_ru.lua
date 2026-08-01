local SH_localization  = {
 SH_mod_name = "StoreHelper"
,SH_display_name = "Store Helper"

,SH_bought_mats_msg     = "SH: куплен %u %s"										-- ie purchased 5 Flint
,SH_buy_reduced_msg     = "SH: уменьшение покупки %s с %u до %u - проверьте золото"
,SH_PA_integration_msg  = "SH: PAJunk/Repair найденный. сделает паузу 0,2 секунды."

,SH_OptMenu_header_name = "Store Helper Параметры"
,SH_OptMenu_description = "Держите под рукой минимальное количество ковриков для рукоделия. Все типы покупают расовый коврик для мультяшек, чтобы гарантировать, что покупающий персонаж может использовать материалы, \N Считает только сумку для крафта, банк и текущий инвентарь мультяшек."
,SH_OptMenu_chk_UseToon_name	 = "использовать настройки персонажа"
,SH_OptMenu_chk_UseToon_tooltip  = "используйте настройки для этого персонажа вместо настроек по умолчанию"
,SH_OptMenu_chk_buy2chat_name    = "покупать сообщения в чат"
,SH_OptMenu_chk_buy2chat_tooltip = "покупать сообщения в чат"
,SH_OptMenu_AllTypes_name	 	 = "все типы материалов"
,SH_OptMenu_AllTypes_tooltip 	 = "если после покупки определенного материала, материалов будет меньше, чем это, купите больше: 0-250 \n Проигрывает никель, за исключением имперских мультфильмов с заменой никеля."
,SH_OptMenu_AllTypes_desc		 = "Этот персонаж купит% s, чтобы достичь всех типов."
,SH_OptMenu_ShowPA_AddFunc_name = "Показывать сообщения для других взаимодействий модератора"
,SH_OptMenu_ShowPA_AddFunc_tooltip = "Сообщение, если добавлена ​​задержка для PersonalAssistant или других дополнений, добавляющих функции магазина"

-- racial style mat names generated in main code using system calls -> no SH_OptMenu_*_name strings
,SH_OptMenu_box_genMat_tooltip	  = "минимум на складе: 0-250 (использовать коробку для >250)"

,SH_OptMenu_Nickel_note = "          Учитывается только для решения о всех типах материалов, если британские единицы измерения с переопределением на никель." 
,SH_OptMenu_Imp_override_name = "Имперская раса Все типы материалов Покупка отмены" 
,SH_OptMenu_Imp_override_tooltip = "Императорский мотив редкий / дорогой, немногие мультяшные люди знают этот стиль. \N Чтобы избежать покупки материалов ограниченного использования, все покупатели будут использовать его для имперцев, чтобы позволить выбрать коврик для покупки. \N НЕ влияет на цель покупки никеля."
,SH_OptMenu_Imp_override_desc = "          Действует только на имперских персонажей."

,SH_err_add_for_store_no_addon_name = "SH: другой аддон попросил SH обработать функцию магазина без указания имени аддона"
,SH_err_add_for_store_no_func_desc  = "SH: %s попросил SH обработать функцию сохранения без описания для уведомления о загрузке"
,SH_err_add_for_store_not_func      = "SH: %s попросил SH обработать функцию хранения, но не передал функцию (%s)"
,SH_err_add_for_store_already_added = "SH: %s попросил SH добавить (%s), который уже был включен"
,SH_accepted_func	                = "SH: принятая функция покупок %s(%s)"
		-- SH: accepted shopping function Bob(buy rune stones)

,SH_err_remove_func_no_addon_name	= "SH: другой аддон попросил удалить функцию без указания имени аддона"
,SH_err_remove_func_no_func_desc	= "SH: %s попросил SH удалить функцию магазина без ключа описания"
,SH_err_remove_func_not_func		= "SH: %s попросил SH удалить функцию сохранения, но не передал функцию"
,SH_err_remove_func_not_found		= "SH: %s попросил SH удалить (%s), но функция не была добавлена или уже удалена"
,SH_removed_func					= "SH: удалена функция покупок %s(%s)"
,SH_cannot_find_alltypes_matID		= "SH: фатальная ошибка не может найти alltypes_matID"

,SH_debug_msg_off = "SH: debug messages off"
,SH_debug_msg_on  = "SH: debug messages on"
,SH_debug_show_ap_entries        = "SH: магазин принимает записи очков альянса %u"
,SH_debug_show_gold_entries      = "SH: sмагазин принимает золотые записи %u"
,SH_debug_show_gold_only_entries = "SH: магазин принимает только золотые записи %u"
,SH_debug_show_telvar_entries    = "SH: хранить записи телваров %u"


-- if a new race is added define SH_style_*, SH_mat_* here
-- if you need a custom language not included by ZOS set SH_load_ZOS_names to false & fill in values
-- SH_style_* is just a display name
,SH_load_ZOS_names	= true
,SH_style_breton	= "custom style name"
,SH_style_redguard	= "custom style name"
,SH_style_orc		= "custom style name"
,SH_style_darkelf	= "custom style name"
,SH_style_nord		= "custom style name"
,SH_style_argonian	= "custom style name"
,SH_style_highelf	= "custom style name"
,SH_style_woodelf	= "custom style name"
,SH_style_khajiit	= "custom style name"
,SH_style_imperial	= "custom style name"

-- SH_mat_* is used for item matching in store entries.
-- custom mat name MUST match the name from GetStoreEntryInfo() not the formated name shown on the screen
,SH_mat_breton		= "custom mat name"
,SH_mat_redguard	= "custom mat name"
,SH_mat_orc			= "custom mat name"
,SH_mat_darkelf		= "custom mat name"
,SH_mat_nord		= "custom mat name"
,SH_mat_argonian	= "custom mat name"
,SH_mat_highelf		= "custom mat name"
,SH_mat_woodelf		= "custom mat name"
,SH_mat_khajiit		= "custom mat name"
,SH_mat_imperial	= "custom mat name"
-- MUST match the name from GetStoreEntryInfo() - REALLY
}

-- loaded SH main LUA first instead of second
-- quick store local into SH for use
ZO_ShallowTableCopy(SH_localization, StoreHelper.localization)


-- do NOT try to set pointer directly, for some reason it will clear addon
-- StoreHelper.localization = SH_localization

-- another way is copying the strings into the Global table with dup checking
-- probably more overhead than the shallow table copy
--[[ 
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(StringId, 1)
end

other files use this to find the key on the _G table
for key, value in pairs(strings) do
	SafeAddString(_G[key], value, 1)
end

in code use GetString(xx)
]]
