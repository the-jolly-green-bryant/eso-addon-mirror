languageTable = {}

function languageTable.CreateZoneToRegionEmotesTable()
	languageTable.zoneToRegionEmotes = {
		["Auridon"] = LorePlay.defaultEmotesByRegion["ad1"],
		["Grahtwood"] = LorePlay.defaultEmotesByRegion["ad2"],
		["Greenshade"] = LorePlay.defaultEmotesByRegion["ad2"],
		["Khenarthi's Roost"] = LorePlay.defaultEmotesByRegion["ad1"],
		["Malabal Tor"] = LorePlay.defaultEmotesByRegion["ad2"],
		["Reaper's March"] = LorePlay.defaultEmotesByRegion["ad2"],
		["Alik'r Desert"] = LorePlay.defaultEmotesByRegion["dc1"],
		["Bangkorai"] = LorePlay.defaultEmotesByRegion["dc1"],
		["Betnikh"] = LorePlay.defaultEmotesByRegion["dc2"],
		["Glenumbra"] = LorePlay.defaultEmotesByRegion["dc2"],
		["Rivenspire"] = LorePlay.defaultEmotesByRegion["dc2"],
		["Stormhaven"] = LorePlay.defaultEmotesByRegion["dc2"],
		["Stros M'Kai"] = LorePlay.defaultEmotesByRegion["dc1"],
		["Bal Foyen"] = LorePlay.defaultEmotesByRegion["ep2"],
		["Bleakrock Isle"] = LorePlay.defaultEmotesByRegion["ep2"],
		["Deshaan"] = LorePlay.defaultEmotesByRegion["ep2"],
		["Eastmarch"] = LorePlay.defaultEmotesByRegion["ep1"],
		["The Rift"] = LorePlay.defaultEmotesByRegion["ep1"],
		["Shadowfen"] = LorePlay.defaultEmotesByRegion["ep3"],
		["Stonefalls"] = LorePlay.defaultEmotesByRegion["ep2"],
		["Coldharbour"] = LorePlay.defaultEmotesByRegion["ch"],
		["Craglorn"] = LorePlay.defaultEmotesByRegion["other"],
		["Cyrodiil"] = LorePlay.defaultEmotesByRegion["ip"],
		["Gold Coast"] = LorePlay.defaultEmotesByRegion["other"],
		["Hew's Bane"] = LorePlay.defaultEmotesByRegion["other"],
		["Murkmire"] = LorePlay.defaultEmotesByRegion["ep3"],
		["Bangkorai"] = LorePlay.defaultEmotesByRegion["dc1"],
		["Wrothgar"] = LorePlay.defaultEmotesByRegion["other"],
		["Vvardenfell"] = LorePlay.defaultEmotesByRegion["ep1"],
	}
end


function languageTable.CreatePlayerTitles()
	languageTable.playerTitles = {
		["Emperor"] = "Emperor",
		["Empress"] = "Empress",
		["Former Emperor"] = "Former Emperor",
		["Former Empress"] = "Former Empress",
		["Ophidian Overlord"] = "Ophidian Overlord",
		["Savior of Nirn"] = "Savior of Nirn",
		["Daedric Lord Slayer"] = "Daedric Lord Slayer",
		["Tamriel Hero"] = "Tamriel Hero",
		["Maelstrom Arena Champion"] = "Maelstrom Arena Champion",
		["Dragonstar Arena Champion"] = "Dragonstar Arena Champion",
		["The Flawless Conqueror"] = "The Flawless Conqueror",
		["Stormproof"] = "Stormproof",
	}
end


function languageTable.CreateEmotesByCityTable()
	local defaultCityToRegionEmotes = {
		["AD"] = {
			[1] = 177,
			[2] = 174,
			[3] = 202,
			[4] = 99,
			[5] = 8,
			[6] = 52,
			[7] = 184,
			[8] = 5,
			[9] = 6,
			[10] = 7,
			[11] = 72,
			[12] = 72,
			[13] = 182,
			[14] = 187,
			[15] = 52,
			[16] = 8,
			[17] = 79
		},
		["EP"] = {
			[1] = 174,
			[2] = 8,
			[3] = 52,
			[4] = 7,
			[5] = 203,
			[6] = 169,
			[7] = 121,
			[8] = 185,
			[9] = 5,
			[10] = 6,
			[11] = 72,
			[12] = 72,
			[13] = 188,
			[14] = 183,
			[15] = 100,
			[16] = 8,
			[17] = 79
		},
		["DC"] = {
			[1] = 25,
			[2] = 52,
			[3] = 201,
			[4] = 11,
			[5] = 6,
			[6] = 122,
			[7] = 91,
			[8] = 38,
			[9] = 9,
			[10] = 72,
			[11] = 95,
			[12] = 7,
			[13] = 181,
			[14] = 5,
			[15] = 189,
			[16] = 190,
			[17] = 8,
			[18] = 79
		},
		["Other"] = {
			[1] = 177,
			[2] = 8,
			[3] = 72,
			[4] = 72,
			[5] = 52,
			[6] = 5,
			[7] = 6,
			[8] = 7,
			[9] = 211,
			[10] = 100,
			[11] = 8,
			[12] = 79
		}
	}


	languageTable.defaultEmotesByCity = {
		["Elden Root"] = {
			["Emotes"] = {
				[1] = 203,
				[2] = 203,
				[3] = 203,
				[4] = 203,
				[5] = 177,
				[6] = 174,
				[7] = 202,
				[8] = 99,
				[9] = 8,
				[10] = 52,
				[11] = 184,
				[12] = 5,
				[13] = 6,
				[14] = 7,
				[15] = 79,
				[16] = 8
			}
		},
		["Vulkhel Guard"] = { 
			["Emotes"] = {
				[1] = 174,
				[2] = 8,
				[3] = 38,
				[4] = 191,
				[5] = 210,
				[6] = 11,
				[7] = 121,
				[8] = 52,
				[9] = 9,
				[10] = 91,
				[11] = 182,
				[12] = 5,
				[13] = 6,
				[14] = 7,
				[15] = 79,
				[16] = 8
			}
		},
		["Mournhold"] = {
			["Emotes"] = {
				[1] = 174,
				[2] = 8,
				[3] = 52,
				[4] = 52,
				[5] = 203,
				[6] = 203,
				[7] = 121,
				[8] = 185,
				[9] = 5,
				[10] = 6,
				[11] = 7,
				[12] = 79,
				[13] = 8
			}
		},
		["Windhelm"] = { 
			["Emotes"] = {
				[1] = 8,
				[2] = 139,
				[3] = 163,
				[4] = 169,
				[5] = 5,
				[6] = 79,
				[7] = 209,
				[8] = 64,
				[9] = 174,
				[10] = 52,
				[11] = 188,
				[12] = 6,
				[13] = 7,
				[14] = 8
			}
		},
		["Riften"] = { 
			["Emotes"] = {
				[1] = 8,
				[2] = 139,
				[3] = 163,
				[4] = 169,
				[5] = 5,
				[6] = 79,
				[7] = 209,
				[8] = 64,
				[10] = 52,
				[11] = 188,
				[12] = 6,
				[13] = 7,
				[14] = 8
			}
		},
		["Wayrest"] = {
			["Emotes"] = {
				[1] = 25,
				[2] = 52,
				[3] = 201,
				[4] = 11,
				[5] = 110,
				[6] = 122,
				[7] = 91,
				[8] = 38,
				[9] = 9,
				[10] = 91,
				[11] = 95,
				[12] = 95,
				[13] = 203,
				[14] = 203,
				[15] = 181,
				[16] = 5,
				[17] = 6,
				[18] = 7,
				[19] = 8,
				[20] = 79
			}
		},
		["Abah's Landing"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Aldcroft"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Anvil"] = { 
			["Emotes"] = defaultCityToRegionEmotes["Other"]
		},
		["Arenthia"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Baandari Trading Post"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Baandari Post Wayshrine"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Belkarth"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Camlorn"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Clockwork City"] = { 
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Daggerfall"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Daggerfall Castle Town"] = {
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Daggerfall Harbor District"] = {
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Daggerfall Trade District"] = {
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Castle Daggerfall"] = {
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Davon's Watch"] = { 
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Dune"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Ebonheart"] = { 
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Elinhir"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Evermore"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Firsthold"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Hallin's Stand"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Haven"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Hollow City"] = { 
			["Emotes"] = defaultCityToRegionEmotes["Other"]
		},
		["The Hollow City"] = { 
			["Emotes"] = defaultCityToRegionEmotes["Other"]
		},
		["Imperial City"] = { 
			["Emotes"] = defaultCityToRegionEmotes["Other"]
		},
		["Kozanset"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Kragenmoor"] = { 
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Kvatch"] = { 
			["Emotes"] = defaultCityToRegionEmotes["Other"]
		},
		["Marbruk"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Mistral"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Northpoint"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Orsinium"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Port Hunding"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Rawl'kha"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Sentinel"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Shornhelm"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Silvenar"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Silvenar's Audience Hall"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Stormhold"] = { 
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Tava's Blessing"] = { 
			["Emotes"] = defaultCityToRegionEmotes["DC"]
		},
		["Skywatch"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Woodhearth"] = { 
			["Emotes"] = defaultCityToRegionEmotes["AD"]
		},
		["Vivec City"] = {
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Seyda Neen"] = {
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Balmora"] = {
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
		["Sadrith Mora"] = {
			["Emotes"] = defaultCityToRegionEmotes["EP"]
		},
	}

	-- Add Wayshrines
	local temp = {}
	for i,v in pairs(languageTable.defaultEmotesByCity) do
		local cityWayshrine = i.." Wayshrine"
		temp[i] = languageTable.defaultEmotesByCity[i]
		temp[cityWayshrine] = languageTable.defaultEmotesByCity[i]
	end
	languageTable.defaultEmotesByCity = temp

	-- Add special cases, such as name variations
	languageTable.defaultEmotesByCity["Mournhold Plaza of the Gods"] = {
		["Emotes"] = languageTable.defaultEmotesByCity["Mournhold"]["Emotes"]
	}

	languageTable.defaultEmotesByCity["Mournhold Banking District"] = {
		["Emotes"] = languageTable.defaultEmotesByCity["Mournhold"]["Emotes"]
	}

	languageTable.defaultEmotesByCity["Elden Root Services"] = {
		["Emotes"] = languageTable.defaultEmotesByCity["Elden Root"]["Emotes"]
	}

	languageTable.defaultEmotesByCity["Vivec Temple Wayshrine"] = {
		["Emotes"] = languageTable.defaultEmotesByCity["Vivec City"]["Emotes"]
	}
end