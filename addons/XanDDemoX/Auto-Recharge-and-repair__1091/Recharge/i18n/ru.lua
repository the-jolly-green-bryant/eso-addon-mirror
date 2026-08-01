local strings = {
--Addon LAM menu
	ARC_LAM_ADDON_DESC								= "Перезаряжает и ремонтирует ваше экипированое оружие и броню автоматически до входа и после выхода из боя.",
	ARC_LAM_OPTION_ACCOUNTWIDE						= "Использовать настройки на всю учётную запись",
	ARC_LAM_OPTION_ACCOUNTWIDE_TT					= "Сохранить настройки аддона для всех ваших персонажей на вашей учетной записи или для каждого персонажа.",
	ARC_LAM_HEADER_AUTO_CHARGE						= GetString(SI_CHARGE_WEAPON_TITLE),
	ARC_LAM_OPTION_AUTO_RECHARGE						= GetString(SI_CHARGE_WEAPON_TITLE) .. " автоматически",
	ARC_LAM_OPTION_AUTO_RECHARGE_TT					= "Автоматически перезаряжает ваше оружие до входа и после выхода из боя. " .. GetString(SI_CHARGE_WEAPON_CONSUME),
	ARC_LAM_OPTION_AUTO_RECHARGE_MIN_TH	 			= "Минимальный процент заряда",
	ARC_LAM_OPTION_AUTO_RECHARGE_MIN_TH_TT			= "Установите значение от 0% до 99%. Оружие будет перезаряжаться, когда текущий процент заряда будет равен или ниже этого значения.",
	ARC_LAM_HEADER_AUTO_REPAIR						= GetString(SI_ITEM_ACTION_REPAIR) .. " " .. GetString(SI_ITEM_FORMAT_STR_ARMOR),
	ARC_LAM_OPTION_AUTO_REPAIR						= "Автоматически чинить броню",
	ARC_LAM_OPTION_AUTO_REPAIR_TT		   			= "Автоматически чинить броню до входа и после выхода из боя. " .. GetString(SI_REPAIR_KIT_CONSUME),
	ARC_LAM_OPTION_AUTO_REPAIR_MIN_TH   				= "Минимальный процент починки",
	ARC_LAM_OPTION_AUTO_REPAIR_MIN_TH_TT				= "Установите значение от 0% до 99%. Броня будет отремонтирована, когда текущий процент будет равен или ниже этого значения.",
	ARC_LAM_HEADER_CHATOUTPUT						= GetString(SI_CHAT_TAB_GENERAL) .. " " .. GetString(SI_AUDIO_OPTIONS_OUTPUT),
    ARC_LAM_OPTION_SHOW_CHAT_MSG						= "Показывать сообщения в чат",
	ARC_LAM_OPTION_SHOW_CHAT_MSG_TT					= "Показывать сообщение в чат если починка/перезарядка оружия не выполнено, и т.д.",
	ARC_LAM_OPTION_SUPPRESS_CHAT_MSG_NOTHING			= "Подавлять сообщ. типа \'Нечего\'",
	ARC_LAM_OPTION_SUPPRESS_CHAT_MSG_NOTHING_TT		= "Не показывать сообщения \'Нечего перезарядить\' или \'Нечего починить\'",
	ARC_LAM_HEADER_ALERT 							= "Экранные сообщения",
	
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT				= "Показывать \'Отсутствуют ремонтные наборы\'",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TT			= "Показывает на экране предупреждение, если у вас нет ремонтных наборов",
	ARC_LAM_OPTION_ALERT_SOON_EMPTY_REPAIRKIT		= "Показывать \'Мало Рем. наборов\'",
	ARC_LAM_OPTION_ALERT_SOON_EMPTY_REPAIRKIT_TT		= "Показывает на экране предупреждение если количество ваших ремонтных наборов падает ниже порогового значения.\n\nУстановите ваш порог на ползунке справа!",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TH			= "Порог ремонтных наборов",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TH_TT		= "Установите значение от 1 до 100 ремонтных наборов. Если вы выйдете из боя и ваших ремонтных наборов окажется меньше этого значения вы получите на экране предупреждение.",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_LOGIN		= "Сообщать о \'Рем. наборах\' при входе/reloadui",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_LOGIN_TT	= "Если вы входите или используете /reloadui:\nПоказывает на экране предупреждение, если количество ваших ремонтных наборов упадет ниже выбранного порога или уже 0.",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_VENDOR		= "Сообщать о \'Рем. наборах\' у продавца",
	ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_VENDOR_TT	= "Когда вы взаимодействуете с продавцом:\nПоказывает на экране предупреждение, если количество ваших ремонтных наборов упадет ниже выбранного порога или уже 0.",

	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM				= "Показывать предупр. \'" .. GetString(SI_ITEMTYPE19) .. " закончились\'",
	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TT			= "Показывать на экране предупреждение если у вас нет камней душ",
	ARC_LAM_OPTION_ALERT_SOON_EMPTY_SOULGEM			= "Сообщать если \'" .. GetString(SI_ITEMTYPE19) .. " мало\'",
	ARC_LAM_OPTION_ALERT_SOON_EMPTY_SOULGEM_TT		= "Показывает на экране предупреждение, если количество ваших камней душ падает ниже порога.\n\nУстановите свой порог на ползунке справа!",
	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TH			= "Порог камней душ",
	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_TH_TT			= GetString(ARC_LAM_OPTION_ALERT_EMPTY_REPAIRKIT_TH_TT),
	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_LOGIN	  		= "Сообщать о '" .. GetString(SI_ITEMTYPE19) .. "' при входе/reloadui",
	ARC_LAM_OPTION_ALERT_EMPTY_SOULGEM_LOGIN_TT		= "Если включено, показывает предупреждение после входа/reloadui, если упадет ниже выбранного порога или уже 0.",

	ARC_LAM_OPTION_SHOW_REPAIR_KITS_LEFT_AT_VENDOR	= "Показать оставшиеся наборы",
	ARC_LAM_OPTION_SHOW_REPAIR_KITS_LEFT_AT_VENDOR_TT= "Показывает оставшиеся ремонтные наборы, если вы разговариваете с торговцем, в виде небольшого значка рядом с ним, с количеством оставшихся ремонтных набор.",
	ARC_LAM_OPTION_USE_REPAIR_KITS_FOR_ITEM_LEVEL	= "Исп. эффективные наборы",
	ARC_LAM_OPTION_USE_REPAIR_KITS_FOR_ITEM_LEVEL_TT = "Если у вас есть несколько ремонтных наборов, то соответствующий будет использоваться для уровня предмета (например, 'большой набор' для предметов с ОГ 160)",
	ARC_LAM_OPTION_DO_NOT_USE_CROWN_STORE_REPAIR_KITS = "Не использовать кронные ремонтные наборы",
	ARC_LAM_OPTION_DO_NOT_USE_CROWN_STORE_REPAIR_KITS_TT = "При включении этот настройки кронные ремонтные наборы не будут использоваться.",


	--Chat output messages
	ARC_CHATOUTPUT_CHARGED							= GetString(SI_ITEMTRAITTYPE2) .. ": ",
	ARC_CHATOUTPUT_CHARGED_NOTHING	   				= zo_strformat("Нечего <<c:1>>:", GetString(SI_ITEMTRAITTYPE2)),
	ARC_CHATOUPUT_NO_CHARGEABLE_WEAPONS				= GetString(SI_SOULGEMITEMCHARGINGREASON1),
	ARC_CHATOUTPUT_REPAIRED							= "Отремонтировано: ",
	ARC_CHATOUTPUT_REPAIRED_NOTHING					= "Не отремонтировано: ",
	ARC_CHATOUPUT_NO_REPAIRABLE_ARMOR				= GetString(SI_NO_REPAIRS_TO_MAKE),

	ARC_CHATOUPUT_MIN_CHARGE 						= GetString(SI_GRAPHICSPRESETS0) .. " " .. GetString(SI_CHARGE_WEAPON_CONFIRM) .. ": ",
	ARC_CHATOUPUT_MIN_CONDITION 						= GetString(SI_GRAPHICSPRESETS0) .. " " .. GetString(SI_REPAIR_SORT_TYPE_CONDITION) .. ": ",
	ARC_CHATOUPUT_INVALID_PERCENTAGE					= "Недопустимое значение: <<C:1>>, Значение: 0-99.",
	ARC_CHATOUPUT_CHARGE								= GetString(SI_CHARGE_WEAPON_CONFIRM) .. " ",
	ARC_CHATOUPUT_REPAIR								= GetString(SI_REPAIR_KIT_TITLE) .. " ",
    ARC_CHATOUPUT_SETTINGS_ENABLED					= GetString(SI_ADDON_MANAGER_ENABLED),
    ARC_CHATOUPUT_SETTINGS_DISABLED					= GetString(SI_CHECK_BUTTON_DISABLED),

	ARC_CHATOUPUT_REPAIRKITS_EMPTY_THRESHOLD			= "Порог " .. GetString(SI_HOOK_POINT_STORE_REPAIR_KIT_HEADER) .. " ",
    ARC_CHATOUPUT_SOULGEMS_EMPTY_THRESHOLD			= "Порог " .. GetString(SI_ITEMTYPE19) .. ": ",

	ARC_LAM_OPTION_AUTO_RECHARGE_IN_COMBAT			= GetString(SI_CHARGE_WEAPON_TITLE) .. " в бою",
	ARC_LAM_OPTION_AUTO_RECHARGE_IN_COMBAT_TT		= "Автоматически заряжать оружие даже в бою",
	ARC_LAM_OPTION_AUTO_REPAIR_IN_COMBAT				= "Ремонт в бою",
	ARC_LAM_OPTION_AUTO_REPAIR_IN_COMBAT_TT		   	= "Автоматически ремонтировать броню даже в бою",

--Alert messages
	ARC_ALERT_REPAIRKITS_EMPTY						= "Ремонтные наборы закончились!",
	ARC_ALERT_REPAIRKITS_SOON_EMPTY					= "Ремонтные наборы скоро закончатся! Только <<C:1>> осталось!",
	ARC_ALERT_SOULGEMS_EMPTY							= GetString(SI_ITEMTYPE19) .. " закончились!",
	ARC_ALERT_SOULGEMS_SOON_EMPTY					= GetString(SI_ITEMTYPE19) .. " почти закончились! Осталось <<C:1>>!",

	ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE		= "Перезаряжать при смене оружия",
	ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_TT	= "Проверяет и перезаряжает оружие после смены оружия.",
	ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_ONLY_IN_COMBAT = "Проверка смены оружия: в бою",
	ARC_LAM_OPTION_AUTO_RECHARGE_ON_WEAPON_PAIR_CHANGE_ONLY_IN_COMBAT_TT = "Проверяет перезаряженно ли оружие, при смене, только в том случае, если вы находитесь в бою",

    --Keybindings
    SI_KEYBINDINGS_CATEGORY_RECHARGE                    = "Auto Recharge",
    SI_BINDING_NAME_RUN_RECHARGE                        = "Использовать AutoRecharge/AutoRepair",
	SI_BINDING_NAME_RUN_REPAIR_SINGLE					= "Использовать AutoRepair",
	SI_BINDING_NAME_RUN_RECHARGE_SINGLE					= "Использовать AutoRecharge",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
