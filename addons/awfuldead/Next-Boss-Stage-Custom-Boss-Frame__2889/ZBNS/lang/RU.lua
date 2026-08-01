-- RU - all boss names need to be translated
local translateBossNames = {
	--["Any"]							= "Any", -- no translation necessary
	["Ra Kotu"]						= "Ра Коту",
	["The Warrior"]					= "Воин",
	["Yokeda Kai"]					= "Йокеда Кай",
	["Zhaj'hassa the Forgotten"]	= "Жай'хасса Забытый",
	["Hunter-Killer Negatrix"]		= "Охотник-убийца Негатрикс",
	["Hunter-Killer Positrox"]		= "Охотник-убийца Позитрокс",
	["Reactor"]						= "Реактор",
	["Reducer"]						= "Редуктор",
	["Reclaimer"]					= "Регенератор",
	["Assembly General"]			= "Сборочный генерал",
	["Saint Olms the Just"]			= "Святой Олмс Справедливый",
	["Foundation Stone Atronach"]	= "Фундаментальный каменный атронах",
	["The Mage"]					= "Маг",
	["Tree-Minder Na-Kesh"]			= "Древохранительница На-Кеш",
	["Domihaus the Bloody-Horned"]	= "Домихаус Кровавые Рога",
	["Hiath the Battlemaster"]		= "Хиат Полководец",
	["Stonebreaker"]				= "Камнелом",
	["Velidreth"]					= "Велидрет",
	["Ash Titan"]					= "Пепельный титан",
	["Stormfist"]					= "Штормовой Кулак",
	["Valkyn Skoria"]				= "Валкин Скория",
	["Zaan the Scalecaller"]		= "Заан Призывательница Чешуи",
	["Thurvokun"]					= "Турвокун",
	["Molag Kena"]					= "Молаг Кена",
	["Z'Maja"]						= "З'Маджа",
	["Tarcyr"]						= "Тарсир",
	["Doylemish Ironheart"]			= "Дойлемиш Железное Сердце",
	["Vykosa the Ascendant"]		= "Вайкоса Вознесшаяся",
	["Pinnacle Factotum"]			= "Вершинный фактотум",
	["Balorgh"]						= "Балорг",
	["Yolnahkriin"]					= "Йолнакрин",
	["Lokkestiiz"]					= "Локкестиз",
	["Nahviintaas"]					= "Навинтас",
	["Lord Falgravn"]				= "Лорд Фальгравн",
	["Shade of the Grove"]			= "Тень Рощи",
	["Rahdgarak"]					= "Радгарак",
	["The Pyrelord"]				= "Пламенный Владыка",
	["Arkasis the Mad Alchemist"]	= "Безумный алхимик Аркасис",
	["Lady Thorn"]					= "Леди Шипов",
	["Tames-The-Beast"]				= "Приручает-Чудовищ",
	["Lady Minara"]					= "Леди Минара",
	["Champion Marcauld"]			= "Чемпион Марко",
	["Anal’a Tu’wha"]				= "Анал'а Ту'ва",
	["Vampire Lord Thisa"]			= "Вампир-лорд Тиза",
	["Ondagore the Mad"]			= "Ондагор Безумный",
	["Kjalnar Tombskald"]			= "Кьялнар Скальд Гробниц",
  	-- ["Warlord Tzogvin"]		    	= "", -- fill
	["Vault Protector"]				= "Защитник хранилища",
	["The Stonekeeper"]				= "Хранитель Камня",
	["Symphony of Blades"]			= "Симфония Клинков",
	["Overfiend"]					= "Сверхчудовище",
	["Ibomez the Flesh Sculptor"]	= "Ибомез Скульптор Плоти",
	["Lord Warden Dusk"]			= "Лорд-надзиратель Сумрак",
	["Kinras Ironeye"]				= "Кинрас Железный Глаз",
	["Captain Geminus"]				= "Капитан Гемина",
	["Pyroturge Encratis"]			= "Повелитель Пламени Энкратис",
	["Sentinel Aksalaz"]			= "Страж Аксалаз",
	["Caillaoife"]					= "Каиллаф",
	["Oaxiltso"]					= "Оазилцо",
	["Flame-Herald Bahsei"]			= "Басей Вестница Пламени",
	["Xalvakka"]					= "Залвакка",
	-- ["Magma Incarnate"] 				= "",
	-- ["Eliam Merric"] 					= "",
	-- ["Zelvraak the Unbreathing"]		= "",
	-- ["Corruption of Stone"] 			= "",
	-- ["Ritemaster Naqri"]				= "",
	-- ["Ozezan the Inferno"]				= "",
	-- ["Kovan Giryon"]					= "",
	-- ["Roksa the Warped"]				= "",
	-- ["Matriarch Lladi Telvanni"]		= "",

	-- v2.0.4
	--["Tames-the-Beast"]				="",
	--["Scorion Broodlord"]			="",
	--["Stone Behemoth"]				="",
	--["Vaduroth"]					="",
	--["Mathgamain"]					="",
	---- Shipwrights Regret
	--["Foreman Bradiggan"]			="",
	--["Captain Numirril"]			="",
	---- Coral Aerie
	--["Maligalig"]					="",
	--["Sarydil"]						="",
	---- Dreadsail Reef
	--["Turlassil"]					="",
	--["Lylanar"]						="",
	--["Reef Guardian"]				="",
	--["Tideborn Taleria"]			="",
	-- Bedlam Veil
	--	["Shattered Champion"]			="",
	--	["Darkshard"]					="",
	--	["The Blind"]					="",
	-- Oathsworn Pit
	--	["Aradros the Awakened"]		="",
}

local bossModes = {}
local defaultBossModes = ZBNS.bossModes
local translatedBossName
local pairs = pairs
for bossName, value in pairs(defaultBossModes) do
	translatedBossName = translateBossNames[bossName]
	if translatedBossName == nil then
		bossModes[bossName] = value
	else
		bossModes[translatedBossName] = value
	end
end
ZBNS.bossModes = bossModes
