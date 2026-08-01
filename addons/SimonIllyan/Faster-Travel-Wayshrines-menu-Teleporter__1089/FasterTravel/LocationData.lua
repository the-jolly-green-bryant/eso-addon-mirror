local Location = FasterTravel.Location
local Utils = FasterTravel.Utils
local Options = FasterTravel.Options

local ALLIANCE_ALL = -2147483646
local ALLIANCE_SHARED = -2147483647
local ALLIANCE_WORLD = -2147483648

local LocationDirection = Options.LocationDirection
local LocationOrder = Options.LocationOrder
local AllWSOrder = Options.AllWSOrder

local _factionZoneOrderLookup = {
	[ALLIANCE_ALDMERI_DOMINION] = {
		"khenarthisroost","auridon","grahtwood","greenshade","malabaltor","reapersmarch",
	},
	[ALLIANCE_DAGGERFALL_COVENANT] = {
		"strosmkai","betnihk","glenumbra","stormhaven","rivenspire","alikr","bangkorai",
	},
	[ALLIANCE_EBONHEART_PACT] = {
		"bleakrock","balfoyen","stonefalls","deshaan","shadowfen","eastmarch","therift",
	},
	[ALLIANCE_ALL] = { "cyrodiil" },
	[ALLIANCE_SHARED] = {
		"coldharbor", "craglorn", "eyevea",
		"imperialcity", "wrothgar", 
		"hewsbane", "goldcoast", 
		"vvardenfell",                              -- Morrowind chapter
		"clockwork", "brassfortress",               -- Clockwork DLC
		"summerset",  "artaeum",                    -- Summerset chapter 
		"murkmire",                                 -- Murkmire DLC 
		"elsweyr",                                  -- Elsweyr chapter
		"southernelsweyr", "tideholm",              -- Dragonhold DLC
		"westernskyrim", "blackreach",              -- Greymoor chapter
		"u28_blackreach", "reach",                  -- Markarth DLC
		"blackwood",                                -- Blackwood chapter
		"u32deadlandszone",
        "u32_fargrave", "u32_theshambles",          -- Deadlands DLC
		"u34_systreszone",                          -- High Isle chapter 
		"galen",                                    -- Firesong DLC
		"u38_telvannipeninsula", "u38_apocrypha",   -- Necrom chapter
		"westwealdoverland",                        -- Gold Road chapter
		--"u42_base_sc_library",						-- The Scholarium
		"solstice",                                 
	},
	[ALLIANCE_WORLD] = { "tamriel", "mundus", }
}

local _factionAllianceOrderLookup = {
	[ALLIANCE_ALDMERI_DOMINION] = {
		ALLIANCE_ALL, ALLIANCE_ALDMERI_DOMINION,
		ALLIANCE_EBONHEART_PACT, ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_SHARED, ALLIANCE_WORLD
	},
	[ALLIANCE_DAGGERFALL_COVENANT] = {
		ALLIANCE_ALL, ALLIANCE_DAGGERFALL_COVENANT, 
		ALLIANCE_ALDMERI_DOMINION, ALLIANCE_EBONHEART_PACT, ALLIANCE_SHARED, ALLIANCE_WORLD
	},
	[ALLIANCE_EBONHEART_PACT] = {
		ALLIANCE_ALL, ALLIANCE_EBONHEART_PACT,
		ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_ALDMERI_DOMINION, ALLIANCE_SHARED, ALLIANCE_WORLD
	}
}

local _factionAllianceIcons = {
	[ALLIANCE_ALDMERI_DOMINION] = "/esoui/art/compass/ava_borderkeep_pin_aldmeri.dds",
	[ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/compass/ava_borderkeep_pin_daggerfall.dds",
	[ALLIANCE_EBONHEART_PACT] = "/esoui/art/compass/ava_borderkeep_pin_ebonheart.dds",
	[ALLIANCE_ALL] = "/esoui/art/compass/ava_3way.dds",
	[ALLIANCE_SHARED] = "/esoui/art/compass/ava_outpost_neutral.dds",
	[ALLIANCE_WORLD] = "/esoui/art/ava/ava_rankicon_palatine.dds"
}

-- generated locations list
local _locationsList = {
	{["subzone"] = "tamriel",				["zone"] = "tamriel",			["mapIndex"] = 1,	["zoneIndex"] = -2147483648,	["name"] = "Tamriel",						["key"] = "tamriel/tamriel",					["tile"] = "art/maps/tamriel/tamriel_0.dds",				},
	{["subzone"] = "glenumbra",				["zone"] = "glenumbra",			["mapIndex"] = 2,	["zoneId"] = 3,					["name"] = "Glenumbra",						["key"] = "glenumbra/glenumbra",				["tile"] = "art/maps/glenumbra/glenumbra_base_0.dds",		},
	{["subzone"] = "rivenspire",			["zone"] = "rivenspire",		["mapIndex"] = 3,	["zoneId"] = 20,				["name"] = "Rivenspire",					["key"] = "rivenspire/rivenspire",				["tile"] = "art/maps/rivenspire/rivenspire_base_0.dds",		},
	{["subzone"] = "stormhaven",			["zone"] = "stormhaven",		["mapIndex"] = 4,	["zoneId"] = 19,				["name"] = "Stormhaven",					["key"] = "stormhaven/stormhaven",				["tile"] = "art/maps/stormhaven/stormhaven_base_0.dds",		},
	{["subzone"] = "alikr",					["zone"] = "alikr",				["mapIndex"] = 5,	["zoneId"] = 104,				["name"] = "Alik'r Desert",					["key"] = "alikr/alikr",						["tile"] = "art/maps/alikr/alikr_base_0.dds",				},
	{["subzone"] = "bangkorai",				["zone"] = "bangkorai",			["mapIndex"] = 6,	["zoneId"] = 92,				["name"] = "Bangkorai",						["key"] = "bangkorai/bangkorai",				["tile"] = "art/maps/bangkorai/bangkorai_base_0.dds",		},
	{["subzone"] = "grahtwood",				["zone"] = "grahtwood",			["mapIndex"] = 7,	["zoneId"] = 383,				["name"] = "Grahtwood",						["key"] = "grahtwood/grahtwood",				["tile"] = "art/maps/grahtwood/grahtwood_base_0.dds",		},
	{["subzone"] = "malabaltor",			["zone"] = "malabaltor",		["mapIndex"] = 8,	["zoneId"] = 58,				["name"] = "Malabal Tor",					["key"] = "malabaltor/malabaltor",				["tile"] = "art/maps/malabaltor/malabaltor_base_0.dds",		},
	{["subzone"] = "shadowfen",				["zone"] = "shadowfen",			["mapIndex"] = 9,	["zoneId"] = 117,				["name"] = "Shadowfen",						["key"] = "shadowfen/shadowfen",				["tile"] = "art/maps/shadowfen/shadowfen_base_0.dds",		},
	{["subzone"] = "deshaan",				["zone"] = "deshaan",			["mapIndex"] = 10,	["zoneId"] = 57,				["name"] = "Deshaan",						["key"] = "deshaan/deshaan",					["tile"] = "art/maps/deshaan/deshaan_base_0.dds",			},
	{["subzone"] = "stonefalls",			["zone"] = "stonefalls",		["mapIndex"] = 11,	["zoneId"] = 41,				["name"] = "Stonefalls",					["key"] = "stonefalls/stonefalls",				["tile"] = "art/maps/stonefalls/stonefalls_base_0.dds",		},
	{["subzone"] = "therift",				["zone"] = "therift",			["mapIndex"] = 12,	["zoneId"] = 103,				["name"] = "The Rift",						["key"] = "therift/therift",					["tile"] = "art/maps/therift/therift_base_0.dds",			},
	{["subzone"] = "eastmarch",				["zone"] = "eastmarch",			["mapIndex"] = 13,	["zoneId"] = 101,				["name"] = "Eastmarch",						["key"] = "eastmarch/eastmarch",				["tile"] = "art/maps/eastmarch/eastmarch_base_0.dds",		},
	{["subzone"] = "ava",					["zone"] = "cyrodiil",			["mapIndex"] = 14,	["zoneId"] = 181,				["name"] = "Cyrodiil",						["key"] = "cyrodiil/ava",						["tile"] = "art/maps/cyrodiil/ava_whole_0.dds",				},
	{["subzone"] = "auridon",				["zone"] = "auridon",			["mapIndex"] = 15,	["zoneId"] = 381,				["name"] = "Auridon",						["key"] = "auridon/auridon",					["tile"] = "art/maps/auridon/auridon_base_0.dds",			},
	{["subzone"] = "greenshade",			["zone"] = "greenshade",		["mapIndex"] = 16,	["zoneId"] = 108,				["name"] = "Greenshade",					["key"] = "greenshade/greenshade",				["tile"] = "art/maps/greenshade/greenshade_base_0.dds",		},
	{["subzone"] = "reapersmarch",			["zone"] = "reapersmarch",		["mapIndex"] = 17,	["zoneId"] = 382,				["name"] = "Reaper's March",				["key"] = "reapersmarch/reapersmarch",			["tile"] = "art/maps/reapersmarch/reapersmarch_base_0.dds",	},
	{["subzone"] = "balfoyen",				["zone"] = "stonefalls",		["mapIndex"] = 18,	["zoneId"] = 281,				["name"] = "Bal Foyen",						["key"] = "stonefalls/balfoyen",				["tile"] = "art/maps/stonefalls/balfoyen_base_0.dds",		},
	{["subzone"] = "strosmkai",				["zone"] = "glenumbra",			["mapIndex"] = 19,	["zoneId"] = 534,				["name"] = "Stros M'Kai",					["key"] = "glenumbra/strosmkai",				["tile"] = "art/maps/Glenumbra/strosmkai_base_0.dds",		},
	{["subzone"] = "betnihk",				["zone"] = "glenumbra",			["mapIndex"] = 20,	["zoneId"] = 535,				["name"] = "Betnikh",						["key"] = "glenumbra/betnihk",					["tile"] = "art/maps/Glenumbra/betnihk_base_0.dds",			},
	{["subzone"] = "khenarthisroost",		["zone"] = "auridon",			["mapIndex"] = 21,	["zoneId"] = 537,				["name"] = "Khenarthi's Roost",				["key"] = "auridon/khenarthisroost",			["tile"] = "art/maps/auridon/khenarthisroost_base_0.dds",	},
	{["subzone"] = "bleakrock",				["zone"] = "stonefalls",		["mapIndex"] = 22,	["zoneId"] = 280,				["name"] = "Bleakrock Isle",				["key"] = "stonefalls/bleakrock",				["tile"] = "art/maps/stonefalls/bleakrock_base_0.dds",		},
	{["subzone"] = "coldharbour",			["zone"] = "coldharbor",		["mapIndex"] = 23,	["zoneId"] = 347,				["name"] = "Coldharbour",					["key"] = "coldharbor/coldharbour",				["tile"] = "art/maps/coldharbor/coldharbour_base_0.dds",	},
	{["subzone"] = "mundus",				["zone"] = "tamriel",			["mapIndex"] = 24,	["zoneIndex"] = -2147483648,	["name"] = "The Aurbis",					["key"] = "tamriel/mundus",						["tile"] = "art/maps/tamriel/mundus_base_0.dds",			},
	{["subzone"] = "craglorn",				["zone"] = "craglorn",			["mapIndex"] = 25,	["zoneId"] = 888,				["name"] = "Craglorn",						["key"] = "craglorn/craglorn",					["tile"] = "art/maps/craglorn/craglorn_base_0.dds",			},
	{["subzone"] = "imperialcity",			["zone"] = "cyrodiil",			["mapIndex"] = 26,	["zoneId"] = 584,				["name"] = "Imperial City",					["key"] = "cyrodiil/imperialcity",				["tile"] = "art/maps/cyrodiil/imperialcity_base_0.dds",		},
	{["subzone"] = "wrothgar",				["zone"] = "wrothgar",			["mapIndex"] = 27,	["zoneId"] = 684,				["name"] = "Wrothgar",						["key"] = "wrothgar/wrothgar",					["tile"] = "art/maps/wrothgar/wrothgar_base_0.dds",			},
	{["subzone"] = "hewsbane",				["zone"] = "thievesguild",		["mapIndex"] = 28,	["zoneId"] = 816,				["name"] = "Hew's Bane",					["key"] = "thievesguild/hewsbane",				["tile"] = "art/maps/thievesguild/hewsbane_base_0.dds",		},
	{["subzone"] = "goldcoast",				["zone"] = "darkbrotherhood",	["mapIndex"] = 29,	["zoneId"] = 823,				["name"] = "Gold Coast",					["key"] = "darkbrotherhood/goldcoast",			["tile"] = "art/maps/darkbrotherhood/goldcoast_base_0.dds",	},
	{["subzone"] = "vvardenfell",			["zone"] = "vvardenfell",		["mapIndex"] = 30,	["zoneId"] = 849,				["name"] = "Vvardenfell",					["key"] = "vvardenfell/vvardenfell",			["tile"] = "art/maps/vvardenfell/vvardenfell_base_0.dds",	},
	{["subzone"] = "clockwork",				["zone"] = "clockwork",			["mapIndex"] = 31,	["zoneId"] = 980,				["name"] = "Clockwork City",				["key"] = "clockwork/clockwork",				["tile"] = "art/maps/clockwork/clockwork_base_0.dds",		},
	{["subzone"] = "brassfortress",			["zone"] = "clockwork",			["mapIndex"] = 31,	["zoneId"] = 981,				["name"] = "The Brass Fortress",			["key"] = "clockwork/brassfortress",			["tile"] = "art/maps/clockwork/brassfortress_base_0.dds",	},
	{["subzone"] = "summerset",				["zone"] = "summerset",			["mapIndex"] = 32,	["zoneId"] = 1011,				["name"] = "Summerset",						["key"] = "summerset/summerset",				["tile"] = "art/maps/summerset/summerset_base_0.dds",		},
	{["subzone"] = "artaeum",				["zone"] = "summerset",			["mapIndex"] = 33,	["zoneId"] = 1027,				["name"] = "Artaeum",						["key"] = "summerset/artaeum",					["tile"] = "art/maps/summerset/artaeum_base_0.dds",			},
	{["subzone"] = "murkmire",				["zone"] = "murkmire",			["mapIndex"] = 34,	["zoneId"] = 726,				["name"] = "Murkmire",						["key"] = "murkmire/murkmire",					["tile"] = "art/maps/murkmire/murkmire_base_0.dds",			},
	{["subzone"] = "elsweyr",				["zone"] = "elsweyr",			["mapIndex"] = 35,	["zoneId"] = 1086,				["name"] = "Northern Elsweyr",				["key"] = "elsweyr/elsweyr",					["tile"] = "art/maps/elsweyr/elsweyr_base_0.dds",			},
	{["subzone"] = "southernelsweyr",		["zone"] = "southernelsweyr",	["mapIndex"] = 36,	["zoneId"] = 1133,				["name"] = "Southern Elsweyr",				["key"] = "southernelsweyr/southernelsweyr",	["tile"] = "art/maps/southernelsweyr/southernelsweyr_base_0.dds",},
	{["subzone"] = "tideholm",				["zone"] = "southernelsweyr",	["mapIndex"] = 36,	["zoneId"] = 1146,				["name"] = "Tideholm",						["key"] = "southernelsweyr/tideholm",			["tile"] = "art/maps/southernelsweyr/tideholm_base_0.dds",		},
	{["subzone"] = "westernskyrim",			["zone"] = "skyrim",			["mapIndex"] = 37,	["zoneId"] = 1160,				["name"] = "Western Skyrim",				["key"] = "skyrim/westernskyrim",				["tile"] = "art/maps/skyrim/westernskyrim_base_0.dds",			},
	{["subzone"] = "blackreach",			["zone"] = "skyrim",			["mapIndex"] = 38,	["zoneId"] = 1161,				["name"] = "Blackreach: Greymoor Caverns",	["key"] = "skyrim/blackreach",					["tile"] = "art/maps/skyrim/blackreach_base_0.dds",				},
	{["subzone"] = "blackreach",			["zone"] = "skyrim",			["mapIndex"] = 39,	["zoneId"] = 1191,				["name"] = "Blackreach",					["key"] = "skyrim/blackreach",					["tile"] = "art/maps/skyrim/blackreach_base_0.dds",				},
	{["subzone"] = "u28_blackreach",		["zone"] = "reach",				["mapIndex"] = 40,	["zoneId"] = 1208,				["name"] = "Blackreach: Arkthzand Cavern",	["key"] = "reach/u28_blackreach",				["tile"] = "art/maps/reach/U28_blackreach_base_0.dds",			},
	{["subzone"] = "reach",					["zone"] = "reach",				["mapIndex"] = 41,	["zoneId"] = 1207,				["name"] = "The Reach",						["key"] = "reach/reach",						["tile"] = "art/maps/reach/reach_base_0.dds",					},
	{["subzone"] = "blackwood",				["zone"] = "blackwood",			["mapIndex"] = 42,	["zoneId"] = 1261,				["name"] = "Blackwood",						["key"] = "blackwood/blackwood",				["tile"] = "art/maps/blackwood/blackwood_base_0.dds",			},
	{["subzone"] = "u32_fargrave",			["zone"] = "deadlands",			["mapIndex"] = 43,	["zoneId"] = 1282,				["name"] = "Fargrave",						["key"] = "deadlands/u32_fargrave",				["tile"] = "art/maps/deadlands/u32_fargrave_base_0.dds",		},
	{["subzone"] = "u32deadlands",			["zone"] = "deadlands",			["mapIndex"] = 44,	["zoneId"] = 1286,				["name"] = "The Deadlands",					["key"] = "deadlands/u32deadlandszone",			["tile"] = "art/maps/deadlands/u32deadlandszone_base_0.dds",	},
	{["subzone"] = "u34_systreszone",		["zone"] = "systres",			["mapIndex"] = 45,	["zoneId"] = 1318,				["name"] = "High Isle",						["key"] = "systres/u34_systreszone",			["tile"] = "art/maps/systres/u34_systreszone_base_0.dds",		},
	{["subzone"] = "u32_theshambles",		["zone"] = "deadlands",			["mapIndex"] = 46,	["zoneId"] = 1283,				["name"] = "The Shambles",		            ["key"] = "deadlands/u32_theshambles",			["tile"] = "art/maps/deadlands/u32_theshambles_base_0.dds",		},
	{["subzone"] = "u36_galen",				["zone"] = "galen",				["mapIndex"] = 47,	["zoneId"] = 1383,				["name"] = "Galen and Y'ffelon",			["key"] = "galen/u36_galenzone",				["tile"] = "art/maps/galen/u36_galenzone_base_0.dds",			},
	{["subzone"] = "u38_telvannipeninsula",	["zone"] = "telvanni",			["mapIndex"] = 48,	["zoneId"] = 1414,				["name"] = "Telvanni Peninsula",			["key"] = "telvanni/u38_telvannipeninsula",		["tile"] = "art/maps/telvanni/u38_telvannipeninsula_base_0.dds",},
	{["subzone"] = "u38_apocrypha",			["zone"] = "apocrypha",			["mapIndex"] = 49,	["zoneId"] = 1413,				["name"] = "Apocrypha",						["key"] = "apocrypha/u38_apocrypha",			["tile"] = "art/maps/apocrypha/u38_apocrypha_base_0.dds",		},
	{["subzone"] = "westwealdoverland",		["zone"] = "westweald",			["mapIndex"] = 50,	["zoneId"] = 1443,				["name"] = "West Weald",					["key"] = "westweald/westwealdoverland",		["tile"] = "art/maps/westweald/westwealdoverland_base_0.dds",	},
	--{["subzone"] = "u42_base_sc_library", 	["zone"] = "westweald", 		["mapIndex"] = nil,	["zoneId"] = 1463,				["name"] = "The Scholarium",				["key"] = "westweald/u42_base_sc_library",		["tile"] = "art/maps/westweald/u42_base_sc_library_base_0.dds",	},
	{["subzone"] = "eyevea",			 	["zone"] = "guildmaps", 		["mapIndex"] = 51,	["zoneId"] = 267,				["name"] = "Eyevea",                        ["key"] = "guildmaps/eyevea",        			["tile"] = "art/maps/guildmaps/eyevea_base_0.dds",              },
	{["subzone"] = "solstice",			 	["zone"] = "solstice",	 		["mapIndex"] = 52,	["zoneId"] = 1502,				["name"] = "Solstice",                      ["key"] = "solstice/solstice",        			["tile"] = "art/maps/solstice/solstice.dds",              },
}

for i, map in ipairs(_locationsList) do
	-- initialize missing indices
	if map.zoneIndex == nil then
		map.zoneIndex = GetZoneIndex(map.zoneId)
	end
	-- add localized zone names
	if map.zoneIndex > 0 then
		map.name = Utils.FormatStringCurrentLanguage(GetZoneNameByIndex(map.zoneIndex))
	end
end

local ZONE_INDEX_CYRODIIL = 37

local _locations
local _locationsLookup
local _zoneFactionLookup

local _zoneIdReverseLookup = {}
for zoneIndex=0, GetNumZones() do
    local zoneId = GetZoneId(zoneIndex)
	local zoneName = Utils.FormatStringCurrentLanguage(GetZoneNameById(zoneId))
	_zoneIdReverseLookup[string.lower(zoneName)] = zoneId
end
	
local function GetZoneIdByName(name)
	return _zoneIdReverseLookup[string.lower(name)]
end

local function GetMapZone(path)
	path = path or GetMapTileTexture()
	path = path:lower():gsub('_0.dds', ''):gsub('_whole', ''):gsub('_base' ,'')
	local zone,subzone = string.match(path,"^.-/.-/(.-)/(.+)")
	if zone == nil and subzone == nil then 
		-- splits if path is actually a zone key 
		zone,subzone = string.match(path,"^(.-)/(.-)$")
	end
	return zone,subzone
end

local function GetMapZoneKey(zone,subzone)
	if zone == nil and subzone == nil then 
		zone,subzone = GetMapZone()
	elseif subzone == nil then
		zone,subzone = GetMapZone(zone)
	end
	return table.concat({zone,"/",subzone}),zone,subzone
end

local function GetList()
	if _locations == nil then
		_locations = {}
		for i,loc in ipairs(_locationsList) do
			local l = {}
			local name = loc.name
			l.name = Utils.FormatStringCurrentLanguage(name) -- cache not required as this as the locations list itself is a cache =)
			l.barename = Utils.BareName(name)
			l.key,l.zone,l.subzone = GetMapZoneKey(loc.tile)
			l.mapIndex, l.zoneIndex, l.tile = loc.mapIndex, loc.zoneIndex, loc.tile
			table.insert(_locations, l)
		end
		table.sort(_locations,function(x,y)	return x.name < y.name end)
	end 
	return _locations
end

local function CreateLocationsLookup(locations,func)
	local lookup = {}
	func = func or function(l) return l end 
	local item
	for i,loc in ipairs(locations) do 
		item = func(loc)
		lookup[loc.zoneIndex] = item
		lookup[loc.key] = item
		if lookup[loc.subzone] == nil then 
			lookup[loc.subzone] = item
		elseif lookup[loc.zone] == nil then 
			lookup[loc.zone] = item
		end
	end
	for i,loc in ipairs(locations) do 
		if lookup[loc.zone] == nil then 
			lookup[loc.zone] = lookup[loc.zoneIndex]
		end
	end
	return lookup
end

local function GetLookup()
	if _locationsLookup == nil then
		_locationsLookup = CreateLocationsLookup(GetList())
	end 
	return _locationsLookup
end

local function GetZoneLocation(lookup,zone,subzone)
	local loc
	if type(zone) == "number" then 
		loc = lookup[zone]
		zone = nil 
	end 
	if loc == nil then
		local key,zone,subzone = Location.Data.GetMapZoneKey(zone,subzone)
		-- try by zone/subzone key first
		loc = lookup[key]
		-- subzone next to handle places like khenarthis roost
		if loc == nil then
			loc = lookup[subzone]
		end
		-- then zone to handle locations within main zones which cannot be matched by key e.g coldharbor's hollow city
		if loc == nil then 
			loc = lookup[zone]
		end 
	end 
	-- if zone can't be found, return tamriel
	if loc == nil then 
		loc = lookup["tamriel"]
	end
	return loc
end

local function IsZoneIndexCyrodiil(zoneIndex)
	return zoneIndex == ZONE_INDEX_CYRODIIL
end

local function IsCyrodiil(loc)
	if loc == nil then return end 
	return IsZoneIndexCyrodiil(loc.zoneIndex)
end

local function GetZoneFactionLookup()
	local zoneLookup = GetLookup()
	if _zoneFactionLookup == nil then 
		local lookup = {}
		for faction,zones in pairs(_factionZoneOrderLookup) do
			for i,zone in ipairs(zones) do
				local z = zoneLookup[zone]
				if z == nil then 
					d("nil at", zone)				
				else
					lookup[z] = faction
				end
			end
		end
		_zoneFactionLookup = lookup
	end 
	return _zoneFactionLookup
end 

local function GetZoneFaction(loc)
	local lookup = GetZoneFactionLookup()
	return lookup[loc]
end 

local function GetAllianceZones(alliance, lookup,sortFunc)
	local zones = _factionZoneOrderLookup[alliance]
	zones = Utils.map(zones,function(key) return lookup[key] end)
	if sortFunc ~= nil then 
		table.sort(zones,sortFunc)
	end
	return zones
end

local function IsFactionWorldOrShared(faction)
	return faction == ALLIANCE_SHARED or faction == ALLIANCE_WORLD or faction == ALLIANCE_ALL
end

local function GetFactionOrderedList(faction,lookup,args)
	args = args or {}
	local zoneSortFunc = args.zoneSortFunc
	local allianceSortFunc = args.allianceSortFunc
	local transform = args.transform
	local alliances = Utils.copy(_factionAllianceOrderLookup[faction])
	if allianceSortFunc ~= nil then 
		table.sort(alliances,allianceSortFunc)
	end 
	local list = {}
	local zones
	for i,alliance in ipairs(alliances) do 
		zones = GetAllianceZones(alliance,lookup,zoneSortFunc)
		if transform ~= nil then 
			zones = transform(alliance,zones) or {}
		end 
		Utils.copy(zones,list)
	end
	return list
end

local function GetDirectionValue(direction,x,y)
	-- Cyrodiil sorts before other zones
	if IsZoneIndexCyrodiil(x.zoneIndex) and not IsZoneIndexCyrodiil(y.zoneIndex) then
		return true
	elseif IsZoneIndexCyrodiil(y.zoneIndex) then 
		return false
	elseif direction == LocationDirection.ASCENDING then
		return Utils.BareName(x.name) < Utils.BareName(y.name)
	elseif direction == LocationDirection.DESCENDING then
		return Utils.BareName(y.name) < Utils.BareName(x.name)
	end 
end

local function AddSharedAndWorld(tbl,lookup,sortFunc)
	local shared = GetAllianceZones(ALLIANCE_SHARED,lookup)
	local world = GetAllianceZones(ALLIANCE_WORLD,lookup)
	local newtbl = {}
	Utils.copy(tbl,    newtbl)
	Utils.copy(shared, newtbl)
	Utils.copy(world,  newtbl)
	return newtbl
end

local _locationSortOrder = {
	[LocationOrder.ZONE_NAME] = function(direction,currentFaction)
		local list = Utils.copy(GetList())
		table.sort(list,function(x,y)
			return GetDirectionValue(direction,x,y)
		end)
		return list
	end,
	[LocationOrder.ZONE_LEVEL] = function(direction,currentFaction)
		local lookup = GetLookup()
		local tbl = GetFactionOrderedList(currentFaction, lookup, {
			transform = function(alliance,zones)
				if direction == LocationDirection.DESCENDING and
					not IsFactionWorldOrShared(alliance) and
					alliance ~= ALLIANCE_ALL then 
					return Utils.reverseTable(zones)
				end 
				return zones
			end 
		})
		return tbl
	end
}

local function UpdateLocationOrder(locations,order,...)
	local newList 
	local direction = order % 2
	local sortfunc = _locationSortOrder[order - direction] 
	if sortfunc ~= nil then 
		newList = sortfunc(direction,...)
		if newList ~= nil then
			for i = 1, #locations do
				locations[i] = nil
			end
			for i,v in ipairs(newList) do
				locations[#locations+1] = v 
			end
		end
	end
end

local function GetZoneFactionIcon(loc)
	local faction = GetZoneFaction(loc)
	return _factionAllianceIcons[faction]
end

local Data = {}
Data.ZONE_INDEX_CYRODIIL = ZONE_INDEX_CYRODIIL
Data.GetZoneIdByName = GetZoneIdByName
Data.GetMapZoneKey = GetMapZoneKey
Data.GetList = GetList
Data.GetLookup = GetLookup
Data.GetZoneLocation = GetZoneLocation
Data.IsZoneIndexCyrodiil = IsZoneIndexCyrodiil
Data.IsCyrodiil = IsCyrodiil
Data.GetZoneFaction = GetZoneFaction
Data.GetFactionOrderedList = GetFactionOrderedList
Data.IsFactionWorldOrShared = IsFactionWorldOrShared
Data.LocationOrder = LocationOrder
Data.UpdateLocationOrder = UpdateLocationOrder
Data.GetZoneFactionIcon = GetZoneFactionIcon
FasterTravel.Location.Data = Data
	
	
