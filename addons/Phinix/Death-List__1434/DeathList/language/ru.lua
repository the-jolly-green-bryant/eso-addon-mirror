local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.DLAddon_UnitAdded			= "добавлен в список смерти."
L.DLAddon_ToAddPlayers		= "Необходимо включить опцию, чтобы добавить игроков в список смерти."
L.DLAddon_NotAttackable		= "Цель не подвергается атаке."
L.DLAddon_NoGuards			= "Невозможно добавить неуязвимых охранников в список смерти."
L.DLAddon_ListCleared		= "Все цели списка смерти очищены."
L.DLAddon_ListEmpty			= "В вашем списке смерти нет имен."
L.DLAddon_Removed			= "был удален из вашего списка смерти."
L.DLAddon_NoExist			= "Цель не существует в вашем списке смерти."

-- Settings panel
L.DLAddon_ShowMarker		= "Показать маркировку персонажа"
L.DLAddon_ShowMarkerTip		= "Показать имя персонажа, который добавил цель в список смерти."
L.DLAddon_MarkPlayers		= "Разрешить маркировку игроков"
L.DLAddon_MarkPlayersTip	= "Позволяет добавлять других игроков в список смерти."
L.DLAddon_ShowDebug			= "Показать отладку"
L.DLAddon_ShowDebugTip		= "Показывает уведомления в чате при выполнении функций списка смерти."
L.DLAddon_MarkColor			= "Выберите цвет значка"
L.DLAddon_MarkColorTip		= "Установите цвет для списка смерти, отмеченного значком цели."
L.DLAddon_TextColor			= "Выберите цвет текста"
L.DLAddon_TextColorTip		= "Установите цвет для имени персонажа, который добавил цель в список смерти."
L.DLAddon_MarkSize			= "Выберите размер значка"
L.DLAddon_MarkSizeTip		= "Установите размер списка целей, отмеченного значком смерти."
L.DLAddon_ChatCommants		= "Команды чата"
L.DLAddon_PrintList			= "Печатает содержимое вашего списка смерти."
L.DLAddon_RemoveName		= "Удалить указанное имя из списка смерти (без кавычек)."
L.DLAddon_ClearList			= "Очистите все цели из вашего списка смерти."
L.DLAddon_Name				= "название"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
