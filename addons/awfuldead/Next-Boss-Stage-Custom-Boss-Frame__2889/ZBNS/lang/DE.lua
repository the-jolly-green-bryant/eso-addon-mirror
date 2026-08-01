-- DE - some boss names need to be translated but not all
local translateBossNames = {
	--["Any"]							= "Any", -- no translation necessary
	-- ["Ra Kotu"]						="Ra Kotu",	-- same
	["The Warrior"]					= "Krieger",
	-- ["Yokeda Kai"]					= "Yokeda Kai",	-- same
	["Zhaj'hassa the Forgotten"]	= "Zhaj'hassa der Vergessene",
	["Hunter-Killer Negatrix"]		= "Abfänger Negatrix",
	["Hunter-Killer Positrox"]		= "Abfänger Positrox",
	["Reactor"]						= "Reaktor",
	["Reducer"]						= "Minderer",
	["Reclaimer"]					= "Rückforderer",
	["Assembly General"]			= "Montagegeneral",
	["Saint Olms the Just"]			= "Heiliger Olms der Gerechte",
	["Foundation Stone Atronach"]	= "Grundsteinatronach",
	["The Mage"]					= "Magierin",
	["Tree-Minder Na-Kesh"]			= "Baumhirtin Na-Kesh",
	["Domihaus the Bloody-Horned"]	= "Domihaus der Blutgehörnte",
	["Hiath the Battlemaster"]		= "Hiath der Kampfmeister",
	["Stonebreaker"]				= "Steinbrecher",
	-- ["Velidreth"]					= "Velidreth", 	-- same
	["Ash Titan"]					= "Aschtitan",
	["Stormfist"]					= "Sturmfaust",
	-- ["Valkyn Skoria"]				= "Valkyn Skoria", -- same
	["Zaan the Scalecaller"]		= "Zaan die Schuppenruferin",
	-- ["Thurvokun"]					= "Thurvokun",	-- same
	-- ["Molag Kena"]					= "Molag Kena",	-- same
	-- ["Z'Maja"]						= "Z'Maja",	-- same
	-- ["Tarcyr"]						= "Tarcyr",	-- same
	["Doylemish Ironheart"]			= "Doylemish Eisenherz",
	["Vykosa the Ascendant"]		= "Vykosa die Aufgestiegene",
	["Pinnacle Factotum"]			= "Perfektioniertes Faktotum",
	-- ["Balorgh"]						= "Balorgh",	-- same
	-- ["Yolnahkriin"]					= "Yolnahkriin", -- same
	-- ["Lokkestiiz"]					= "Lokkestiiz", -- same
	-- ["Nahviintaas"]					= "Nahviintaas", -- same
	-- ["Lord Falgravn"]				= "Lord Falgravn", -- same
	["Shade of the Grove"]			= "Schatten des Hains",
	-- ["Rahdgarak"]					= "Rahdgarak",	-- same
	["The Pyrelord"]				= "Der Schürfürst",
	["Arkasis the Mad Alchemist"]	= "Arkasis der irre Alchemist",
	["Lady Thorn"]					= "Fürstin Dorn",
	["Tames-The-Beast"]				= "Zähmt-die-Bestien",
	["Lady Minara"]					= "Fürstin Minara",
	-- ["Champion Marcauld"]			= "Champion Marcauld",	-- same
	["Anal’a Tu’wha"]				= "Anal'a Tu'wha",	-- other '
	["Vampire Lord Thisa"]			= "Vampirfürstin Thisa",
	["Ondagore the Mad"]			= "Ondagore der Verrückte",
	["Kjalnar Tombskald"]			= "Kjalnar Grabskalde",
	["Warlord Tzogvin"]		    = "Kriegsfürst Tzogvin",
	["Vault Protector"]				= "Gewölbebeschützer",
	["The Stonekeeper"]				= "Steinwahrer",
	["Symphony of Blades"]			= "Sinfonie der Klingen",
	["Overfiend"]					= "Oberunhold",
	["Ibomez the Flesh Sculptor"]	= "Ibomez der Fleischbildner",
	["Lord Warden Dusk"]			= "Hochwärter Dämmer",
	["Kinras Ironeye"]				= "Kinras Eisenauge",
	["Captain Geminus"]				= "Hauptmann Geminus",
	["Pyroturge Encratis"]			= "Pyroturg Encratis",
	["Sentinel Aksalaz"]			= "Wächter Aksalaz",
	-- ["Caillaoife"]					= "Caillaoife",	-- same
	-- ["Oaxiltso"]                    = "Oaxiltso",    -- same
    ["Flame-Herald Bahsei"]            = "Flammenheroldin Bahsei",
    -- ["Xalvakka"]                    = "Xalvakka",    -- same
	["Magma Incarnate"] 			= "Magmaverkörperung",
	["Eliam Merric"] 				= "Reliktträgern",
	["Zelvraak the Unbreathing"]	= "Zelvraak der Atemlose",
	["Corruption of Stone"] 		= "Verderbnis des Steins",
	["Ritemaster Naqri"]			= "Rissmeister Naqri",
	["Ozezan the Inferno"]			= "Ozezan das Inferno",
	-- ["Kovan Giryon"]					= "Kovan Giryon",	-- same
	["Roksa the Warped"]			= "Roksa die Verkrümmte",
	["Matriarch Lladi Telvanni"]	= "Matriarchin Lladi Telvanni",

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
