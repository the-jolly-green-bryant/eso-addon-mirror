--[[
Addon:    DuelRPG - Gestion avancée des combats JDR
Author:   @neferys
File:     DuelRPGdef.lua
]]--

-- DuelRPG Declaration
if DuelRPG == nil then DuelRPG = {} end

function DuelRPG.GetLanguage()
	local language = GetCVar("language.2")

	if(language == "en" or language == "fr") then return language end

	return "en"
end

DuelRPG.raceTable = {
   ["Breton"] = "breton",
   ["Bretone"] = "breton", --de, male
   ["Bretonin"] = "breton", --de, female
   ["Bréton"] = "breton", --fr, male
   ["Brétonne"] = "breton", --fr, female
   ["Orc"] = "orc",
   ["Ork"] = "orc", --de, male/female
   ["Orque"] = "orc", --fr, male/female
   ["Redguard"] = "redguard",
   ["Rothwardone"] = "redguard", --de, male
   ["Rothwardonin"] = "redguard", --de, female
   ["Rougegarde"] = "redguard", --fr, male/female
   ["High Elf"] = "altmer",
   ["Hochelf"] = "altmer", --de, male
   ["Hochelfin"] = "altmer", --de, female
   ["Haut-Elfe"] = "altmer", --fr, male
   ["Haute-Elfe"] = "altmer", --fr, female
   ["Wood Elf"] = "bosmer",
   ["Waldelf"] = "bosmer", --de, male
   ["Waldelfin"] = "bosmer", --de, female
   ["Elfe des bois"] = "bosmer", --fr, male/female
   ["Khajiit"] = "khajiit",
   ["Argonian"] = "argonian",
   ["Argonier"] = "argonian", --de, male
   ["Argonierin"] = "argonian", --de, female
   ["Argonien"] = "argonian", --fr, male
   ["Argonienne"] = "argonian", --fr, female
   ["Dark Elf"] = "dunmer",
   ["Dunkelelf"] = "dunmer", --de, male
   ["Dunkelelfin"] = "dunmer", --de, female
   ["Elfe Noir"] = "dunmer", --fr, male
   ["Elfe Noire"] = "dunmer", --fr, female
   ["Nord"] = "nord",
   ["Nordique"] = "nord", --fr, male/female
   ["Imperial"] = "imperial",
   ["Kaiserlicher"] = "imperial", --de, male
   ["Kaiserliche"] = "imperial", --de, female
   ["Impérial"] = "imperial", --fr, male
   ["Impériale"] = "imperial", --fr, female
}

DuelRPG.CAN_RESEARCH_RACES = {
	["altmer"] = {
		cacrace = -1,
		magrace = 1,
		disrace = 0,
		dexrace = 0,
		endrace = 0
	},
	["argonian"] =  {
		cacrace = 0,
		magrace = 0,
		disrace = 0,
		dexrace = 1,
		endrace = -1
	},
	["bosmer"] = {
		cacrace = -1,
		magrace = 0,
		disrace = 1,
		dexrace = 1,
		endrace = -1
	},
	["breton"] = {
		cacrace = -1,
		magrace = 1,
		disrace = 0,
		dexrace = 0,
		endrace = 0
	},
	["dunmer"] = {
		cacrace = 1,
		magrace = 1,
		disrace = -1,
		dexrace = 0,
		endrace = -1
	},
	["imperial"] = {
		cacrace = 0,
		magrace = 0,
		disrace = 0,
		dexrace = 0,
		endrace = 0
	},
	["khajiit"] = {
		cacrace = 0,
		magrace = 0,
		disrace = 0,
		dexrace = 1,
		endrace = -1
	},
	["nord"] = {
		cacrace = 1,
		magrace = -1,
		disrace = -1,
		dexrace = 0,
		endrace = 1
	},
	["orc"] = {
		cacrace = 1,
		magrace = 0,
		disrace = -1,
		dexrace = -1,
		endrace = 1
	},
	["redguard"] = {
		cacrace = 1,
		magrace = -1,
		disrace = -1,
		dexrace = 0,
		endrace = 1
	}
}

function DuelRPG.GetLevelAttr(value)

	if value == 1 then return 0 end
	if value == 2 then return 1 end
	if value == 3 then return 2 end
	if value == 4 then return 3 end
	if value == 5 then return 4 end
	if value == 6 then return 5 end
	if value == 7 then return 6 end
	if value == 8 then return 7 end
	if value == 9 then return 8 end
	if value == 10 then return 9 end
	
end

function DuelRPG.GetAttrCostIndAdd(value)

	if value + 10 == 8 then return -2 end
	if value + 10 == 9 then return -1 end
	if value + 10 == 10 then return -1 end
	if value + 10 == 11 then return -1 end
	if value + 10 == 12 then return -1 end
	if value + 10 == 13 then return -1 end
	if value + 10 == 14 then return -2 end
	if value + 10 == 15 then return -2 end
	if value + 10 == 16 then return -3 end
	if value + 10 == 17 then return -3 end
	if value + 10 == 18 then return -4 end
	
end

function DuelRPG.GetAttrCostCum(value)

	if value + 10 == 7 then return 4 end
	if value + 10 == 8 then return 2 end
	if value + 10 == 9 then return 1 end
	if value + 10 == 10 then return 0 end
	if value + 10 == 11 then return -1 end
	if value + 10 == 12 then return -2 end
	if value + 10 == 13 then return -3 end
	if value + 10 == 14 then return -5 end
	if value + 10 == 15 then return -7 end
	if value + 10 == 16 then return -10 end
	if value + 10 == 17 then return -13 end
	if value + 10 == 18 then return -17 end
	
end

function DuelRPG.Calcul_multi(value)

	if value == 6 or value == 7 then return -2 end
	if value == 8 or value == 9 then return -1 end
	if value == 10 or value == 11 then return 0 end
	if value == 12 or value == 13 then return 1 end
	if value == 14 or value == 15 then return 2 end
	if value == 16 or value == 17 then return 3	end
	if value == 18 or value == 19 then return 4 end

end
	
DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_ARMOR = {
	["Sans armure"] = {
		defearmor = 0
	},
	["Armure légère"] =  {
		defearmor = 1
	},
	["Armure intermédiaire"] = {
		defearmor = 3
	},
	["Armure lourde"] = {
		defearmor = 6
	}
}

DuelRPG.CAN_RESEARCH_COMBATS_OPTIONS_WEAPON = {
	["Main nue"] = {
		armoweapon = 0,
		damaweapon = 1,
		typeweapon = 1,
		nbhaweapon = 1
	},
	["Dague"] =  {
		armoweapon = 0,
		damaweapon = 4,
		typeweapon = 1,
		nbhaweapon = 1
	},
	["Bâton"] =  {
		armoweapon = 0,
		damaweapon = 6,
		typeweapon = 1,
		nbhaweapon = 2
	},
	["Epée"] =  {
		armoweapon = 0,
		damaweapon = 6,
		typeweapon = 1,
		nbhaweapon = 1
	},
	["Arc"] = {
		armoweapon = 0,
		damaweapon = 12,
		typeweapon = 2,
		nbhaweapon = 2
	},
	["Bouclier"] = {
		armoweapon = 2,
		damaweapon = 0,
		typeweapon = 0,
		nbhaweapon = 1
	},
	["Marteau"] = {
		armoweapon = 0,
		damaweapon = 6,
		typeweapon = 1,
		nbhaweapon = 1
	},
	["Hache"] = {
		armoweapon = 0,
		damaweapon = 6,
		typeweapon = 1,
		nbhaweapon = 1
	},
	["Epée à deux mains"] = {
		armoweapon = 0,
		damaweapon = 12,
		typeweapon = 1,
		nbhaweapon = 2
	},
	["Hache à deux mains"] = {
		armoweapon = 0,
		damaweapon = 12,
		typeweapon = 1,
		nbhaweapon = 2
	},
	["Marteau à deux mains"] = {
		armoweapon = 0,
		damaweapon = 12,
		typeweapon = 1,
		nbhaweapon = 2
	}
}
