-----------------------------------------------------------------------------------
-- Addon Name: Dolgubon's Lazy Writ Crafter
-- Creator: Dolgubon (Joseph Heinzle)
-- Addon Ideal: Simplifies Crafting Writs as much as possible
-- Addon Creation Date: March 14, 2016
--
-- File Name: Languages/br.lua
-- File Description: Brazilian Localization
-- Load Order Requirements: None
-- 
-----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--
-- TRANSLATION NOTES - PLEASE READ
--
-- If you are not looking to translate the addon you can ignore this. :D
--
-- If you ARE looking to translate this to something else then anything with a comment of Vital beside it is 
-- REQUIRED for the addon to function properly. These strings MUST BE TRANSLATED EXACTLY!
-- If only going for functionality, ctrl+f for Vital. Otherwise, you should just translate everything. Note that some strings 
-- Note that if you are going for a full translation, you must also translate defualt.lua and paste it into your localization file.
--
-- For languages that do not use the Latin Alphabet, there is also an optional langParser() function. IF the language you are translating
-- requires some changes to the WritCreater.parser() function then write the optional langParser() function here, and the addon
-- will use that instead. Just below is a commented out langParser for English. Be sure to remove the comments if rewriting it. [[  ]]
--
-- If you run into problems, please feel free to contact me on ESOUI.
--
-----------------------------------------------------------------------------------
--
--[[
function WritCreater.langParser(str)  -- Optional overwrite function for language translations
	local seperater = "%s+"

	str = string.gsub(str,":"," ")

	local params = {}
	local i = 1
	local searchResult1, searchResult2  = string.find(str,seperater)
	if searchResult1 == 1 then
		str = string.sub(str, searchResult2+1)
		searchResult1, searchResult2  = string.find(str,seperater)
	end

	while searchResult1 do

		params[i] = string.sub(str, 1, searchResult1-1)
		str = string.sub(str, searchResult2+1)
	    searchResult1, searchResult2  = string.find(str,seperater)
	    i=i+1
	end 
	params[i] = str
	return params

end
--]]

WritCreater = WritCreater or {}

local function proper(str)
	if type(str)== "string" then
		return zo_strformat("<<C:1>>",str)
	else
		return str
	end
end

function WritCreater.langWritNames() -- Vital
	-- Exact!!!  I know for german alchemy writ is Alchemistenschrieb - so ["G"] = schrieb, and ["A"]=Alchemisten
	local names = {
	["G"] = "Orde", -- EDITADO ["G"] = "Writ"
	[CRAFTING_TYPE_ENCHANTING] 		= "Encantamento", --"Enchanter",
	[CRAFTING_TYPE_BLACKSMITHING] 	= "Ferraria", --Blacksmith",
	[CRAFTING_TYPE_CLOTHIER] 		= "Alfaiataria", --"Clothier",
	[CRAFTING_TYPE_PROVISIONING]	= "Culin", --Provisioner",
	[CRAFTING_TYPE_WOODWORKING] 	= "Marcenaria", --Woodworker",
	[CRAFTING_TYPE_ALCHEMY] 		= "Alquimia", --Alchemist",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Joalheria" --Jewelry",
	}
	return names
end

function WritCreater.langCraftKernels()
	return 
	{
		[CRAFTING_TYPE_ENCHANTING] = "Encantamento", --"Enchant",
		[CRAFTING_TYPE_BLACKSMITHING] = "Ferraria", --"Blacksmith",
		[CRAFTING_TYPE_CLOTHIER] = "Alfaiataria", --"Clothier",
		[CRAFTING_TYPE_PROVISIONING] = "Culin", --"Provision",
		[CRAFTING_TYPE_WOODWORKING] = "Marcenaria", --"Woodwork",
		[CRAFTING_TYPE_ALCHEMY] = "Alquimia", --"Alchem",
		[CRAFTING_TYPE_JEWELRYCRAFTING] = "Joalheria", --"Jewelry",
	}
end

function WritCreater.langMasterWritNames() -- Vital
	local names = {
	["M"] 							= "magistral", --"masterful",
	["M1"]							= "mestre", --"master"
	[CRAFTING_TYPE_ALCHEMY]			= "mistura", --"concoction"
	[CRAFTING_TYPE_ENCHANTING]		= "Glifo", --"glyph"
	[CRAFTING_TYPE_PROVISIONING]	= "celebração", --"feast"
	["plate"]						= "proteção", --"plate"
	["tailoring"]					= "alfaiataria", --"tailoring"
	["leatherwear"]					= "roupa de couro", --"leatherwear"
	["weapon"]						= "arma", --"weapon"
	["shield"]						= "escudo", --"shield"
	}
return names

end

function WritCreater.writCompleteStrings() -- Vital for translation
	local strings = {
	["place"] = "Coloque as mercadorias",  --"Place the goods",
	["sign"] = "Assine o Manifesto.", --"Sign the Manifest",
	["masterPlace"] = "Eu terminei o", --"I've finished the ",
	["masterSign"] = "<Conclua o trabalho.>", --"<Finish the job.>",
	["masterStart"] = "<Retire a Ordem do Quadro.>", --"<Accept the contract.>",
	["Rolis Hlaalu"] = "Rolis Hlaalu", -- This is the same in most languages but ofc chinese and japanese
	["Deliver"] = "Entregue", --"Deliver",
	}
	return strings
end

function WritCreater.languageInfo() -- Vital

local craftInfo = 
	{
		[ CRAFTING_TYPE_CLOTHIER] = 
		{
			["pieces"] = --exact!!
			{
				 [1] = "Tunica", --robe
				 [2] = "Gibão", --jerkin
				 [3] = "Sapatos", --shoes
				 [4] = "Luvas", --gloves
				 [5] = "Chapeu", --hat
				 [6] = "Calções", --breeches
				 [7] = "Palas", --epaulet
				 [8] = "Faixa", --sash
				 [9] = "Brigantina", --jack
				[10] = "Botas", --boots
				[11] = "Braçadeiras", --bracers
				[12] = "Capacete", --helmet
				[13] = "Guardas", --guards
				[14] = "Ombreiras", --cops
				[15] = "Cinto", --belt
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Homespun Robe, Linen Robe
			{
				 [1] = "Artesanal", --Homespun
				 [2] = "Linho",	--Linen
				 [3] = "Algodao", --Cotton
				 [4] = "Sedaracna", --Spidersilk
				 [5] = "Fio de Ebano", --Ebonthread
				 [6] = "Kresh",
				 [7] = "Fio Ferroso", --Ironthread
				 [8] = "Fio de Prata", --Silverweave
				 [9] = "Sombrafiada", --Shadowspun
				[10] = "Ancestor", --Seda Ancestral
				[11] = "Couro Cru", --Rawhide
				[12] = "Pele", --Hide
				[13] = "Couro", --Leather
				[14] = "Couro-Completo", --Full-Leather
				[15] = "Couro Impio", --Fell
				[16] = "Brigandina", --Brigandine
				[17] = "Pele de Ferro", --Ironhide
				[18] = "Pele Soberba", --Superb
				[19] = "Umbrapele", --Shadowhide
				[20] = "Couro Rubedita", --Rubedo
			},
	
		},
		[CRAFTING_TYPE_BLACKSMITHING] = 
		{
			["pieces"] = --exact!!
			{
				[1] = "Machado", --axe
				 [2] = "Maça", --mace
				 [3] = "Espada", --sword
				 [4] = "Machado de Batalha", --battle axe
				 [5] = "Malho", --maul
				 [6] = "Montante", --greatsword
				 [7] = "Adaga", --dagger
				 [8] = "Couraça", --cuirass
				 [9] = "Escarpes", --sabatons
				[10] = "Manoplas", --gauntlets
				[11] = "Elmo", --helm
				[12] = "Grevas", --greaves
				[13] = "Espaldas", --pauldron
				[14] = "Cinturão", --girdle
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Iron Axe, Steel Axe
			{
				 [1] = "Ferro", --Iron
				 [2] = "Aço", --Steel
				 [3] = "Oricalco", --Orichalcum
				 [4] = "Anões", --Dwarven
				 [5] = "Ebano", --Ebony
				 [6] = "Calcinio", --Calcinium
				 [7] = "Galatita", --Galatite
				 [8] = "Mercurio", --Quicksilver
				 [9] = "Aço do Vacuo", --Voidsteel
				[10] = "Rubedita", --Rubedite
			},

		},
		[CRAFTING_TYPE_WOODWORKING] = 
		{
			["pieces"] = --Exact!!!
			{
				[1] = "Arco", --bow
				[3] = "Infernal", --inferno
				[4] = "Gelo", --Ice
				[5] = "Raio", --lightning
				[6] = "Restauração", --restoration
				[2] = "Escudo", --shield
			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
			{
				[1] = "Bordo", --Maple
				 [2] = "Carvalho", --Oak
				 [3] = "Faia", --Beech
				 [4] = "Nogueira", --Hickory
				 [5] = "Teixo", --Yew
				 [6] = "Betula", --Birch
				 [7] = "Freixo", --Ash
				 [8] = "Mogno", --Mahogany
				 [9] = "Madeira da Noite", --Nightwood
				[10] = "Freixo Rubi", --Ruby Ash
			},

		},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = 
		{
			["pieces"] = --Exact!!!
			{
				[1] = "anel", --ring
				[2] = "colar", --necklace

			},
			["match"] = --exact!!! This is not the material, but rather the prefix the material gives to equipment. e.g. Maple Bow. Oak Bow.
			{
				[1] = "Peltre", -- 1 (Pewter)
				[2] = "Cobre", -- 26 (Copper)
				[3] = "Prata", -- CP10 (Silver)
				[4] = "Electrum", --CP80 (Electrum)
				[5] = "Platina", -- CP150 (Platinum)
			},

		},
		[CRAFTING_TYPE_ENCHANTING] = 
		{
			["pieces"] = --exact!!
			{ --{String Identifier, ItemId, positive or negative}
				{"Resistencia Infecciosa", 45841,2}, --{"disease", 45841,2},
				{"Infeccioso", 45841,1}, --{"foulness", 45841,1},
				{"Absorver Vigor", 45833,2}, --{"absorb stamina", 45833,2},
				{"Absorver Magicka", 45832,2}, --{"absorb magicka", 45832,2},
				{"Absorcao de Saude", 45831,2}, --{"absorb health", 45831,2},
				{"Resistência ao Gelo",45839,2}, --{"frost resist",45839,2},
				{"Gelo",45839,1}, --{"frost",45839,1},
				{"Custo de Vigor", 45836,2}, --{"feat", 45836,2},
				{"Recuperacao de Vigor", 45836,1}, --{"stamina recovery", 45836,1},
				{"Robustez", 45842,1}, --{"hardening", 45842,1},
				{"Esmagador", 45842,2}, --{"crushing", 45842,2},
				{"Investida", 68342,2}, --{"onslaught", 68342,2},
				{"Defesa", 68342,1}, --{"defense", 68342,1},
				{"Blindagem",45849,2}, --{"shielding",45849,2},
				{"Contra-ataque",45849,1}, --{"bashing",45849,1},
				{"Resistência ao Venenoso",45837,2}, --{"poison resist",45837,2},
				{"Dano Venenoso",45837,1}, --{"poison",45837,1},
				{"Dano Magico",45848,2}, --{"spell harm",45848,2},
				{"magica",45848,1}, --{"magical",45848,1},
				{"Recuperacao de Magicka", 45835,1}, --{"magicka recovery", 45835,1},
				{"Custo de Feiticos", 45835,2}, --{"spell cost", 45835,2},
				{"Resistencia ao Eletrico",45840,2}, --{"shock resist",45840,2},
				{"Dano Eletrico",45840,1}, --{"shock",45840,1},
				{"Recuperacao de Saude",45834,1}, --{"health recovery",45834,1},
				{"Redução de Saude",45834,2}, --{"decrease health",45834,2},
				{"Enfraquecer",45843,2}, --{"weakening",45843,2},
				{"Arma",45843,1}, --{"weapon",45843,1},
				{"Alquimista",45846,1}, --{"boost",45846,1},
				{"Aceleracao",45846,2}, --{"speed",45846,2},
				{"Resistencia ao igneo",45838,2}, --{"flame resist",45838,2},
				{"Dano igneo",45838,1}, --{"flame",45838,1},
				{"Reducao de Dano Fisico", 45847,2}, --{"decrease physical", 45847,2},
				{"Aumento de Dano Fisico", 45847,1}, --{"increase physical", 45847,1},
				{"vigor",45833,1}, --{"stamina",45833,1},
				{"saude",45831,1}, --{"health",45831,1},
				{"magica",45832,1} --{"magicka",45832,1}
			},
			["match"] = --exact!!! The names of glyphs. The prefix (in English) So trifling glyph of magicka, for example
			{
				 {"insignificante", 45855}, --{"trifling", 45855},
				 {"inferior",45856}, --{"inferior",45856},
				 {"pequeno",45857}, --{"petty",45857},
				 {"leve",45806}, --{"slight",45806},
				 {"menor",45807}, --{"minor",45807},
				 {"reduzido",45808}, --{"lesser",45808},
				 {"moderado",45809}, --{"moderate",45809},
				 {"medio",45810}, --{"average",45810},
				 {"forte",45811}, --{"strong",45811},
				 {"maior",45812}, --{"major",45812},
				 {"maioral",45813}, --{"greater",45813},
				 {"grandioso",45814}, --{"grand",45814},
				 {"esplendido",45815}, --{"splendid",45815},
				 {"monumental",45816}, --{"monumental",45816},
			     {"Verdadeiramente Glorioso",{68341,68340,},}, --{"truly",{68341,68340,},},
				 {"soberbo",{64509,64508,},}, --{"superb",{64509,64508,},},
			},
			["quality"] = 
			{
				{"normal",45850}, --{"normal",45850},
				{"fino",45851}, --{"fine",45851},
				{"superior",45852}, --{"superior",45852},
				{"epico",45853}, --{"epic",45853},
				{"lendario",45854}, --{"legendary",45854},
				{"", 45850} --{"", 45850} -- default, if nothing is mentioned. Default should be Ta.
			}
		},
	} 

	return craftInfo

end

function WritCreater.masterWritQuality() -- Vital . This is probably not necessary, but it stays for now because it works
	return {{"epico",4},{"lendario",5}} -- {{"Epic",4},{"Legendary",5}}
end

function WritCreater.langEssenceNames() -- Vital

local essenceNames =  
	{
		[1] = "Oko", --health
		[2] = "Deni", --stamina
		[3] = "Makko", --magicka
	}
	return essenceNames
end

function WritCreater.langPotencyNames() -- Vital
	--exact!! Also, these are all the positive runestones - no negatives needed.
	local potencyNames = 
	{
		[1] = "Jora", --Lowest potency stone lvl
		[2] = "Porade",
		[3] = "Jera",
		[4] = "Jejora",
		[5] = "Odra",
		[6] = "Pojora",
		[7] = "Edora",
		[8] = "Jaera",
		[9] = "Pora",
		[10]= "Denara",
		[11]= "Rera",
		[12]= "Derado",
		[13]= "Rekura",
		[14]= "Kura",
		[15]= "Rejera",
		[16]= "Repora", --v16 potency stone
		
	}
	return potencyNames
end

local bankExceptions = 
{
	["original"] = {
		
	},
	["corrected"] = {
		
	}
}


function WritCreater.bankExceptions(condition)
	condition = string.gsub(condition, ":", " ")
	for i = 1, #bankExceptions["original"] do
		condition = string.gsub(condition,bankExceptions["original"][i],bankExceptions["corrected"][i])
	end
	return condition
end

function WritCreater.questExceptions(condition)
	condition = string.gsub(condition, " "," ")
	return condition
end

function WritCreater.enchantExceptions(condition)
	condition = string.lower(condition)
	condition = string.gsub(condition, " "," ")
	condition = string.gsub(condition,"entregue","delivery")
	return condition
end

function WritCreater.langTutorial(i) 
	local t = {
		[5]="Há também algumas coisas que você deveria saber.\nPrimeiro, /dailyreset é um comando do chat vai dizer\nquanto tempo falta até a próxima reinicialização diária do servidor.", --[5]="There's also a few things you should know.\nFirst, /dailyreset is a slash command that will tell you\nhow long until the next daily server reset.",
		[4]="Finalmente, você também pode optar por desativar ou\native este addon para cada profissão.\nPor padrão, todas as profissões estão ativadas.\nSe você deseja desativar alguns, por favor, verifique as configurações.", --[4]="Finally, you can also choose to deactivate or\nactivate this addon for each profession.\nBy default, all applicable crafts are on.\nIf you wish to turn some off, please check the settings.",
		[3]="Em seguida, você precisa escolher se deseja ver essa\njanela ao usar uma estação de criação.\nA janela mostrará quantos materiais o contrato precisa, bem como quantos você tem atualmente.", --[3]="Next, you need to choose if you wish to see this\nwindow when using a crafting station.\nThe window will tell you how many mats the writ will require, as well as how many you currently have.",
		[2]="A primeira configuração a escolher é se você\nquer usar o AutoCraft.\nAo ativado, quando você entra em uma estação de criação, o addon vai começar a criar.", --[2]="The first setting to choose is if you\nwant to useAutoCraft.\nIf on, when you enter a crafting station, the addon will start crafting.",
		[1]="Bem-vindo ao Dolgubon's Lazy Writ Crafter!\nHá algumas configurações que você deve fazer primeiro.\n Você pode alterar as configurações a qualquer\nmomento no menu de configurações.", --[1]="Welcome to Dolgubon's Lazy Writ Crafter!\nThere are a few settings you should choose first.\n You can change the settings at any\n time in the settings menu.",
	}
	return t[i]
end

function WritCreater.langTutorialButton(i,onOrOff) -- sentimental and short please. These must fit on a small button
	local tOn = 
	{
		[1]="Usar o Padrão", --"Use Defaults",
		[2]="Ativado", --"On",
		[3]="Mostrar", --"Show",
		[4]="Continuar", --"Continue",
		[5]="Finalizar", --"Finish",
	}
	local tOff=
	{
		[1]="Continuar", --"Continue",
		[2]="Desativado", --"Off",
		[3]="Não mostrar", --"Do not show",
	}
	if onOrOff then
		return tOn[i]
	else
		return tOff[i]
	end
end

function WritCreater.langStationNames()
	return
	{
		["Estação de Ferraria"] 		= 1, --["Blacksmithing Station"] = 1,
		["Estação de Alfaiataria"] 		= 2, --["Clothing Station"] = 2,
		["Mesa de Encantamentos"] 		= 3, --["Enchanting Table"] = 3,
		["Estação de Alquimia"] 		= 4, --["Alchemy Station"] = 4,
		["Fogueira"] 					= 5, --["Cooking Fire"] = 5,
		["Estação de Marcenaria"] 		= 6, --["Woodworking Station"] = 6,
		["Estação de Joalheria"] 		= 7, --["Jewelry Crafting Station"] = 7, 
	}
end

-- What is this??! This is just a fun 'easter egg' that is never activated on easter.
-- Replaces mat names with a random DivineMats on Halloween, New Year's, and April Fools day. You don't need this many! :D
-- Translate it or don't, completely up to you. But if you don't translate it, replace the body of 
-- shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()
-- with just a return false. (This will prevent it from ever activating. Also, if you're a user and don't like this,
-- you're boring, and also that's how you can disable it. )
local DivineMats =
{
	{"Rusted Nails", "Ghost Robes", "","","", "Rotten Logs","Cursed Gold", "Chopped Liver", "Crumbled Gravestones", "Toad Eyes", "Werewolf Claws", "Zombie Guts", "Lizard Brains"},
	{"Buzzers","Sock Puppets", "Jester Hats","Otter Noses", "Red Herrings", "Wooden Snakes", "Fool's Gold", "Mudpies"},
	{"Coal", "Stockings", "","","","Evergreen Branches", "Golden Rings", "Bottled Time", "Reindeer Bells", "Elven Hats", "Pine Needles", "Cups of Snow"},
}

-- confetti?
-- random sounds?
-- 

local function shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()
	if GetDate()%10000 == 1031 then return 1 end
	if GetDate()%10000 == 401 then return 2 end
	if GetDate()%10000 == 1231 then return 3 end
--	if GetDisplayName() == "@Dolgubon" then
--		return 2
--	end
	return false
end

local function hasMadnessEngulfedNirn()
    local t = GetTimeString() local c = string.sub(t, 1,string.find(t, ":") - 1)
    return tonumber(c) > 11
end

local function wellWeShouldUseADivineMatButWeHaveNoClueWhichOneItIsSoWeNeedToAskTheGodsWhichDivineMatShouldBeUsed() local a= math.random(1, #DivineMats ) return DivineMats[a] end
local l = shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit()

if l then
	DivineMats = DivineMats[l]
	local DivineMat = wellWeShouldUseADivineMatButWeHaveNoClueWhichOneItIsSoWeNeedToAskTheGodsWhichDivineMatShouldBeUsed()
	
	WritCreater.strings.smithingReqM = function (amount, _,more)
		local craft = GetCraftingInteractionType()
		DivineMat = DivineMats[craft]
		return zo_strformat( "A construção vai usar <<1>> <<4>> (|cf60000Você possui <<3>>|r)" ,amount, type, more, DivineMat) end
	 --return zo_strformat( "Crafting will use <<1>> <<4>> (|cf60000You need <<3>>|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReqM2 = function (amount, _,more)
		local craft = GetCraftingInteractionType()
		DivineMat = DivineMats[craft]
		return zo_strformat( "As well as <<1>> <<4>> (|cf60000Você possui <<3>>|r)" ,amount, type, more, DivineMat) end
	 --return zo_strformat( "As well as <<1>> <<4>> (|cf60000You need <<3>>|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReq = function (amount, _,more) 
		local craft = GetCraftingInteractionType()
		DivineMat = DivineMats[craft]
		return zo_strformat( "A construção vai usar <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
	 --return zo_strformat( "Crafting will use <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
	WritCreater.strings.smithingReq2 = function (amount, _,more) 
		local craft = GetCraftingInteractionType()
		DivineMat = DivineMats[craft]
		return zo_strformat( "As well as <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
     --return zo_strformat( "As well as <<1>> <<4>> (|c2dff00<<3>> available|r)" ,amount, type, more, DivineMat) end
end


-- [[ /script local writcreater = {} local c = {a = 1} local g = {__index = c} setmetatable(writ, g) d(a.a) local e = {__index = {Z = 2}} setmetatable(c, e) d(a.Z)
local h = {__index = {}}
local t = {}
local g = {["__index"] = t}
setmetatable(t, h)
setmetatable(WritCreater, g) --]]

local function enableAlternateUniverse(override)

	if shouldDivinityprotocolbeactivatednowornotitshouldbeallthetimebutwhateveritlljustbeforabit() == 2 or override then
	--if true then
		local stations = 
			{"Blacksmithing Station", "Clothing Station", "Enchanting Table",
			"Alchemy Station",  "Cooking Fire", "Woodworking Station","Jewelry Crafting Station",  "Outfit Station", "Transmute Station", "Wayshrine"}
			local stationNames =  -- in the comments are other names that were also considered, though not all were considered seriously
			{"Wightsmithing Station", -- Popcorn Machine , Skyforge, Heavy Metal Station, Metal Clockwork Solid, Wightsmithing Station., Coyote Stopper
			 "Sock Puppet Theatre", -- Sock Distribution Center, Soul-Shriven Sock Station, Grandma's Sock Knitting Station, Knits and Pieces, Sock Knitting Station
			"Top Hats Inc.", -- Mahjong Station, Magic Store, Card Finder, Five Aces, Top Hat Store
			"Seedy Skooma Bar", -- Chemical Laboratory , Drugstore, White's Garage, Cocktail Bar, Med-Tek Pharmaceutical Company, Med-Tek Laboratories, Skooma Central, Skooma Backdoor Dealers, Sheogorath's Pharmacy
			 "McDaedra Order Kiosk",--"Khajit Fried Chicken", -- Khajit Fried Chicken, soup Kitchen, Some kind of bar, misspelling?, Roast Bosmer
			 "IKEA Assembly Station", -- Chainsaw Massace, Saw Station, Shield Corp, IKEA Assembly Station, Wood Splinter Removal Station
			 "April Fool's Gold",--"Diamond Scam Store", -- Lucy in the Sky, Wedding Planning Hub, Shiny Maker, Oooh Shiny, Shiny Bling Maker, Cubit Zirconia, Rhinestone Palace
			 -- April Fool's Gold
			 "Khajit Fur Trade Outpost", -- Jester Dressing Room Loincloth Shop, Khajit Walk, Khajit Fashion Show, Mummy Maker, Thalmor Spy Agency, Tamriel Catwalk, 
			 --	Tamriel Khajitwalk, second hand warehouse,. Dye for Me, Catfur Jackets, Outfit station "Khajiit Furriers", Khajit Fur Trading Outpost
			 "Sacrificial Goat Altar",-- Heisenberg's Station Correction Facility, Time Machine, Probability Redistributor, Slot Machine Rigger, RNG Countermeasure, Lootcifer Shrine, Whack-a-mole
			 -- Anti Salt Machine, Department of Corrections, Quantum State Rigger , Unnerf Station
			 "TARDIS" } -- Transporter, Molecular Discombobulator, Beamer, Warp Tunnel, Portal, Stargate, Cannon!, Warp Gate
			
			local crafts = {"Blacksmithing", "Clothing", "Enchanting","Alchemy","Provisioning","Woodworking","Jewelry Crafting" }
			local craftNames = {
				"Wightsmithing",
				"Sock Knitting",
				"Top Hat Tricks",
				"Skooma Brewing",
				"McDaedra",--"Chicken Frying",
				"IKEA Assembly",
				"Fool's Gold Creation",
			}
			local quest = {"Blacksmith", "Clothier", "Enchanter" ,"Alchemist", "Provisioner", "Woodworker", "Jewelry Crafting","Provisioner Writ"}
			local questNames = 	
			{
				"Wightsmith",
				"Sock Knitter",
				"Top Hat Trickster",
				"Skooma Brewer",
				"McDaedra",--"Chicken Fryer",
				"IKEA Assembly",
				"Fool's Gold",
				"McDaedra Delivery",
			}
			local items = {"Blacksmith", "Clothier", "Enchanter", "alchemical", "food and drink",  "Woodworker", "Jewelry"}
			local itemNames = {
				"Wight",
				"Sock Puppet",
				"Top Hat",
				"Skooma",
				"McDaedra Nuggets",--"Fried Chicken",
				"IKEA",
				"Fool's Gold",
			}
			local coffers = {"Ferreiro", "alfaiate", "Encantador" ,"Alquimista", "Culinária", "Marcenaria", "Joalheria",}
			local cofferNames = {
				"Wightsmith",
				"Sock Knitter",
				"Top Hat Trickster",
				"Skooma Brewer",
				"McDaedra Takeout",--"Chicken Fryer",
				"IKEA Assembly",
				"Fool's Gold",
			}
			local ones = {"Jewelry Crafter"}
			local oneNames = {"Fool's Gold"}
		

		local t = {["__index"] = {}}
		function h.__index.alternateUniverse()
			return stations, stationNames
		end
		function h.__index.alternateUniverseCrafts()
			return crafts, craftNames
		end
		function h.__index.alternateUniverseQuests()
			return quest, questNames
		end
		function h.__index.alternateUniverseItems()
			return items, itemNames
		end
		function h.__index.alternateUniverseCoffers()
			return coffers, cofferNames
		end
		function h.__index.alternateUniverseOnes()
			return ones, oneNames
		end
		

		h.__metatable = "No looky!"
		local a = WritCreater.langStationNames()
		a[1] = 1
		for i = 1, 7 do
			a[stationNames[i]] = i
		end
		WritCreater.langStationNames = function() 
			return a
		end
		local b =WritCreater.langWritNames()
		for i = 1, 7 do
			b[i] = questNames[i]
		end
		-- WritCreater.langWritNames = function() return b end

	end
end

-- For Transmutation: "Well Fitted Forever"
-- So far, I like blacksmithing, clothing, woodworking, and wayshrine, enchanting
-- that leaves , alchemy, cooking, jewelry, outfits, and transmutation

local lastYearStations = 
{"Blacksmithing Station", "Clothing Station", "Woodworking Station", "Cooking Fire", 
"Enchanting Table", "Alchemy Station", "Outfit Station", "Transmute Station", "Wayshrine"}
local stationNames =  -- in the comments are other names that were also considered, though not all were considered seriously
{"Heavy Metal 112.3 FM", -- Popcorn Machine , Skyforge, Heavy Metal Station
 "Sock Knitting Station", -- Sock Distribution Center, Soul-Shriven Sock Station, Grandma's Sock Knitting Station, Knits and Pieces
 "Splinter Removal Station", -- Chainsaw Massace, Saw Station, Shield Corp, IKEA Assembly Station, Wood Splinter Removal Station
 "McSheo's Food Co.", 
 "Tetris Station", -- Mahjong Station
 "Poison Control Centre", -- Chemical Laboratory , Drugstore, White's Garage, Cocktail Bar, Med-Tek Pharmaceutical Company, Med-Tek Laboratories
 "Thalmor Spy Agency", -- Jester Dressing Room Loincloth Shop, Khajit Walk, Khajit Fashion Show, Mummy Maker, Thalmor Spy Agency, Morag Tong Information Hub, Tamriel Spy HQ, 
 "Department of Corrections",-- Heisenberg's Station Correction Facility, Time Machine, Probability Redistributor, Slot Machine Rigger, RNG Countermeasure, Lootcifer Shrine, Whack-a-mole
 -- Anti Salt Machine, Department of Corrections
 "Warp Gate" } -- Transporter, Molecular Discombobulator, Beamer, Warp Tunnel, Portal, Stargate, Cannon!, Warp Gate

-- enableAlternateUniverse(GetDisplayName()=="@Dolgubon")
enableAlternateUniverse()

local function alternateListener(eventCode,  channelType, fromName, text, isCustomerService, fromDisplayName)
	if not WritCreater.alternateUniverse and fromDisplayName == "@Dolgubon"and (text == "Let the Isles bleed into Nirn!" ) then	
		enableAlternateUniverse(true)	
		WritCreater.WipeThatFrownOffYourFace(true)	
	end	
	-- if GetDisplayName() == "@Dolgubon" then
	-- 	enableAlternateUniverse(true)	
	-- 	WritCreater.WipeThatFrownOffYourFace(true)	
	-- end
end	
-- 20764
-- 21465

EVENT_MANAGER:RegisterForEvent(WritCreater.name,EVENT_CHAT_MESSAGE_CHANNEL, alternateListener)

--Hide craft window when done
--"Verstecke Fenster anschließend",
-- [tooltip ] = "Verstecke das Writ Crafter Fenster an der Handwerksstation automatisch, nachdem die Gegenstände hergestellt wurden"

--[[
SLASH_COMMANDS['/opencontainers'] = function()local a=WritCreater.langWritRewardBoxes() for i=1,200 do for j=1,6 do if a[j]==GetItemName(1,i) then if IsProtectedFunction("endUseItem") then
	CallSecureProtected("endUseItem",1,i)
else
	UseItem(1,i)
end end end end end
--]]
function WritCreater.language()

	return false

end

local function myLower(str)
	return zo_strformat("<<z:1>>",str)
end

function WritCreater.getWritAndSurveyType()
	if not WritCreater.langCraftKernels then return end

	local kernels = WritCreater.langCraftKernels()
	local craftType
	for craft, kernel in pairs(kernels) do
		if string.find(myLower(itemName), myLower(kernel)) then
			craftType = craft
		end
	end
	return craftType
end

local function proper(str)
	if type(str)== "string" then
		return zo_strformat("<<C:1>>",str)
	else
		return str
	end
end

WritCreater.lang = "none"

-- This is in the default, so that if a new setting is added an error is not thrown, 
-- and the addon instead uses the English option strings for any that are missing.

local function runeMissingFunction (ta,essence,potency)
	local missing = {}
	if not ta["bag"] then
		missing[#missing + 1] = "|rTa|cf60000" --3
	end
	if not essence["bag"] then
		missing[#missing + 1] =  "|cffcc66"..essence["slot"].."|cf60000" --2
	end
	if not potency["bag"] then
		missing[#missing + 1] = "|c0066ff"..potency["slot"].."|r"  --1
	end
	local text = ""
	for i = 1, #missing do
		if i ==1 then 
			text = "|cff3333O glifo não pode ser craftado.Não possui material suficiente "..proper(missing[i])  --"|cff3333Glyph could not be crafted. You do not have any "..proper(missing[i])
		else
			text = text.." ou "..proper(missing[i])
		end
	end
	return text
end


local function dailyResetFunction(till, stamp) -- You can translate the following simple version instead.
										-- function (till) d(zo_strformat("<<1>> hours and <<2>> minutes until the daily reset.",till["hour"],till["minute"])) end,
	if till["hour"]==0 then
		if till["minute"]==1 then
			return "1 minuto até o reinício diário do servidor!" --return "1 minute until daily server reset!"
		elseif till["minute"]==0 then
			if stamp==1 then
			return "Reinicio diario em "..stamp.." segundos!" --return "Daily reset in "..stamp.." seconds!"
			else
			return "Sério ... pare de perguntar. Nasceu de sete meses??? Reinicia em mais um segundo! " --return "Seriously... Stop asking. Are you that impatient??? It resets in one more second! *grumble grumble*"
			end
		else
			return till["minute"].." minutos até eu reiniciar o dia" --return till["minute"].." minutes until daily reset!"
		end
	elseif till["hour"]==1 then
		if till["minute"]==1 then
			return till["hour"].." hora e "..till["minute"].."minutos até a reinicializar as Ordens diária!" --return till["hour"].." hour and "..till["minute"].." minute until daily reset"
		else
			return till["hour"].." hora e "..till["minute"].."minutos até a reinicializar as Ordens diária!" --return till["hour"].." hour and "..till["minute"].." minutes until daily reset"
		end
	else
		if till["minute"]==1 then
			return till["hour"].." horas e "..till["minute"].."minutos até a reinicializar as Ordens diária!" --return till["hour"].." hours and "..till["minute"].." minute until daily reset"
		else
			return till["hour"].." horas e "..till["minute"].."minutos até a reinicializar as Ordens diária!" --return till["hour"].." hours and "..till["minute"].." minutes until daily reset"
		end
	end 
end

local function masterWritEnchantToCraft (pat,set,trait,style,qual,mat,writName,Mname,generalName)
	local partialString = zo_strformat("Construa um CP150 << t:6 >> << t:1 >> de << t:2 >> com o traço e estilo << t:3 >> << t:4 >> em << t:5 >> qualidade",pat,set,trait,style,qual,mat) --local partialString = zo_strformat("Crafting a CP150 <<t:6>> <<t:1>> from <<t:2>> with the <<t:3>> trait and style <<t:4>> at <<t:5>> quality",pat,set,trait,style,qual,mat)
	return zo_strformat("<<t:2>> <<t:3>> <<t:4>>: <<1>>",partialString,writName,Mname,generalName ) --return zo_strformat("<<t:2>> <<t:3>> <<t:4>>: <<1>>",partialString,writName,Mname,generalName )
end

WritCreater.missingTranslations = {}
local stringIndexTable = {}
local findMissingTranslationsMetatable = 
{
["__newindex"] = function(t,k,v) if not stringIndexTable[tostring(t)] then stringIndexTable[tostring(t)] = {} end stringIndexTable[tostring(t)][k] = v WritCreater.missingTranslations[k] = {k, v} end,
["__index"] = function(t, k) return stringIndexTable[tostring(t)][k] end,
}

WritCreater.strings = {}
setmetatable(WritCreater.strings, findMissingTranslationsMetatable)

WritCreater.strings["runeReq"] 					= function (essence, potency) return zo_strformat("|c2dff00Precisamos de 1 |rTa|c2dff00, 1 |cffcc66<<1>>|c2dff00 e 1 |c0066ff<<2>>|r", essence, potency) end --= function (essence, potency) return zo_strformat("|c2dff00A Contrução  1 |rTa|c2dff00, 1 |cffcc66<<1>>|c2dff00 and 1 |c0066ff<<2>>|r", essence, potency) end
WritCreater.strings["runeMissing"] 				= runeMissingFunction 
WritCreater.strings["notEnoughSkill"]			= "Sua habilidade de alfaiataria não é alta o suficiente para fabricar o equipamento necessário" --= "You do not have a high enough crafting skill to make the required equipment"
WritCreater.strings["smithingMissing"] 			= "\n|cf60000Você não tem materiais suficientes.|r" --= "\n|cf60000You do not have enough mats|r"
WritCreater.strings["craftAnyway"] 				= "Construa mesmo assim" --= "Craft anyway"
WritCreater.strings["smithingEnough"] 			= "\n|c2dff00Você tem materiais suficientes|r" --= "\n|c2dff00You have enough mats|r"
WritCreater.strings["craft"] 					= "|c00ff00Construa|r" --= "|c00ff00Craft|r"
WritCreater.strings["crafting"] 				= "|c00ff00Construindo ...|r" --= "|c00ff00Crafting...|r"
WritCreater.strings["craftIncomplete"] 			= "|cf60000Crafting could not be completed.\nYou need more mats.|r"
WritCreater.strings["moreStyle"] 				= "|cf60000Você não tem pedras de estilo utilizáveis ​​definidas.\nVerifique seu inventário, conquistas e configurações|r" --= "|cf60000You do not have any usable style stones.\nCheck your inventory, achievements, and settings|r"
WritCreater.strings["moreStyleSettings"]		= "|cf60000Você não tem uma pedra de estilo utilizável.\nVocê provavelmente precisa permitir mais no menu de configurações.|r" --= "|cf60000You do not have any usable style stones.\nYou likely need to allow more in the Settings Menu|r"
WritCreater.strings["moreStyleKnowledge"]		= "|cf60000Você não tem nenhuma pedra de estilo utilizável.\nVocê deve aprender mais algma pedra de estilo.|r" --= "|cf60000You do not have any usable style stones.\nYou might need to learn to craft more styles|r"
WritCreater.strings["dailyreset"] 				= dailyResetFunction
WritCreater.strings["complete"] 				= "|c00FF00Ordem completa.|r" --= "|c00FF00Writ complete.|r"
WritCreater.strings["craftingstopped"]			= "O construção parou. Verifique se o addon está criando o item correto.." --= "Crafting stopped. Please check to make sure the addon is crafting the correct item."
WritCreater.strings["smithingReqM"] 			= function (amount, type, more) return zo_strformat( "A construção vai usar <<1>> <<2>>  \n(Você possui |cf60000<<3>>|r)" ,amount, type, more) end --= function (amount, type, more) return zo_strformat( "Crafting will use <<1>> <<2>> (|cf60000You need <<3>>|r)" ,amount, type, more) end
WritCreater.strings["smithingReq"] 				= function (amount,type, current) return zo_strformat( "A construção vai usar <<1>> <<2>> \n(Você possui |c2dff00<<3>>|r)"  ,amount, type, current) end --= function (amount,type, current) return zo_strformat( "Crafting will use <<1>> <<2>> (|c2dff00<<3>> available|r)"  ,amount, type, current) end
WritCreater.strings["lootReceived"]				= "Foi recebido <<1>>(Você tem <<2>>)" --= "<<3>> <<1>> was received (You have <<2>>)"
WritCreater.strings["lootReceivedM"]			= "Foi recebido <<1>>" --= "<<1>> was received "
WritCreater.strings["countSurveys"]				= "Você tem <<1>> pesquisas" --= "You have <<1>> surveys"
WritCreater.strings["countVouchers"]			= "Você tem <<1>> Vouchers de Ordens não adquiridos" --= "You have <<1>> unearned Writ Vouchers"
WritCreater.strings["includesStorage"]			= function(type) local a= {"Surveys", "Master Writs"} a = a[type] return zo_strformat("A contagem inclui <<1>> o armazenamento das casas", a) end --= function(type) local a= {"Surveys", "Master Writs"} a = a[type] return zo_strformat("Count includes <<1>> in house storage", a) end
WritCreater.strings["surveys"]					= "Pesquisas" --= "Crafting Surveys"
WritCreater.strings["sealedWrits"]				= "Ordem selada" --= "Sealed Writs"
WritCreater.strings["masterWritEnchantToCraft"]	= function(lvl, type, quality, writCraft, writName, generalName) return zo_strformat("<<t:4>>de<<t:5>> <<t:6>>: Construindo um <<t:1>> Glifo de <<t:2>> na <<t:3>> qualidade",lvl, type, quality, writCraft, writName, generalName) end --= function(lvl, type, quality, writCraft, writName, generalName)return zo_strformat("<<t:4>> <<t:5>> <<t:6>>: Crafting a <<t:1>> Glyph of <<t:2>> at <<t:3>> quality",lvl, type, quality, writCraft,writName, generalName) end
WritCreater.strings["masterWritSmithToCraft"]	= masterWritEnchantToCraft
WritCreater.strings["withdrawItem"]				= function(amount, link, remaining) return "Dolgubon's Lazy Writ Crafter recuperou "..amount.." "..link..". ("..remaining.." restante no banco)" end --= function(amount, link, remaining) return "Dolgubon's Lazy Writ Crafter retrieved "..amount.." "..link..". ("..remaining.." in bank)" end -- in Bank for German
WritCreater.strings['fullBag']					= "Não tem espaço no seu inventário. Por favor, esvazie seu inventário." --= "You have no open bag spaces. Please empty your bag."
WritCreater.strings['masterWritSave']			= "O Lazy Writ Crafter de Dolgubon evitou que você aceitasse acidentalmente um comando mestre! Vá para o menu Configurações para desabilitar essa opção." --= "Dolgubon's Lazy Writ Crafter has saved you from accidentally accepting a master writ! Go to the settings menu to disable this option."
WritCreater.strings['missingLibraries']			= "Dolgubon's Lazy Writ Crafter precisa das seguintes bibliotecas independentes. Faça download, instale ou ative essas bibliotecas: " --= "Dolgubon's Lazy Writ Crafter requires the following standalone libraries. Please download, install or turn on these libraries: "
WritCreater.strings['resetWarningMessageText']	= "As diárias da Ordem reiniciarão <<1>> hora e <<2>> minutos\nVocê pode personalizar ou desativar este aviso nas configurações." --= "The daily reset for writs will be in <<1>> hour and <<2>> minutes\nYou can customize or turn off this warning in the settings"
WritCreater.strings['resetWarningExampleText']	= "O aviso será parecido com este" --= "The warning will look like this"



WritCreater.optionStrings = {}
WritCreater.optionStrings.nowEditing                   = "Você está alterando a configuração de% s" --= "You are changing %s settings"
WritCreater.optionStrings.accountWide                  = "Configuração Global" --= "Account Wide"
WritCreater.optionStrings.characterSpecific            = "Configuração específica por personagem" --= "Character Specific"
WritCreater.optionStrings.useCharacterSettings         = "Usar configurações de personagem" --= "Use character settings" -- de
WritCreater.optionStrings.useCharacterSettingsTooltip  = "Use configurações específicas do personagem apenas neste personagem" --= "Use character specific settings on this character only" --de
WritCreater.optionStrings["style tooltip"]						= function (styleName, styleStone) return zo_strformat("Permitir que <<1>> estilo, que usa <<2>> pedra de estilo, para ser usado para construção",styleName, styleStone) end --= function (styleName, styleStone) return zo_strformat("Allow the <<1>> style, which uses the <<2>> style stone, to be used for crafting",styleName, styleStone) end 
WritCreater.optionStrings["show craft window"]					= "Mostrar Janela de Construção" --= "Show Craft Window"
WritCreater.optionStrings["show craft window tooltip"]			= "Mostrar janela de construção quando a estação deconstrução estiver aberta" --= "Shows the crafting window when a crafting station is open"
WritCreater.optionStrings["autocraft"]							= "Criação Automatica" --= "AutoCraft"
WritCreater.optionStrings["autocraft tooltip"]					= "Ativar esta opção iniciará automaticamente a criação de itens ao interagir com a estação de criação. Se a janela não for exibida, esta opção será ATIVADA." --= "Selecting this will cause the addon to begin crafting immediately upon entering a crafting station. If the window is not shown, this will be on."
WritCreater.optionStrings["blackmithing"]						= "Ferraria" --= "Blacksmithing"
WritCreater.optionStrings["blacksmithing tooltip"]				= "Ativar a dica de Ferraria" --= "Turn the addon on for Blacksmithing"
WritCreater.optionStrings["clothing"]							= "Alfaiataria" --= "Clothing"
WritCreater.optionStrings["clothing tooltip"]					= "Ativar a dica de Alfaiataria" --= "Turn the addon on for Clothing"
WritCreater.optionStrings["enchanting"]							= "Encantamento" --= "Enchanting"
WritCreater.optionStrings["enchanting tooltip"]					= "Ativar a dica de Encantamento" --= "Turn the addon on for Enchanting"
WritCreater.optionStrings["alchemy"]							= "Alquimia" --= "Alchemy"
WritCreater.optionStrings["alchemy tooltip"]					= "Ativar a dica de Alquimia (Retirada de banco apenas)" --= "Turn the addon on for Alchemy (Bank Withdrawal only)"
WritCreater.optionStrings["provisioning"]						= "Culinária" --= "Provisioning"
WritCreater.optionStrings["provisioning tooltip"]				= "Ativar a dica de Culinária (Retirada de banco apenas)" --= "Turn the addon on for Provisioning (Bank Withdrawal only)"
WritCreater.optionStrings["woodworking"]						= "Marcenaria" --= "Woodworking"
WritCreater.optionStrings["woodworking tooltip"]				= "Ativar a dica de Marcenaria" --= "Turn the addon on for Woodworking"
WritCreater.optionStrings["jewelry crafting"]					= "Joalheria" --= "Jewelry Crafting"
WritCreater.optionStrings["jewelry crafting tooltip"]			= "Ativar a dica de Joalheria" --= "Turn the addon on for Jewelry Crafting"
WritCreater.optionStrings["writ grabbing"]						= "Retirar intens de Ordens de Fabricão" --= "Withdraw writ items"
WritCreater.optionStrings["writ grabbing tooltip"]				= "Pegue os materiais necessários para Ordem (por exwemplo, Raiz de Nirn, Ta, etc.) do banco" --= "Grab items required for writs (e.g. nirnroot, Ta, etc.) from the bank"
WritCreater.optionStrings["delay"]								= "Atraso na retirada"
WritCreater.optionStrings["delay tooltip"]						= "Quanto tempo esperar antes de retirar itens do banco (milissegundos)"
WritCreater.optionStrings["style stone menu"]					= "Pedras de estilo" --= "Style Stones Used"
WritCreater.optionStrings["style stone menu tooltip"]			= "Escolha quais pedras de estilo o plugin irá usar" --= "Choose which style stones the addon will use"
WritCreater.optionStrings["send data"]							= "Enviar dados" --= "Send Writ Data"
WritCreater.optionStrings["send data tooltip"]					= "Envie informações sobre as recompensas recebidas. Nenhuma outra informação é enviada." --= "Send information on the rewards received from your writ boxes. No other information is sent."
WritCreater.optionStrings["exit when done"]						= "Saia da janela de criação" --= "Exit crafting window"
WritCreater.optionStrings["exit when done tooltip"]				= "Saia da janela de construção quando todo o pedido for concluído" --= "Exit crafting window when all crafting is completed"
WritCreater.optionStrings["automatic complete"]					= "Diálogo automático" --= "Automatic quest dialog"
WritCreater.optionStrings["automatic complete tooltip"]			= "Aceitar e completar missões automaticamente" --= "Automatically accepts and completes quests when at the required place"
WritCreater.optionStrings["new container"]						= "Manter novo status" --= "Keep new status"
WritCreater.optionStrings["new container tooltip"]				= "Manter o novo status para contêineres de recompensa" --= "Keep the new status for writ reward containers"
WritCreater.optionStrings["master"]								= "Comandos principais" --= "Master Writs"
WritCreater.optionStrings["master tooltip"]						= "If this is ON the addon will craft Master Writs you have active"
WritCreater.optionStrings["right click to craft"]				= "Clique com o botão direito para criar" --= "Right Click to Craft"
WritCreater.optionStrings["right click to craft tooltip"]		= "Se estiver LIGADO, o plug-in criará todos os comandos principais que você solicitar após clicar com o botão direito." --= "If this is ON the addon will craft Master Writs you tell it to craft after right clicking a sealed writ"
WritCreater.optionStrings["crafting submenu"]					= "Itens pedido de Construção" --= "Trades to Craft"
WritCreater.optionStrings["crafting submenu tooltip"]			= "Desativar extensão para comandos específicos" --= "Turn the addon off for specific crafts"
WritCreater.optionStrings["timesavers submenu"]					= "Economize tempo" --= "Timesavers"
WritCreater.optionStrings["timesavers submenu tooltip"]			= "Várias economias de tempo" --= "Various small timesavers"
WritCreater.optionStrings["loot container"]						= "Abrir o container quando recebido" --= "Loot container when received"
WritCreater.optionStrings["loot container tooltip"]				= "Abra o contêiner de recompensas do pedido ao recebê-lo" --= "Loot writ reward containers when you receive them"
WritCreater.optionStrings["master writ saver"]					= "Salvar pedido de Ordem Mestre" --= "Save Master Writs"
WritCreater.optionStrings["master writ saver tooltip"]			= "Impedir criação de Ordens Mestre" --= "Prevents Master Writs from being accepted"
WritCreater.optionStrings["loot output"]						= "Alerta de recompensa valiosa" --= "Valuable Reward Alert"
WritCreater.optionStrings["loot output tooltip"]				= "Mostrar mensagem quando itens de alto valor são recebidos dos contêineres de recompensa" --= "Output a message when valuable items are received from a writ"
WritCreater.optionStrings["autoloot behaviour"]					= "AutolootBehaviour" --= "Autoloot Behaviour" -- Note that the following three come early in the settings menu, but becuse they were changed
WritCreater.optionStrings["autoloot behaviour tooltip"]			= "Escolha quando o plug-in irá abrir automaticamente os contêineres de recompensa" --= "Choose when the addon will autoloot writ reward containers" -- they are now down below (with untranslated stuff)
WritCreater.optionStrings["autoloot behaviour choices"]			= {"Copie a configuração nas configurações de jogo "," Autoloot "," Never Autoloot"} --= {"Copy the setting under the Gameplay settings", "Autoloot", "Never Autoloot"}
WritCreater.optionStrings["container delay"]					= "Atraso para abrir de contêineres"
WritCreater.optionStrings["container delay tooltip"]			= "Atrasa a abertura automática de contêineres de recompensa"
WritCreater.optionStrings["hide when done"]						= "Ocultar quando terminado" --= "Hide when done"
WritCreater.optionStrings["hide when done tooltip"]				= "Esconder a janela do plugin quando todos os itens forem criados" --= "Hide the addon window when all items have been crafted"
WritCreater.optionStrings['reticleColour']						= "Mudar a cor da retícula" --= "Change Reticle Colour"
WritCreater.optionStrings['reticleColourTooltip']				= "Mude a cor da retícula se você tiver um pedido incompleto ou concluído na estação" --= "Changes the Reticle colour if you have an uncompleted or completed writ at the station"
WritCreater.optionStrings['autoCloseBank']								= "Sair automaticamente do Banco"
WritCreater.optionStrings['autoCloseBankTooltip']						= "Saia automaticamente do banco quando todos os itens forem retirados."
WritCreater.optionStrings['dailyResetWarn']								= "Aviso de reinício de Ordens"
WritCreater.optionStrings['dailyResetWarnTooltip']						= "Exibe um aviso quando as Ordens estão prestes a reiniciar diariamente"
WritCreater.optionStrings['dailyResetWarnTime']							= "Minutos antes de reiniciar"
WritCreater.optionStrings['dailyResetWarnTimeTooltip']					= "Quantos minutos antes do reinicio da Ordem de Fabricação diaria deve mostrar a advertência"
WritCreater.optionStrings['dailyResetWarnType']							= "Advertência de reinicio diario "
WritCreater.optionStrings['dailyResetWarnTypeTooltip']					= "Que tipo de aviso deve ser exibido quando a Ordem de Fabricação diária está prestes a ocorrer?"
WritCreater.optionStrings['dailyResetWarnTypeChoices']					= {"Nenhum", "Tipo 1", "Tipo 2", "Tipo 3", "Tipo 4", "Todos"}
WritCreater.optionStrings['stealingProtection']							= "Proteção a roubo"
WritCreater.optionStrings['stealingProtectionTooltip']					= "Impedir que você roube perto de um local de Ordem de Fabricação"
WritCreater.optionStrings['jewelryWritDestroy']							= "Destrua Ordem de Fabricação de Joias"
WritCreater.optionStrings['jewelryWritDestroyTooltip']					= "Destrua Ordem de Fabricação de Joias. AVISO: Sem aviso!"
WritCreater.optionStrings['jewelryWritDestroyWarning']					= "AVISO: Não há nenhum aviso ao destruir Ordem de Fabricação de joias! Ative por sua própria conta e risco!"
WritCreater.optionStrings['noDELETEConfirmJewelry']						= "Destruição fácil de joias"
WritCreater.optionStrings['noDELETEConfirmJewelryTooltip']				= "Adicione automaticamente o texto de confirmação DELETE à caixa de diálogo de exclusão do Jewelry Writ"
WritCreater.optionStrings['suppressQuestAnnouncements']					= "Ocultar anúncios da missão de Ordem de Fabricação"
WritCreater.optionStrings['suppressQuestAnnouncementsTooltip']			= "Esconde o texto no centro da tela quando você inicia um texto ou cria um item para ele"
WritCreater.optionStrings["pet begone"]									= "Oculta o animal"
WritCreater.optionStrings["pet begone tooltip"]							= "Se e quando os animais de estimação devem ser escondidos. Os animais de estimação podem bloquear a interação, mas isso os impedirá de bloquear as interações Para obter os melhores resultados, mantenha-o sempre ativado."
WritCreater.optionStrings["pet begone choices"]							= {" Nunca esconda "," Sempre esconda "," Esconda na busca "}
WritCreater.optionStrings["pet begone warning"]							= "Quando ligado, você verá Pacrooti. Você não verá nenhum outro jogador ou animal de estimação de combate. Se ligar, os jogadores não desaparecerão instantaneamente. Se desligar, eles não reaparecerão instantaneamente. Não se trata de insetos, mas de efeitos colaterais inevitáveis. "
WritCreater.optionStrings["questBuffer"]								= "Buffer de Ordem de Fabricação"
WritCreater.optionStrings["questBufferTooltip"]							= "Mantenha um buffer de missões para que você sempre tenha espaço para ler as Ordens de Fabricação"
WritCreater.optionStrings["craftMultiplier"]							= "Multiplicador de Construção"
WritCreater.optionStrings["craftMultiplierTooltip"]						= "Crie várias cópias de cada item necessário para que você não precise refazê-los na próxima vez que surgir a Ordem de Fabricação. Observação: economize aproximadamente 37 slots para cada aumento acima de 1"
WritCreater.optionStrings["allReward"]									= "Todas as Construções"
WritCreater.optionStrings["allRewardTooltip"]							= "Ação a ser realizada para todos as profissões"
WritCreater.optionStrings['sameForALlCrafts']							= "Use a mesma opção para todos"
WritCreater.optionStrings['sameForALlCraftsTooltip']					= "Use a mesma opção para recompensas deste tipo para todos as profissões"
WritCreater.optionStrings['1Reward']									= "Ferraria"
WritCreater.optionStrings['2Reward']									= "Use para todos"
WritCreater.optionStrings['3Reward']									= "Use para todos"
WritCreater.optionStrings['4Reward']									= "Use para todos"
WritCreater.optionStrings['5Reward']									= "Use para todos"
WritCreater.optionStrings['6Reward']									= "Use para todos"
WritCreater.optionStrings['7Reward']									= "Use para todos"
WritCreater.optionStrings["matsReward"]									= "Materiais de recompensas"
WritCreater.optionStrings["matsRewardTooltip"]							= "O que fazer com as recompensas materiais"
WritCreater.optionStrings["surveyReward"]								= "Recompensas das pesquisas"
WritCreater.optionStrings["surveyRewardTooltip"]						= "O que fazer com as recompensas das pesquisas"
WritCreater.optionStrings["masterReward"]								= "Recompensas Mestre da Ordem de Fabricação"
WritCreater.optionStrings["masterRewardTooltip"]						= "O que fazer com as recompensas Mestre da Ordem de Fabricação"
WritCreater.optionStrings["repairReward"]								= "Recompensas do kit de reparo"
WritCreater.optionStrings["repairRewardTooltip"]						= "O que fazer com as recompensas do kit de reparo"
WritCreater.optionStrings["ornateReward"]								= "Recompensas de equipamento ornamentado"
WritCreater.optionStrings["ornateRewardTooltip"]						= "O que fazer com as recompensas de ornamentado"
WritCreater.optionStrings["intricateReward"]							= "Recompensas de equipamento intrincadas"
WritCreater.optionStrings["intricateRewardTooltip"]						= "O que fazer com as recompensas de equipamento intrincadas"
WritCreater.optionStrings["soulGemReward"]								= "Joias da alma vazia"
WritCreater.optionStrings["soulGemTooltip"]								= "O que fazer com as joias da alma vazia"
WritCreater.optionStrings["glyphReward"]								= "Glifos"
WritCreater.optionStrings["glyphRewardTooltip"]							= "O que fazer com os Glifos"
WritCreater.optionStrings["recipeReward"]								= "Receitas"
WritCreater.optionStrings["recipeRewardTooltip"]						= "o que fazer com as receitas"
WritCreater.optionStrings["fragmentReward"]								= "Fragmentos Psijicos"
WritCreater.optionStrings["fragmentRewardTooltip"]						= "O que fazer com Fragmentos Psijicos"
WritCreater.optionStrings["writRewards submenu"]						= "Recompensa da ordem de fabricação por escrita"
WritCreater.optionStrings["writRewards submenu tooltip"]				= "o que fazer com todos as recompensas das Ordens de Fabricão"
WritCreater.optionStrings["jubilee"]									= "Abrir Caixa de Aniversário" 
WritCreater.optionStrings["jubilee tooltip"]							= "Abrir Automaticamente Caixas de Aniversário"
WritCreater.optionStrings["rewardChoices"]								= {"Nada","Depositar","Junk", "Destruir"}
WritCreater.optionStrings["alternate universe"] = "Desativar piadas de 1º de abril" --WritCreater.optionStrings["alternate universe"] = "Turn off April"
WritCreater.optionStrings["alternate universe tooltip"] = "Desativa a renomeação de estações de artesanato, artesanato e outros itens interativos" --WritCreater.optionStrings["alternate universe tooltip"] = "Turn off the renaming of crafts, crafting stations, and other interactables"

function WritCreater.langWritRewardBoxes () return
{
	[1] = "Recipiente de alquimista", --"Alchemist's Vessel",
	[2] = "Cofre do encantador", --"Enchanter's Coffer",
	[3] = "Pacote de culinária", --"Provisioner's Pack",
	[4] = "Caixa de ferreiro", --"Blacksmith's Crate",
	[5] = "Sacola de alfaiate", --"Clothier's Satchel",
	[6] = "Estojo de marceneiro", --"Woodworker's Case",
	[7] = "Cofre de joalheria", --"Jewelry Crafter's Coffer",
	[8] = "Remessa", --"Shipment",
}

end

function WritCreater.getTaString()
	return "ta"
end

WritCreater.lang = "br" --EDITADO WritCreater.lang = "en"
WritCreater.langIsMasterWritSupported = true



findMissingTranslationsMetatable["__newindex"] = function(t,k,v)WritCreater.missingTranslations[k] = nil rawset(t,k,v)  end
ZO_CreateStringId("SI_BINDING_NAME_WRIT_CRAFTER_CRAFT_ITEMS", "Craft items")
																		-- CSA, ZO_Alert, chat message, window

