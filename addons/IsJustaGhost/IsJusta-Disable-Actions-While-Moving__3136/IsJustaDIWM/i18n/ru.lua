------------------------------------------------
-- Russian localization
------------------------------------------------

local strings = {
	-- need translations
	SI_IJA_DIWM_Title				= "|cFF00FFIsJusta|r |cffffffDisable actions while moving|r",

	SI_IJA_DIWM_DISABLEINTERACT		= "Взаимодействие с компаньонами",
	SI_IJA_DIWM_DISABLEINTERACT_TIP	= "Отключает взаимодействие с компаньоном во время движения игрока.",

	SI_IJA_DIWM_DISABLEMORE			= "Другие взаимодействия",
	SI_IJA_DIWM_DISABLEMORE_TIP		= "Отключает другие взаимодействия во время движения игрока.",
	SI_IJA_DIWM_DISABLEMORE_HEADER	= "Выберите другие взаимодействия, чтобы отключить",
	
	SI_IJA_DIWM_OPTIONAL			= "Дополнительные возможности",
	
	SI_IJA_DIWM_OPTIONAL1			= "Включить визуальную сетку",
	SI_IJA_DIWM_OPTIONAL_TIP1		= "Включено: сетка становится красной, когда сталкивается с отключенным действием",

	SI_IJA_DIWM_OPTIONAL2			= "Отключить в приседе",
	SI_IJA_DIWM_OPTIONAL_TIP2		= "Включено: отключает блокировку взаимодействий в приседе",
	
	SI_IJA_DIWM_OPTIONAL3			= "Отключить в подземельях/испытаниях",
	SI_IJA_DIWM_OPTIONAL_TIP3		= "Включено: отключает блокировку взаимодействия в подземельях/испытаниях",
	
	SI_IJA_DIWM_OPTIONAL4			= "Отключить в зонах PVP",
	SI_IJA_DIWM_OPTIONAL_TIP4		= "Включено: отключает блокировку взаимодействий в PVP-зоне",
	
	SI_IJA_DIWM_OPTIONAL5			= "Скрыть взаимодействие при перезарядке",
	SI_IJA_DIWM_OPTIONAL_TIP5		= "Включено: полностью скроет подсказку взаимодействия.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(_G[stringId], 1)
end
