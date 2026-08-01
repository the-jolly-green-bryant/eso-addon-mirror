local customOverrides = {				-- List of quests where we want to override the default Category or Zone
	-- QuestTypes: 0 None; 1 Group; 2 Main; 3 Guild; 4 Crafting; 5 Dungeon; 6 Trial; 7 AVA; 8 Class; 9 ???; 10 AVA Group; 11 AVA Grand; 12 Holiday; 13 Battlground; 14 Prologue; 15 Pledge; 16 Companion; 17 Tribute; 18 Scribing; 19 Favor; 20 Tamriel
	[4964] = {["questType"] = 0, ["zoneName"] = ""},						--Scion of the Blood Matron	None		None
	[4961] = {["questType"] = 0, ["zoneName"] = ""},						--Hircine's Gift			None		None
	[7327] = {["questType"] = 0, ["zoneName"] = ""},						--The Rogue Mage			None		None
	[4345] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(381)},		--The Veil Falls			None		Auridon
	[4066] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(181)},		--Bear Essentials			None		Cyrodiil
	[5321] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(684)},		--A Heart of Brass			None		Wrothgar
	[5328] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(684)},		--Hidden History			None		Wrothgar
	[5520] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(684)},		--Flame of Forge and Fallen	None		Wrothgar
	[4704] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(181)},		--Welcome to Cyrodiil		None		Cyrodiil
	[4722] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(181)},		--Welcome to Cyrodiil		None		Cyrodiil
	[4725] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(181)},		--Welcome to Cyrodiil		None		Cyrodiil	
	[5487] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--City on the Brink			None		Imperial City
	[5493] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--City on the Brink			None		Imperial City
	[5496] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--City on the Brink			None		Imperial City
	[5602] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--City on the Brink			None		Imperial City
	[5473] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Of Brands and Bones		None		Imperial City
	[5477] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--The Watcher in the Walls	None		Imperial City
	[5480] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--The Bleeding Temple		None		Imperial City
	[5482] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--The Sublime Brazier		None		Imperial City
	[5483] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--The Imperial Standard		None		Imperial City
	[5489] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--The Lock and the Legion	None		Imperial City
	[5490] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Knowledge is Power		None		Imperial City
	[5491] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Speaking for the Dead		None		Imperial City
	[5492] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Lifeblood of an Empire	None		Imperial City
	[5495] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Priceless Treasures		None		Imperial City
	[5498] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Historical Accuracy		None		Imperial City
	[5500] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Dousing the Fires			None		Imperial City
	[5501] = {["questType"] = 0, ["zoneName"] = GetZoneNameById(584)},		--Watch Your Step			None		Imperial City
	[5087] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(888)},		--Assaulting the Citadel	Trial		Craglorn
	[5102] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(888)},		--The Mage's Tower			Trial		Craglorn
	[5554] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(816)},		--The Dark Moon's Jaws		Trial		Hew's Bane
	[6000] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(849)},		--To Tel Fyr				Trial		Vvardenfell
	[6193] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1011)},		--Checking on Cloudrest		Trial		Summerset
	[6354] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1086)},		--Sunspire Summons			Trial		Northern Elsweyr
	[6504] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1160)},		--Reinforcement for Kyne's	Trial		Western Skyrim
	[6655] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1261)},		--A Plea from the Flames	Trial		Blackwood
	[6784] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1318)},		--All Hands on Deck			Trial		High Isle
	[7032] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1413)},		--Approaching a Nightmare	Trial		Apocrypha
	[7213] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1443)},		--Aiding the Expedition		Trial		West Weald
	[7307] = {["questType"] = 6, ["zoneName"] = GetZoneNameById(1502)},		--Ossified Bravery			Trial		Solstice
	[7197] = {["questType"] = 18, ["zoneName"] = GetZoneNameById(1463)},	--The Wing of the Indrik	Scribing	The Scholarium
	[7203] = {["questType"] = 18, ["zoneName"] = GetZoneNameById(1463)},	--The Wing of the Dragon	Scribing	The Scholarium
	[7204] = {["questType"] = 18, ["zoneName"] = GetZoneNameById(1463)},	--The Wing of the Netch		Scribing	The Scholarium
	[7217] = {["questType"] = 18, ["zoneName"] = GetZoneNameById(1463)},	--The Wing of the Gryphon	Scribing	The Scholarium
	[7220] = {["questType"] = 18, ["zoneName"] = GetZoneNameById(1463)},	--The Wing of the Crow		Scribing	The Scholarium
}

function JournalQuestLog.GetCustomOverride(questId, questType, zoneName)
	local quest = customOverrides[questId]
	if quest ~= nil then
		questType, zoneName = quest["questType"], quest["zoneName"]
	end
	return questType, zoneName
end