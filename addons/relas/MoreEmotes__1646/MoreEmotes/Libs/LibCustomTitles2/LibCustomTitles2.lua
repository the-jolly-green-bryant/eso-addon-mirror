--[[
Author: Ayantir
Filename: LibCustomTitles.lua
Version: 11
]]--

--[[

This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share — copy and redistribute the material in any medium or format
    Adapt — remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial — You may not use the material for commercial purposes.
    ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at : 
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode

Change log (Relas Aryon 3/17/2017:
-Created new subversion, LibCustomTitlesTwo, to allow me to expand upon this code without it being automatically overwritten by previous versions. All credit to Ayantir.
]]--

local libLoaded
local LIB_NAME, VERSION = "LibCustomTitlesTwo", 12
local LibCustomTitlesTwo, oldminor = LibStub:NewLibrary(LIB_NAME, VERSION)

function LibCustomTitlesTwo:Init()
	
	local CT_NO_TITLE = 0
	local CT_TITLE_ACCOUNT = 1
	local CT_TITLE_CHARACTER = 2
	
	-- Default override
	local overriden = {
		en = "Volunteer",
		fr = "Volontaire",
		de = "Freiwillige",
	}

	local customTitles = {
	
		["@Ayantir"] = { -- Dev / EU. v1
			ov = true,
			en = "The Enlightened",
			fr = "Mangeuse de Gâteaux",
			de = "Die Erleuchtete",
		},
		
		["@Baertram"] = { -- Dev / EU. v4
			ov = true,
			en = "Ursa Major",
			fr = "Ursa Major",
			de = "Ursa Major",
		},
		
		["@sirinsidiator"] = { -- Dev / EU. v5
			["Illonia Ithildû"] = {
				ov = true,
				en = "Planeswalker",
				fr = "Arpenteuse de Mondes",
				de = "Weltenwanderer",
			},
			ov = true,
			en = "Absolutely Not Suspicious",
			fr = "Carrément pas suspect",
			de = "Absolut Nicht Verdächtig",
		},
		
		["@Randactyl"] = { -- Dev / NA. v6
			["Vedrasi Rilim"] = {
				ov = true,
				en = "Glorious Leader",
			},
			ov = true,
			en = "No Lollygaggin'",
		},
		
		["@FinchRevolon"] = { -- NA. v8
			ov = true,
			en = "Jane Gobbol",
		},
		
		["@HundorianOfDirt"] = { -- NA. v8
			ov = true,
			en = "Dirt Lord",
		},
		
		["@Ign0tus"] = { -- NA. v8
			["Smudgê"] = {
				ov = true,
				en = "Infiltrator",
			},
			["Nefandus Pravus"] = {
				ov = true,
				en = "Nightlord",
			},
			["Zero Divisor"] = {
				ov = true,
				en = "Executioner",
			},
			ov = true,
			en = "Sweetroll Thief",
		},
		
		["@dOpiate"] = { -- Dev / EU. v8
			["Harmful"] = {
				ov = {en = "Recruit", fr = "Recrue", de = "Rekrutin"},
				en = "The Butcher",
				fr = "Le Boucher",
				de = "Der Metzger",
			},
		},
		
		["@LadyHermione"] = { -- NA v9
			["Lady Hermione Sophia"] = {
				ov = true,
				en = "Know-It-All",
			},
		},
		
		["@Tarsalterror"] = { -- NA v9
			ov = {en = "Enemy of Coldharbour", fr = "Ennemi de Havreglace", de = "Feind Kalthafens"},
			en = "Fancy Man of Cornwood",
		},
		
		["@manavortex"] = { -- EU v10
			["Vivicah Telvanni"] = {
				ov = {en = "Master Wizard", fr = "Maître mage", de = "Meisterin der Zauberei"},
				en = "Archmagister",
				fr = "Archimage",
				de = "Erzmagister",
			},
		},
		
		["@Valorin"] = { -- EU v10
			["Valorin Telvanni"] = {
				ov = {en = "Savior of Nirn", fr = "Sauveur de Nirn", de = "Retter Nirns"},
				en = "Aetherial Blade",
				fr = "Lame Ethérée",
				de = "Ätherklinge",
			},
		},
		
		["@manorin"] = { -- EU v10
			["Foryn Telvanni"] = {
				ov = {en = "Pact Hero", fr = "Héros du Pacte", de = "Held des Paktes"},
				en = "Hero",
				fr = "Héros",
				de = "Helt",
			},
		},
		
		["@Chivana"] = { -- EU v11
			["Chivana"] = {
				ov = true,
				en = "Amazon Queen",
				fr = "Reine Amazone",
				de = "Amazonaskönigin",
			},
		},
		
		["@Mythk"] = { -- NA v11
			ov = {en = "Recruit", fr = "Recrue", de = "Rekrutin"},
			en = "The One and Only",
			fr = "Le Seul et l'Unique",
		},
		
		["@susmitds"] = { -- NA. v11
			["Shadow Kitter"] = {
				ov = true,
				en = "Emperor Slayer",
			},
			["Venom Kitter"] = {
				ov = true,
				en = "Poison Angel",
			},
			["Wind Kitter"] = {
				ov = true,
				en = "Cyclone Walker",
			},
			["Lumina Kitter"] = {
				ov = true,
				en = "Darklight Seeker",
			},
			["Thunder Xyler"] = {
				ov = true,
				en = "Unbound Infinium",
			},
			["Light Xyler"] = {
				ov = true,
				en = "Everglow Hunter",
			},
			["Fire Xyler"] = {
				ov = true,
				en = "Eternal Inferno",
			},
			["Void Xyler"] = {
				ov = true,
				en = "Existential Anomaly",
			},
		},
		
		["@JasminTheSecond"] = { -- EU v11
			["Durac"] = {
				ov = true,
				en = "The Lost",
				fr = "L'égaré",
				de = "Der Verschollene",
			},
		},
		
		["@feyii"] = { -- v12 - Reyne male?
			ov = {en = "Master Wizard", fr = "Maître mage", de = "Meisterin der Zauberei"},
			en = "Uncle Sheo's Second Most Favourite Mortal",
			fr = "Deuxième mortel favori de l'oncle Sheo",
			de = "Onkel Sheo's zweitliebster Sterblicher",
			["Reyne"] = {
				ov = {en = "Dominion Hero", fr = "Héros du Domaine", de = "Held des Dominions"},
				en = "Moon Hallowed",
				fr = "Élu de la Lune",
				de = "Mondgeweihter",
			},
		},
		
		["@Horizon_Seeker"] = { -- v12 -- Should not be pushed
			["Endaros Ilmori"] = {
				ov = true,
				en = "Armiger",
				fr = "Armiger",
				de = "Armiger",
			},
		},
		
		["@Sermon24"] = { -- v12 -- Should not be pushed
			["Tarelith Sero"] = {
				ov = true,
				en = "Armiger",
				fr = "Armiger",
				de = "Armiger",
			},
		},
		
		["@FinchRevolution"] = { -- v12 -- Should not be pushed
			["Elynu Lleryn"] = {
				ov = true,
				en = "Armiger",
				fr = "Armiger",
				de = "Armiger",
			},
			["Blind Old Woman"] = {
				ov = true,
				en = "Marusia Gratus",
				fr = "Marusia Gratus",
				de = "Marusia Gratus",
			},
			["Lorien Loran"] = {
				ov = true,
				en = "Force of Nature",
				fr = "Force of Nature",
				de = "Force of Nature",
			},
			["Ernest the Fishmonger"] = {
				ov = true,
				en = "Fish Whisperer",
				fr = "Fish Whisperer",
				de = "Fish Whisperer",
			},
		},
		
		["@Rickter2049"] = { -- v12
			ov = {en = "Tyro", fr = "Première classe", de = "Tyro"},
			en = "Lord of Requiem",
			fr = "Prince du Requiem",
		},
		
		
		["@Arvs"] = { -- v12
			["Arvs Veleth"] = {
				ov = true,
				en = "Armiger",
				fr = "Armiger",
				de = "Armiger",
			},
			["Brutus Verulus"] = {
				ov = true,
				en = "Colovian Warlord",
			},
		},

		["@wildhoneycomb"] = { -- v12
			["Neluth Valerius"] = {
				ov = true,
				en = "Sparrow",
				fr = "Sparrow",
			},
			["Erienn Larethal"] = {
				ov = true,
				en = "Beekeeper",
				fr = "Beekeeper",
			},
			["Nirah Ereshkigal"] = {
				ov = true,
				en = "Ashlander",
				fr = "Ashlander",
			},
		},
		
		["@BigPapaK8"] = { -- Max
			["Hieronymus Maximus"] = {
				ov = true,
				en = "Gambler",
				fr = "Gambler",
			},
			["Virvyn Beneran"] = {
				ov = true,
				en = "Tailor",
				fr = "Tailor",
			},
			["Zebdusipal Ereshkigal"] = {
				ov = true,
				en = "Ashlander Hunter",
				fr = "Ashlander Hunter",
			},
			["Galms Marys"] = {
				ov = true,
				en = "Shipwright",
				fr = "Shipwright",
			},
		},
		
		["@Sharakor"] = { -- v12
			ov = {en = "Recruit", fr = "Recrue", de = "Rekrutin"},
			en = "High Inquisitor",
			fr = "Haut-Inquisiteur",
			["Nerf Shærakør"] = {
				ov = true,
				en = "King Of Blackwater Blade",
			},
			["Shærrakor"] = {
				ov = true,
				en = "Pharaoh",
			},
			["Daddy Shærakor"] = {
				ov = true,
				en = "Must Nerf Shærakor",
			},
		},
		
		["@panzerfaustn"] = { -- v13
			ov = true,
			en = "Boethiah's Proven",
			fr = "Boethiah's Proven",
		},
		
		["@FoulMurder"] = { -- NA. v13
			["Fevasa Sarano"] = {
				ov = true,
				en = "Debutante",
			},
			["Relas Aryon"] = {
				ov = true,
				en = "Armiger",
			},
			["Redoran Relas Aryon"] = {
				ov = true,
				en = "Armiger",
			},
			["Dirge Baro"] = {
				ov = true,
				en = "Looter",
			},
			["Dremora Kynlurker"] = { -- deprecated
				ov = {en = "Volunteer", fr = "Volontaire", de = "Freiwillige"},
				en = "Servant of Dagon",
			},
			["Dremora Kynlurker"] = {
				ov = {en = "Recruit", fr = "Recrue", de = "Rekrutin"},
				en = "Daedric Servant"
			},
			["Goblin Mystic"] = {
				ov = true,
				en = "Invasive Species",
			},
			["Erur-Hannat Shashmassami"] = {
				ov = true,
				en = "Zealot",
			},
			["Egvir"] = {
				ov = true,
				en = "Strange Little Man",
			},
			["Corcich of Markarth"] = {
				ov = true,
				en = "Reachman",
			},
			["Sehtras Ulven"] = {
				ov = true,
				en = "Commoner",
			},
			["Sadran Urvel"] = {
				ov = true,
				en = "Spellwright",
			},
		},
		
		["@Audens"] = { -- NA. v13
			["Audens Avidius"] = {
				ov = true,
				en = "Battlemage",
			},
			["Tiphys the Helmsman"] = {
				ov = true,
				en = "Stormreeve",
			},
			["Balen Sedrethi"] = {
				ov = true,
				en = "Beastmaster",
			},
		},

		
	}
	
	local lang = GetCVar("Language.2")
	
	local function GetCustomTitleType(displayName, unitName)
		if customTitles[displayName] then
			if customTitles[displayName][unitName] then
				return CT_TITLE_CHARACTER
			end
			return CT_TITLE_ACCOUNT
		end
		return CT_NO_TITLE
	end
	
	local function GetModifiedTitle(originalTitle, displayName, unitName, registerType)
		
		local title = originalTitle
		if registerType == CT_TITLE_CHARACTER then
			if customTitles[displayName][unitName].ov then
				if type(customTitles[displayName][unitName].ov) == "boolean" then
					if originalTitle == overriden[lang] then
						title = customTitles[displayName][unitName][lang] or originalTitle
					end
				elseif originalTitle == customTitles[displayName][unitName].ov[lang] then
					title = customTitles[displayName][unitName][lang] or originalTitle
				end
			end
		elseif registerType == CT_TITLE_ACCOUNT then
			if customTitles[displayName].ov then
				if type(customTitles[displayName].ov) == "boolean" then
					if originalTitle == overriden[lang] then
						title = customTitles[displayName][lang] or originalTitle
					end
				elseif originalTitle == customTitles[displayName].ov[lang] then
					title = customTitles[displayName][lang] or originalTitle
				end
			end
		end
		
		return title
		
	end

	local GetUnitTitle_original = GetUnitTitle
	GetUnitTitle = function(unitTag)
		local unitTitleOriginal = GetUnitTitle_original(unitTag)
		local unitDisplayName = GetUnitDisplayName(unitTag)
		local unitCharacterName = GetUnitName(unitTag)
		local registerType = GetCustomTitleType(unitDisplayName, unitCharacterName)
		if registerType ~= CT_NO_TITLE then
			return GetModifiedTitle(unitTitleOriginal, unitDisplayName, unitCharacterName, registerType)
		end
		return unitTitleOriginal
	end
	
	local GetTitle_original = GetTitle
	GetTitle = function(index)
		local titleOriginal = GetTitle_original(index)
		local displayName = GetDisplayName()
		local characterName = GetUnitName("player")
		local registerType = GetCustomTitleType(displayName, characterName)
		if registerType ~= CT_NO_TITLE then
			return GetModifiedTitle(titleOriginal, displayName, characterName, registerType)
		end
		return titleOriginal
	end

end

local function OnAddonLoaded()
	if not libLoaded then
		libLoaded = true
		local LCC = LibStub('LibCustomTitlesTwo')
		LCC:Init()
		EVENT_MANAGER:UnregisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(LIB_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)