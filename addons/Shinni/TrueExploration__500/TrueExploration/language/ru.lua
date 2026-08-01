if not TrueExplor then
	TrueExplor = {}
	TrueExplor.lang = TrueExplor.lang or {}
end

local language = {
	chatCommands = "Команды чата",
	chatCommandsDesc = "/discover, /undiscover, /clearmap, /tedebug [0,1]",
	radiusSetting = "Настройки радиусаПараметры радиуса",
	dungeonRadius = "Подземелье",
	dungeonRadiusDesc = "Количество тайлов, которые можно открывать сразу на карте подземелья (размер карты <= 768)",
	townRadius = "Город",
	townRadiusDesc = "Количество тайлов, которые можно открывать сразу на карте города (размер карты <= 1280)",
	islandRadius = "Остров",
	islandRadiusDesc = "Количество тайлов, которые можно открывать сразу на карте острова (или большого города) (размер карты <= 1536)",
	zoneRadius = "Зона",
	zoneRadiusDesc = "Количество тайлов, которые можно открывать сразу на карте зоны (размер карты <= 2048)",
	cyrodiilRadius = "Сиродил",
	cyrodiilRadiusDesc = "Количество тайлов, которые можно открывать сразу на карте Сиродила (размер карты = 5120)",
	mapTypes = "Типы карты",
		
	zone = "Включение аддона на картах зон",
	zoneDesc = "Если флажок не установлен, карты зон всегда будут открыты.",
	subzone = "Включение аддона на картах подзон",
	subzoneDesc = "Если флажок не установлен, карты подзон (подземелья, города) всегда будут открыты.",
	graphicSettings = "Параметры графики",
	discovered = "Прозрачность открытого",
	discoveredDesc = "0 ~ карта полностью видна, 255 ~ карта полностью скрыта.",
	undiscovered = "Прозрачность неоткрытого",
	undiscoveredDesc = "0 ~ карта полностью видна, 255 ~ карта полностью скрыта.",
	
}

for type, string in pairs(language) do
	TrueExplor.lang[type] = string
end
