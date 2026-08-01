local HPAStrings = {
	HPA_LOW_ATTR_SLOT_LABEL = "Слот заканчивается %s",
	HPA_LOW_ATTR_THRESHOLD_LABEL = "Граница заканчивается %s",
	HPA_POPUP_SCALE_LABEL = "Масштаб всплывающего окна",
	HPA_COOLDOWN_ALERT_NAME = "Предупреждение об откате",
	HPA_COOLDOWN_ALERT_ENABLED_LABEL = "Включить уведомление",
	HPA_COOLDOWN_ALERT_ENABLED_TOOLTIP = "Если включено, то после окончания периода ожидания готовности текущего быстрого слота, будет показано уведомление о его готовности",
	HPA_COOLDOWN_ALERT_FONT_LABEL = "Шрифт уведомления",
	HPA_COOLDOWN_ALERT_ICON_SIZE_LABEL = "Размер иконки уведомления",
	HPA_COOLDOWN_ALERT_READY_TEXT = "|c00ff00Готово|r!",
	HPA_COOLDOWN_ALERT_XML_READY_TEXT = "|t48:48:EsoUI/Art/Icons/icon_missing.dds|t |c00ff00Готово|r!",
	HPA_COOLDOWN_ALERT_XML_LOW_TEXT = "Атрибут",
	HPA_COOLDOWN_ALERT_XML_PRESS_TEXT = "Нажмите",
	HPA_LOW_ATTR_TEXT = "%s",
	HPA_SET_ALERT_POSITION_NAME = "Положение сообщений",
}

for stringId, stringValue in pairs(HPAStrings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
