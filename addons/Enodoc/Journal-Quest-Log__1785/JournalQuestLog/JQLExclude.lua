local specialExclude = {				-- List of quests that should be REMOVED for everyone
	-- OLD CRAGLORN QUESTS
	5033,	--The Star-Gazers
	5025,	--The Corrupted Stone
	5069,	--The Warrior's Call
	5116,	--Elemental Army
	5130,	--The Shattered and the Lost
	5115,	--The Missing Guardian
	5203,	--The Serpent's Fang
	5245,	--Holding Court
	5194,	--Slithering Brood
	5243,	--A Leaf in the Wind
	5239,	--Dawn of the Exalted Viper
	5258,	--The Time-Lost Warrior
	5108,	--Critical Mass
	5081,	--The Fallen City of Shada
	5118,	--The Reason We Fight
	5106,	--Waters Run Foul
	5079,	--The Seeker's Archive
	5107,	--Supreme Power
	5085,	--The Trials of Rahni'Za
	5110,	--Gem of the Stars
	5112,	--Message Unknown
	5111,	--Strange Lexicon
	5186,	--The Blood of Nirn
	5313,	--The Gray Passage
	5175,	--Iron and Scales
	5236,	--Souls of the Betrayed
	5174,	--Taken Alive
	5151,	--The Truer Fangs
	5171,	--The Oldest Ghost
	5240,	--Uncaged
	-- OLD HOMESTEAD QUEST
	6001,	--A Friend In Need
	-- DUPLICATE QUESTS
	6327, 6330, 6331, 6332, 6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595,	--A Charitable Contribution
	5980, 5981, 5982, 5983, 5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991,		--A Masterful Concoction
	5973, 6017,						--A Masterful Glyph
	5974, 6018,						--A Masterful Plate
	5976, 6020,						--A Masterful Shield
	5972, 5975, 6016, 6019,			--A Masterful Weapon
	5635, 5936, 6168, 6370,			--Ache for Cake
	5415, 5416, 5417, 5418, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105,		--Alchemist Writ
	5368, 5377, 5392,				--Blacksmith Writ
	5374, 5388, 5389,				--Clothier Writ
	5487, 5493, 5496, 5602,			--City on the Brink
	5622, 5624, 5625, 5627,			--Contract: Alik'r Desert
	5654, 5655, 5656, 5657, 5658,	--Contract: Auridon
	5630, 5631, 5632,				--Contract: Bangkorai
	5649, 5650, 5651, 5652,			--Contract: Deshaan
	5653, 5667, 5669, 5670,			--Contract: Eastmarch
	5590, 5591, 5592, 5593, 5594,	--Contract: Glenumbra
	5659, 5660, 5661, 5671, 5672,	--Contract: Grahtwood
	5673, 5674, 5676, 5677,			--Contract: Greenshade
	5662, 5663, 5665, 5666,			--Contract: Malabal Tor
	5675, 5678, 5679, 5680,			--Contract: Reaper's March
	5616, 5617, 5626,				--Contract: Rivenspire
	5681, 5682, 5683, 5684,			--Contract: Shadowfen
	5685, 5687, 5689, 5690,			--Contract: Stonefalls
	5614, 5618, 5619, 5620, 5621,	--Contract: Stormhaven
	5691, 5692, 5695, 5697,			--Contract: The Rift
	5645, 5646, 5647,				--Crime Spree
	5400, 5406, 5407,				--Enchanter Writ
	6110, 6024,						--Glitter and Gleam
	6512, 6528, 6558, 6559,			--Halt the Harrowstorms
	5610, 5639, 5640,				--Idle Hands
	6218, 6227, 6228,				--Jewelry Crafting Writ
	6204, 6205, 6450, 6451, 6452,	--Masterful Jewelry
	5979, 6022,						--Masterful Leatherwear
	5978, 6021,						--Masterful Tailoring
	4809, 4810, 4811,				--Nirnroot Wine
	4767, 4967, 4997,				--One of the Undaunted
	5609, 5641, 5642,				--Plucking Fingers
	5409, 5412, 5413,				--Provisioner Writ
	5724, 5725, 5726,				--Sacrament: Sewer Tenement
	5718, 5719, 5720,				--Sacrament: Smuggler's Den
	5529, 5713, 5714,				--Sacrament: Trader's Cove
	6166, 6202,						--Sinking Summerset
	6434, 6435,						--The Dragonguard's Quarry
	5879, 6134,						--The New Life Festival
	5638, 5643, 5644,				--Under Our Thumb
	6427, 6439,						--Witches Festival Writ
	5394, 5395, 5396,				--Woodworker Writ
}

function JournalQuestLog.GetSkipSpecial(questId)
	local skipSpecial = false
	for _,v in pairs(specialExclude) do
		if v == questId then
			skipSpecial = true
			break
		end
	end
	return skipSpecial
end

local duplicateIndex = {
	{["name"]="CyrodiilNirnroot", ["questIds"] = {4809, 4810, 4811}},				--Nirnroot Wine
	{["name"]="DBAlikr", ["questIds"] = {5622, 5624, 5625, 5627}},					--Contract: Alik'r Desert
	{["name"]="DBAuridon", ["questIds"] = {5654, 5655, 5656, 5657, 5658}},			--Contract: Auridon
	{["name"]="DBBangkorai", ["questIds"] = {5630, 5631, 5632}},					--Contract: Bangkorai
	{["name"]="DBDeshaan", ["questIds"] = {5649, 5650, 5651, 5652}},				--Contract: Deshaan
	{["name"]="DBEastmarch", ["questIds"] = {5653, 5667, 5669, 5670}},				--Contract: Eastmarch
	{["name"]="DBGlenumbra", ["questIds"] = {5590, 5591, 5592, 5593, 5594}},		--Contract: Glenumbra
	{["name"]="DBGrahtwood", ["questIds"] = {5659, 5660, 5661, 5671, 5672}},		--Contract: Grahtwood
	{["name"]="DBGrenshade", ["questIds"] = {5673, 5674, 5676, 5677}},				--Contract: Greenshade
	{["name"]="DBMalabal", ["questIds"] = {5662, 5663, 5665, 5666}},				--Contract: Malabal Tor
	{["name"]="DBReapers", ["questIds"] = {5675, 5678, 5679, 5680}},				--Contract: Reaper's March
	{["name"]="DBRivenspire", ["questIds"] = {5616, 5617, 5626}},					--Contract: Rivenspire
	{["name"]="DBShadowfen", ["questIds"] = {5681, 5682, 5683, 5684}},				--Contract: Shadowfen
	{["name"]="DBStonefalls", ["questIds"] = {5685, 5687, 5689, 5690}},				--Contract: Stonefalls
	{["name"]="DBStormhaven", ["questIds"] = {5614, 5618, 5619, 5620, 5621}},		--Contract: Stormhaven
	{["name"]="DBRift", ["questIds"] = {5691, 5692, 5695, 5697}},					--Contract: The Rift
	{["name"]="DBSacrament1", ["questIds"] = {5724, 5725, 5726}},					--Sacrament: Sewer Tenement
	{["name"]="DBSacrament2", ["questIds"] = {5718, 5719, 5720}},					--Sacrament: Smuggler's Den
	{["name"]="DBSacrament3", ["questIds"] = {5529, 5713, 5714}},					--Sacrament: Trader's Cove
	{["name"]="HolidayAnniversary", ["questIds"] = {5635, 5936, 6168, 6370}},		--Ache for Cake
	{["name"]="HolidayNewLife", ["questIds"] = {5879, 6134}},						--The New Life Festival
	{["name"]="ICBrink", ["questIds"] = {5487, 5493, 5496, 5602}},					--City on the Brink
	{["name"]="TGJob1", ["questIds"] = {5610, 5639, 5640}},							--Idle Hands
	{["name"]="TGJob2", ["questIds"] = {5609, 5641, 5642}},							--Plucking Fingers
	{["name"]="TGJob3", ["questIds"] = {5638, 5643, 5644}},							--Under Our Thumb
	{["name"]="TGJob4", ["questIds"] = {5645, 5646, 5647}},							--Crime Spree
	{["name"]="UndauntedJoiner", ["questIds"] = {4767, 4967, 4997}},				--One of the Undaunted
	{["name"]="WEHarrowstorm", ["questIds"] = {6512, 6528, 6558, 6559}},			--Halt the Harrowstorms
	{["name"]="WESummerset", ["questIds"] = {6166, 6202}},							--Sinking Summerset
	{["name"]="WESouthernElsweyr", ["questIds"] = {6434, 6435}},					--The Dragonguard's Quarry
	{["name"]="WritAlchemy", ["questIds"] = {5415, 5416, 5417, 5418, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105}},						--Alchemist Writ
	{["name"]="WritBlacksmith", ["questIds"] = {5368, 5377, 5392}},					--Blacksmith Writ
	{["name"]="WritClothier", ["questIds"] = {5374, 5388, 5389}},					--Clothier Writ
	{["name"]="WritEnchanter", ["questIds"] = {5400, 5406, 5407}},					--Enchanter Writ
	{["name"]="WritJewelry", ["questIds"] = {6218, 6227, 6228}},					--Jewelry Crafting Writ
	{["name"]="WritProvisioner", ["questIds"] = {5409, 5412, 5413}},				--Provisioner Writ
	{["name"]="WritWitches", ["questIds"] = {6427, 6439}},							--Witches Festival Writ
	{["name"]="WritWoodworker", ["questIds"] = {5394, 5395, 5396}},					--Woodworker Writ
	{["name"]="WritMasterAlchemy", ["questIds"] = {5980, 5981, 5982, 5983, 5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991}},				--A Masterful Concoction
	{["name"]="WritMasterClothierMedium", ["questIds"] = {5979, 6022}},				--Masterful Leatherwear
	{["name"]="WritMasterClothierLight", ["questIds"] = {5978, 6021}},				--Masterful Tailoring
	{["name"]="WritMasterEnchanter", ["questIds"] = {5973, 6017}},					--A Masterful Glyph
	{["name"]="WritMasterBlacksmith", ["questIds"] = {5974, 6018}},					--A Masterful Plate
	{["name"]="WritMasterJewelry", ["questIds"] = {6204, 6205, 6450, 6451, 6452}},	--Masterful Jewelry
	{["name"]="WritMasterWoodworking", ["questIds"] = {5976, 6020}},				--A Masterful Shield
	{["name"]="WritMasterWeapon", ["questIds"] = {5972, 5975, 6016, 6019}},			--A Masterful Weapon
	{["name"]="WritNewLife", ["questIds"] = {6327, 6330, 6331, 6332, 6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595}},	--A Charitable Concoction
}

function JournalQuestLog.DuplicateManager()
	local duplicateQuests = {}
	for n=1,#duplicateIndex do
		local isComplete = false
		for k,v in pairs(duplicateIndex[n]) do
			if k=="questIds" then
				for m = 1,#v do
					local questInfo = GetCompletedQuestInfo(v[m])
					if questInfo ~= "" then isComplete = true
					end
				end
			end
		end
		duplicateIndex[n]["isComplete"] = isComplete
	end
	for n=1,#duplicateIndex do
		for k,v in pairs(duplicateIndex[n]) do
			if k=="isComplete" and v == false then
				local questIds = duplicateIndex[n]["questIds"]
				local questId = questIds[#questIds]
				local questName, questType, zoneName, objectiveName = LibUespQuestData:GetUespQuestInfo(questId)
				local categoryName, categoryType = QUEST_JOURNAL_MANAGER:GetQuestCategoryNameAndType(questType, zoneName)
				local completionState = JQL_COMPLETION_STATE_NOT_COMPLETED
				local journalZone = zo_strformat(SI_QUEST_JOURNAL_ZONE_FORMAT, zoneName)
				local isAvailable = true
				local repeatType = LibUespQuestData:GetUespQuestRepeatType(questId)
				local isRepeatable
				local isMissable = JournalQuestLog.GetIsMissable(questId)
			
				if repeatType > 0 then
					isRepeatable = true
				else
					isRepeatable = false
				end

				duplicateQuests[n] = {questId=questId, questName=questName, questType=questType, zoneName=zoneName, objectiveName=objectiveName, zoneIndex="", poiIndex="", categoryName=categoryName, categoryType=categoryType, completionState=completionState, isAvailable=isAvailable, isRepeatable=isRepeatable, isMissable = isMissable}
			end
		end
	end
	return duplicateQuests
end

--[[
-- To remove duplicates from Completed list - unused as it disconnects Completed quest total from Adventurer Achievements counter
local duplicateExclude = {
	[6327] = {6330, 6331, 6332, 6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6330] = {6331, 6332, 6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6331] = {6332, 6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6332] = {6333, 6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6333] = {6334, 6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6334] = {6485, 6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6485] = {6486, 6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6486] = {6487, 6489, 6490, 6592, 6593, 6594, 6595},
	[6487] = {6489, 6490, 6592, 6593, 6594, 6595},
	[6489] = {6490, 6592, 6593, 6594, 6595},
	[6490] = {6592, 6593, 6594, 6595},
	[6592] = {6593, 6594, 6595},
	[6593] = {6594, 6595},
	[6594] = {6595},
	[6595] = {},
	[5980] = {5981, 5982, 5983, 5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991},
	[5981] = {5982, 5983, 5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991},
	[5982] = {5983, 5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991},
	[5983] = {5984, 5985, 5986, 5987, 5988, 5989, 5990, 5991},
	[5984] = {5985, 5986, 5987, 5988, 5989, 5990, 5991},
	[5985] = {5986, 5987, 5988, 5989, 5990, 5991},
	[5986] = {5987, 5988, 5989, 5990, 5991},
	[5987] = {5988, 5989, 5990, 5991},
	[5988] = {5989, 5990, 5991},
	[5989] = {5990, 5991},
	[5990] = {5991},
	[5991] = {},
	[5973] = {6017},
	[6017] = {},
	[5974] = {6018},
	[6018] = {},
	[5976] = {6020},
	[6020] = {},
	[5972] = {5975, 6016, 6019},
	[5975] = {6016, 6019},
	[6016] = {6019},
	[6019] = {},
	[5635] = {5936, 6168, 6370},
	[5936] = {6168, 6370},
	[6168] = {6370},
	[6370] = {},
	[5415] = {5416, 5417, 5418, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105},
	[5416] = {5417, 5418, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105},
	[5417] = {5418, 6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105},
	[5418] = {6098, 6099, 6100, 6101, 6102, 6103, 6104, 6105},
	[6098] = {6099, 6100, 6101, 6102, 6103, 6104, 6105},
	[6099] = {6100, 6101, 6102, 6103, 6104, 6105},
	[6100] = {6101, 6102, 6103, 6104, 6105},
	[6101] = {6102, 6103, 6104, 6105},
	[6102] = {6103, 6104, 6105},
	[6103] = {6104, 6105},
	[6104] = {6105},
	[6105] = {},
	[5368] = {5377, 5392},
	[5377] = {5392},
	[5392] = {},
	[5374] = {5388, 5389},
	[5388] = {5389},
	[5389] = {},
	[5622] = {5624, 5625, 5627},
	[5624] = {5625, 5627},
	[5625] = {5627},
	[5627] = {},
	[5654] = {5655, 5656, 5657, 5658},
	[5655] = {5656, 5657, 5658},
	[5656] = {5657, 5658},
	[5657] = {5658},
	[5658] = {},
	[5630] = {5631, 5632, 5633},
	[5631] = {5632, 5633},
	[5632] = {5633},
	[5633] = {},
	[5649] = {5650, 5651, 5652},
	[5650] = {5651, 5652},
	[5651] = {5652},
	[5652] = {},
	[5653] = {5667, 5669, 5670},
	[5667] = {5669, 5670},
	[5669] = {5670},
	[5670] = {},
	[5590] = {5591, 5592, 5593, 5594},
	[5591] = {5592, 5593, 5594},
	[5592] = {5593, 5594},
	[5593] = {5594},
	[5594] = {},
	[5659] = {5660, 5661, 5671, 5672},
	[5660] = {5661, 5671, 5672},
	[5661] = {5671, 5672},
	[5671] = {5672},
	[5672] = {},
	[5673] = {5674, 5676, 5677},
	[5674] = {5676, 5677},
	[5676] = {5677},
	[5677] = {},
	[5662] = {5663, 5665, 5666},
	[5663] = {5665, 5666},
	[5665] = {5666},
	[5666] = {},
	[5675] = {5678, 5679, 5680},
	[5678] = {5679, 5680},
	[5679] = {5680},
	[5680] = {},
	[5616] = {5617, 5626, 5629},
	[5617] = {5626, 5629},
	[5626] = {5629},
	[5629] = {},
	[5681] = {5682, 5683, 5684},
	[5682] = {5683, 5684},
	[5683] = {5684},
	[5684] = {},
	[5685] = {5687, 5689, 5690},
	[5687] = {5689, 5690},
	[5689] = {5690},
	[5690] = {},
	[5614] = {5618, 5619, 5620, 5621},
	[5618] = {5619, 5620, 5621},
	[5619] = {5620, 5621},
	[5620] = {5621},
	[5621] = {},
	[5691] = {5692, 5695, 5697},
	[5692] = {5695, 5697},
	[5695] = {5697},
	[5697] = {},
	[5645] = {5646, 5647},
	[5646] = {5647},
	[5647] = {},
	[5400] = {5406, 5407},
	[5406] = {5407},
	[5407] = {},
	[6512] = {6528, 6558, 6559},
	[6528] = {6558, 6559},
	[6558] = {6559},
	[6559] = {},
	[5610] = {5639, 5640},
	[5639] = {5640},
	[5640] = {},
	[6218] = {6227, 6228},
	[6227] = {6228},
	[6228] = {},
	[6204] = {6205, 6450, 6451, 6452},
	[6205] = {6450, 6451, 6452},
	[6450] = {6451, 6452},
	[6451] = {6452},
	[6452] = {},
	[5979] = {6022},
	[6022] = {},
	[5978] = {6021},
	[6021] = {},
	[4809] = {4810, 4811},
	[4810] = {4811},
	[4811] = {},
	[4767] = {4967, 4997},
	[4967] = {4997},
	[4997] = {},
	[5609] = {5641, 5642},
	[5641] = {5642},
	[5642] = {},
	[5409] = {5412, 5413, 5414},
	[5412] = {5413, 5414},
	[5413] = {5414},
	[5414] = {},
	[5724] = {5725, 5726},
	[5725] = {5726},
	[5726] = {},
	[5718] = {5719, 5720},
	[5719] = {5720},
	[5720] = {},
	[5529] = {5713, 5714},
	[5713] = {5714},
	[5714] = {},
	[6166] = {6202},
	[6202] = {},
	[6434] = {6435},
	[6435] = {},
	[5879] = {6134},
	[6134] = {},
	[5638] = {5643, 5644},
	[5643] = {5644},
	[5644] = {},
	[6427] = {6439},
	[6439] = {},
	[5394] = {5395, 5396},
	[5395] = {5396},
	[5396] = {},
}

function JournalQuestLog.GetSkipDuplicate(questId)
	local quest = duplicateExclude[questId]
	local skipDuplicate
	if quest == nil then skipDuplicate = false
	else
		for i = 1,#quest do
			local questInfo = GetCompletedQuestInfo(quest[i])
			if questInfo ~= "" then skipDuplicate = true
			end
		end
	end
	return skipDuplicate
end
--]]