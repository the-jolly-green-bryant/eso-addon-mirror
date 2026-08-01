--base language is english, so the file en.lua shuld be kept empty!
WMGH_localization_strings = WMGH_localization_strings  or {}

WMGH_localization_strings["ru"] = {
    -- General
    WMGH_NAME = "Where's My Guild Hall",
    WMGH_INITIALIZE = "Инициализация Where's My Guild Hall...",
    
    -- Settings Panel
    WMGH_ASSUME_GM = "Полагать, что гильдмастер владеет гильд-холлом",
    WMGH_GHL_COMPATIBLE =  "Искать строку '<GH' в заметках списка игроков гильдии",
    WMGH_GHL_COMPATIBLE_TT =  "Совместимо с аддоном Guild Hall List\n(Использовать строку-маркер '<GH', обозначающую, что игрок владеет гильд-холлом.)",
	WMGH_SCAN_GUILDHALL = "Искать строку 'Guild Hall' в заметках списка игроков гильдии",
    WMGH_SCAN_GUILDHALL_TT =  "Использовать строку-маркер 'Guild Hall', обозначающую, что игрок владеет гильд-холлом.",
    
    -- Submenu - Status Bar Display
    WMGH_GUILDS_SECTION_NM = "Индивидуальные настройки для гильдий",

	    -- UI
    WMGH_GUILDHALL = "Гильд-холл",
    WMGH_NONE = "нет",
}
