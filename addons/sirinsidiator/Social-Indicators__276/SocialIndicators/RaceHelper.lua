-- adopted from Garkin's race table (http://www.esoui.com/forums/showthread.php?t=2014)
local RACE_NAMES = {
	["en"] = {
		[GENDER_MALE] = {
			[1] = "Breton",
			[2] = "Redguard",
			[3] = "Orc",
			[4] = "Dark Elf",
			[5] = "Nord",
			[6] = "Argonian",
			[7] = "High Elf",
			[8] = "Wood Elf",
			[9] = "Khajiit",
			[10] = "Imperial",
		},
		[GENDER_FEMALE] = {}
	},
	["de"] = {
		[GENDER_MALE] = {
			[1] = "Bretone",
			[2] = "Rothwardone",
			[3] = "Ork",
			[4] = "Dunkelelf",
			[6] = "Argonier",
			[7] = "Hochelf",
			[8] = "Waldelf",
			[10] = "Kaiserlicher",
		},
		[GENDER_FEMALE] = {
			[1] = "Bretonin",
			[2] = "Rothwardonin",
			[4] = "Dunkelelfin",
			[6] = "Argonierin",
			[7] = "Hochelfin",
			[8] = "Waldelfin",
			[10] = "Kaiserliche",
		}
	},
	["fr"] = {
		[GENDER_MALE] = {
			[1] = "Bréton",
			[2] = "Rougegarde",
			[3] = "Orque",
			[4] = "Elfe Noir",
			[5] = "Nordique",
			[6] = "Argonien",
			[7] = "Haut-Elfe",
			[8] = "Elfe des bois",
			[10] = "Impérial",
		},
		[GENDER_FEMALE] = {
			[1] = "Brétonne",
			[4] = "Elfe Noire",
			[6] = "Argonienne",
			[7] = "Haute-Elfe",
			[10] = "Impériale",
		}
	}
}

local DEFAULT_RACE_NAMES = RACE_NAMES["en"]
local CURRENT_RACE_NAMES = RACE_NAMES[GetCVar("language.2")]

local RACE_ID_TO_IDENTIFIER = {
	[1] = "breton",
	[2] = "redguard",
	[3] = "orc",
	[4] = "dunmer",
	[5] = "nord",
	[6] = "argonian",
	[7] = "altmer",
	[8] = "bosmer",
	[9] = "khajiit",
	[10] = "imperial",
}

local RACE_NAME_TO_ID = {}
for _, raceNamesForLanguage in pairs(RACE_NAMES) do
	for _, raceNamesForGender in pairs(raceNamesForLanguage) do
		for raceId, raceName in pairs(raceNamesForGender) do
			RACE_NAME_TO_ID[raceName] = raceId
		end
	end
end

local function GetRaceIdentifier(raceId)
	return RACE_ID_TO_IDENTIFIER[raceId]
end

local function GetRaceName(raceId, gender)
	return CURRENT_RACE_NAMES[gender][raceId] or CURRENT_RACE_NAMES[GENDER_MALE][raceId] or DEFAULT_RACE_NAMES[GENDER_MALE][raceId] or ""
end

local function GetRaceIcon(raceId)
	return "esoui/art/charactercreate/charactercreate_" ..  RACE_ID_TO_IDENTIFIER[raceId] .. "icon_up.dds"
end

SocialIndicators.GetUnitRaceId = GetUnitRaceId
SocialIndicators.GetRaceIdentifier = GetRaceIdentifier
SocialIndicators.GetRaceName = GetRaceName
SocialIndicators.GetRaceIcon = GetRaceIcon
