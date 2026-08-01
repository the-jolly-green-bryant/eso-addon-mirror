--------------------------------------------------------------------------------
-- This tool generates the achievement data for Raidificator, and is intended
-- for use only by an addon developer for the maintenance of Raidificator. It is
-- disabled and will not load unless manually enabled by renaming the manifest.
--
-- Usage: Invoke /rcrach, then /reloadui, then look in SavedVariables.
--------------------------------------------------------------------------------


local LCCC = LibCodesCommonCode
local LMAC = LibMultiAccountCollectibles
local RCR = Raidificator
local Data, HardcodedAchievements, InjectedAchievements, ManualHardModeIds, ExpectedCounts, Trophies, Seen

local IA_ZONE = 1436
local OO_ZONE = 1565

local FIELD_SIZE = RCR.ACHIEVEMENT_FIELD_SIZE
local FLAGS_SIZE = RCR.FLAGS_FIELD_SIZE
local FLAGS = RCR.ACHIEVEMENT_FLAGS

local F_VET = FLAGS.V
local F_NCLR = FLAGS.C
local F_VCLR = FLAGS.V + FLAGS.C
local F_HM = FLAGS.V + FLAGS.H
local F_SR = FLAGS.V + FLAGS.S
local F_ND = FLAGS.V + FLAGS.N
local F_TRI = FLAGS.V + FLAGS.T


-- Additional flags used only for ESO Clears Bot (ESOCB) support ---------------
local F_HMF = FLAGS.V + FLAGS.H + FLAGS.F
local F_MISC = FLAGS.V + FLAGS.M

local FinalHardModeHints = { }

local function MarkFinalHardMode( zoneId, achievements )
	-- Mark which HM is the final one, either by explicit hint or by highest ID
	local lastIndex = 0
	for i, ach in ipairs(achievements) do
		if (ach[2] == F_HM) then
			if (FinalHardModeHints[ach[1]]) then
				ach[2] = F_HMF
				return
			else
				lastIndex = i
			end
		end
	end
	if (lastIndex > 0) then
		achievements[lastIndex][2] = F_HMF
	end
end

local function CheckChallenger( zoneId, name )
	if (RCR.ZONES.D[zoneId] and string.find(name, "Challenger$")) then
		return true
	else
		return false
	end
end

local function ShouldExpectMisc( zoneId )
	return (RCR.ZONES.D[zoneId] and RCR.ZONES.D[zoneId][3] >= 2015) or (RCR.ZONES.T[zoneId] and RCR.ZONES.T[zoneId][1] >= 2016)
end
--------------------------------------------------------------------------------


local function Initialize( )
	if (not RCR_AchievementClassifier) then RCR_AchievementClassifier = { } end
	Data = RCR_AchievementClassifier
	Data.results = { }
	Data.forced = { }
	Data.unmatched = { }

	local DLC_GENERAL = { 1132, -1 }

	-- { zoneId, sampleAchIsHM, { sampleCategoryAchId, defaultCategoryFlags }[, ...] }
	-- If sampleCategoryAchId corresponds to a hard mode achievement, it is also used
	-- as a hint for flagging which hard mode is the final hard mode for ESOCB
	Zones = {
		-- Dungeons ----------------------------------------------------------------
		{  144, true, { 1570 } }, -- Spindleclutch I
		{  936, true, {  448 } }, -- Spindleclutch II
		{  380, true, { 1554 } }, -- The Banished Cells I
		{  935, true, {  451 } }, -- The Banished Cells II
		{  283, true, { 1561 } }, -- Fungal Grotto I
		{  934, true, {  342 } }, -- Fungal Grotto II
		{  146, true, { 1594 } }, -- Wayrest Sewers I
		{  933, true, {  681 } }, -- Wayrest Sewers II
		{  126, true, { 1578 } }, -- Elden Hollow I
		{  931, true, {  463 } }, -- Elden Hollow II
		{   63, true, { 1586 } }, -- Darkshade Caverns I
		{  930, true, {  467 } }, -- Darkshade Caverns II
		{  130, true, { 1615 } }, -- Crypt of Hearts I
		{  932, true, { 1084 } }, -- Crypt of Hearts II
		{  176, true, { 1602 } }, -- City of Ash I
		{  681, true, { 1114 } }, -- City of Ash II
		{  148, true, { 1609 } }, -- Arx Corinium
		{   22, true, { 1634 } }, -- Volenfell
		{  131, true, { 1622 } }, -- Tempest Island
		{  449, true, { 1628 } }, -- Direfrost Keep
		{   38, true, { 1652 } }, -- Blackheart Haven
		{   31, true, { 1640 } }, -- Selene's Web
		{   64, true, { 1646 } }, -- Blessed Crucible
		{   11, true, { 1658 } }, -- Vaults of Madness
		{  678, true, { 1303 }, DLC_GENERAL }, -- Imperial City Prison
		{  688, true, { 1279 }, DLC_GENERAL }, -- White-Gold Tower
		{  843, true, { 1506 }, DLC_GENERAL }, -- Ruins of Mazzatun
		{  848, true, { 1524 }, DLC_GENERAL }, -- Cradle of Shadows
		{  973, true, { 1696 }, DLC_GENERAL }, -- Bloodroot Forge
		{  974, true, { 1704 }, DLC_GENERAL }, -- Falkreath Hold
		{ 1009, true, { 1965 }, DLC_GENERAL }, -- Fang Lair
		{ 1010, true, { 1981 }, DLC_GENERAL }, -- Scalecaller Peak
		{ 1052, true, { 2154 }, DLC_GENERAL }, -- Moon Hunter Keep
		{ 1055, true, { 2164 }, DLC_GENERAL }, -- March of Sacrifices
		{ 1081, true, { 2272 }, DLC_GENERAL }, -- Depths of Malatar
		{ 1080, true, { 2262 }, DLC_GENERAL }, -- Frostvault
		{ 1122, true, { 2417 }, DLC_GENERAL }, -- Moongrave Fane
		{ 1123, true, { 2427 }, DLC_GENERAL }, -- Lair of Maarselok
		{ 1152, true, { 2541 }, DLC_GENERAL }, -- Icereach
		{ 1153, true, { 2551 }, DLC_GENERAL }, -- Unhallowed Grave
		{ 1197, true, { 2755 }, DLC_GENERAL }, -- Stone Garden
		{ 1201, true, { 2706 }, DLC_GENERAL }, -- Castle Thorn
		{ 1228, true, { 2833 }, DLC_GENERAL }, -- Black Drake Villa
		{ 1229, true, { 2843 }, DLC_GENERAL }, -- The Cauldron
		{ 1267, true, { 3018 }, DLC_GENERAL }, -- Red Petal Bastion
		{ 1268, true, { 3028 }, DLC_GENERAL }, -- The Dread Cellar
		{ 1301, true, { 3153 }, DLC_GENERAL }, -- Coral Aerie
		{ 1302, true, { 3154 }, DLC_GENERAL }, -- Shipwright's Regret
		{ 1360, true, { 3377 }, DLC_GENERAL }, -- Earthen Root Enclave
		{ 1361, true, { 3396 }, DLC_GENERAL }, -- Graven Deep
		{ 1389, true, { 3470 }, DLC_GENERAL }, -- Bal Sunnar
		{ 1390, true, { 3531 }, DLC_GENERAL }, -- Scrivener's Hall
		{ 1470, true, { 3812 }, DLC_GENERAL }, -- Oathsworn Pit
		{ 1471, true, { 3853 }, DLC_GENERAL }, -- Bedlam Veil
		{ 1496, true, { 4111 }, DLC_GENERAL }, -- Exiled Redoubt
		{ 1497, true, { 4130 }, DLC_GENERAL }, -- Lep Seclusa
		{ 1551, true, { 4313 }, DLC_GENERAL }, -- Naj-Caldeesh
		{ 1552, true, { 4336 }, DLC_GENERAL }, -- Black Gem Foundry

		-- Trials ------------------------------------------------------------------
		{  636, true, { 1136 } }, -- Hel Ra Citadel
		{  638, true, { 1137 } }, -- Aetherian Archive
		{  639, true, { 1138 } }, -- Sanctum Ophidia
		{  725, true, { 1344 } }, -- Maw of Lorkhaj
		{  975, true, { 1829 } }, -- Halls of Fabrication
		{ 1000, true, { 2079 } }, -- Asylum Sanctorium
		{ 1051, true, { 2136 } }, -- Cloudrest
		{ 1121, true, { 2466 } }, -- Sunspire
		{ 1196, true, { 2739 } }, -- Kyne's Aegis
		{ 1263, true, { 3007 } }, -- Rockgrove
		{ 1344, true, { 3252 } }, -- Dreadsail Reef
		{ 1427, true, { 3568 } }, -- Sanity's Edge
		{ 1478, true, { 4023 } }, -- Lucent Citadel
		{ 1548, true, { 4276 } }, -- Ossein Cage
		{ 1565, false }, -- Opulent Ordeal

		-- Arenas ------------------------------------------------------------------
		{  635, false, { 1140 } }, -- Dragonstar Arena
		{  677, false, { 1330 } }, -- Maelstrom Arena
		{ 1082, true, { 2364 } }, -- Blackrose Prison
		{ 1227, true, { 2911 } }, -- Vateshran Hollows
		{ 1436, false, { 3772 }, { 3931 } }, -- Infinite Archive
	}

	HardcodedAchievements = {
		-- WGT
		[1132] = {  688, F_MISC }, -- Imperial City Challenger

		-- BRP
		[2365] = { 1082, F_ND }, -- Unchained and Undying
		[2367] = { 1082, F_VET }, -- Blackrose Buccaneer

		-- VH
		[2920] = { 1227, F_VET }, -- Missed Me by That Much
		[2960] = { 1227, 0 }, -- Honor to the Spiritblood

		-- Correct Normal to Vet
		[2881] = { 1228, F_VET }, -- Amphibians Arrested (description does not mention vet, but used to be in the Veteran subcategory pre-U50)
		[3035] = { 1267, F_VET }, -- Sly Terror (typo)

		-- HM false positives (generally the extra-hard mode achievements)
		[2301] = { 1052, F_VET }, -- Strangling Cowardice
		[2824] = { 1197, F_VET }, -- Old Fashioned
		[2828] = { 1201, F_VET }, -- Guardian Preserved
		[3042] = { 1268, F_VET }, -- Settling Scores
		[3224] = { 1302, F_VET }, -- Sans Spirit Support
		[3226] = { 1301, F_VET }, -- Tentacless Triumph
		[3255] = { 1344, F_VET }, -- Full Tour
		[3391] = { 1360, F_VET }, -- Scourge of Archdruid Devyric
		[3410] = { 1361, F_VET }, -- Pressure in the Deep
		[3484] = { 1389, F_VET }, -- No Time to Waste
		[3538] = { 1390, F_VET }, -- Harsh Edit
		[3826] = { 1470, F_VET }, -- Dogged Avenger
		[3867] = { 1471, F_VET }, -- Martial Gift
		[4120] = { 1496, F_VET }, -- Exposed to the Elements
		[4125] = { 1496, F_VET }, -- Life's for the Living
		[4281] = { 1548, F_VET }, -- Heating Up
		[4327] = { 1551, F_VET }, -- No Time to Explore
		[4350] = { 1552, F_VET }, -- Entry-Level Position

		-- ND false positives
		[1837] = {  975, F_VET }, -- Stress Tested
		[2890] = { 1229, F_VET }, -- Hold It Together
	}

	ManualHardModeIds = {
		2466, 2469, 2470, -- Sunspire
		2079, 2085, 2086, -- Asylum Sanctorium
		2134, 2135, 2136, -- Cloudrest
	}

	InjectedAchievements = {
		-- Imperial City Prison
		[678] = {
			{ 1132, F_MISC },
		},

		-- Opulent Ordeal
		[1565] = {
			{ 4517, F_NCLR },
			{ 4532, 0 },
			{ 4485, FLAGS.N },
		},
	}

	ExpectedCounts = {
		[F_NCLR] = { },
		[F_VCLR] = { },
		[F_HM] = {
			[1197] = 3,
			[1228] = 3,
		},
		[F_SR] = {
			[635] = 0,
			[677] = 0,
		},
		[F_ND] = {
			[635] = 0,
			[636] = 0,
			[638] = 0,
			[639] = 0,
		},
		[F_TRI] = { },
		-- ESOCB
		[F_MISC] = {
			[678] = 0,
			[1565] = 0,
		},
	}

	-- Nothing from IA or OO should be flagged
	for k, v in pairs(ExpectedCounts) do
		v[IA_ZONE] = 0
		v[OO_ZONE] = 0
	end

	Trophies = { }
	for i = 1, LMAC.GetMaxCollectibleId() do
		if (string.find(GetCollectibleName(i), "^Trophy:")) then
			table.insert(Trophies, i)
		end
	end

	Seen = { }

	return Data.results
end

local function CleanZoneName( zoneName )
	zoneName = string.gsub(zoneName, "^The ", "")
	zoneName = string.gsub(zoneName, "%-", ".")
	return zoneName
end

local function FindTrophyId( pattern )
	for _, id in ipairs(Trophies) do
		if (string.find(GetCollectibleDescription(id) .. " ", pattern)) then
			return id
		end
	end
	return 0
end

local function CheckVet( description )
	if (string.find(description, "n Veteran.?$")) then
		return true
	else
		return false
	end
end

local function CheckND( description )
	if (string.find(description, "without suffering a .+ member death") or string.find(description, "^Complete .+ without dying") or string.find(description, "without experiencing the death of a group member")) then
		return true
	else
		return false
	end
end

local function CheckND2( description )
	if (string.find(description, "without dying")) then
		return true
	else
		return false
	end
end

local function CheckSR( description )
	if (string.find(description, "within .+ minutes") or string.find(description, "in under .+ minutes")) then
		return true
	else
		return false
	end
end

local function CheckHMById( achievementId )
	for _, id in ipairs(ManualHardModeIds) do
		if (achievementId == id) then
			return true
		end
	end
	return false
end

local function CheckHM( description, name )
	if (string.find(name, "Difficult Mode$") or string.find(zo_strlower(description), "defeat .+ after.* enraging") or string.find(description, "Scroll of Glorious Battle") or string.find(zo_strlower(description), "challenge banner") or string.find(description, "without .+ Sigil")) then
		return true
	else
		return false
	end
end

local function CheckMeta( description )
	if (string.find(description, "^Complete .+ listed") or string.find(description, "^Complete .+ following.* achievements") or string.find(description, "^Complete all achievements")) then
		return true
	else
		return false
	end
end

local function CheckClearN( description, name )
	if (string.find(name, "Completed$") or string.find(name, "Vanquisher$") or string.find(name, "Arena Champion$")) then
		return true
	else
		return false
	end
end

local function CheckClearV( description, name )
	if (string.find(name, "Conqueror$") and not string.find(name, "^Veteran")) then
		return true
	else
		return false
	end
end

local function Hex( flags )
	return string.format("0x%02X", flags)
end

local function GetExpectedHMCount( zoneId )
	if (RCR.ZONES.D[zoneId]) then
		return zoneId < 1267 and 1 or 3
	elseif (RCR.ZONES.T[zoneId]) then
		return zoneId < 1000 and 1 or 3
	elseif (RCR.ZONES.A[zoneId]) then
		return zoneId < 1082 and 0 or 1
	else
		return 0
	end
end

local function CheckGroup( data, flags, expected, desc, zoneId )
	local group = data[Hex(flags)]
	local count = group and LCCC.CountTable(group) or 0
	expected = ExpectedCounts[flags][zoneId] or expected
	if (count ~= expected) then
		RCR.Msg(string.format("[WARNING] Incorrect %s count: %s (%d found, %d expected)", desc, LCCC.GetZoneName(zoneId), count, expected))
	end
end

local function GetAchievementInfoEx(...)
	local results = { GetAchievementInfo(...) }
	results[1] = zo_strformat(results[1])
	return unpack(results)
end

local function Process( )
	local results = Initialize()
	local classified = { }
	local trophies = { }

	for _, zone in ipairs(Zones) do
		local zoneId = zone[1]
		local zoneName = LCCC.GetZoneName(zoneId)
		local sampleAchIsHM = zone[2]
		local forceMatch = true
		local patN = CleanZoneName(zoneName) .. "[^I]"
		local patV = "Veteran " .. patN

		results[zoneId] = { name = zoneName, trophy = FindTrophyId(patN) }
		local achievements = { }

		for i = 3, #zone do
			FinalHardModeHints[zone[i][1]] = true -- ESOCB
			local topLevelIndex, subCategoryIndex = GetCategoryInfoFromAchievementId(zone[i][1])
			local numAchievements = subCategoryIndex and select(2, GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex)) or select(3, GetAchievementCategoryInfo(topLevelIndex))
			local flagsBase = zone[i][2]
			if (flagsBase == -1) then
				flagsBase = nil
				sampleAchIsHM = false
				forceMatch = false
			end
			local expectNormal = flagsBase == 0
			for j = 1, numAchievements do
				local achievementId = GetAchievementId(topLevelIndex, subCategoryIndex, j)
				while true do
					local nextAchievementId = GetNextAchievementInLine(achievementId)
					if (nextAchievementId ~= 0) then
						achievementId = nextAchievementId
					else
						break
					end
				end
				if (achievementId == 0) then
					RCR.Msg(string.format("[ERROR] Invalid Index for %s: %d/%d/%d", zoneName, topLevelIndex or 0, subCategoryIndex or 0, j))
				end
				local name, description = GetAchievementInfoEx(achievementId)
				local matched = false
				local flags = flagsBase or 0

				if (not Seen[achievementId]) then
					Seen[achievementId] = true
				end

				local hardcode = HardcodedAchievements[achievementId]
				if (hardcode) then
					if (hardcode[1] == 0) then
						Seen[achievementId] = hardcode[1]
					elseif (hardcode[1] == zoneId) then
						matched = true
						if (hardcode[2]) then
							flags = hardcode[2]
						end
					end
				else
					if (string.find(description .. " ", patV)) then
						matched = true
						flags = BitOr(flags, F_VET)
					elseif (string.find(description .. " ", patN)) then
						matched = true
					elseif (string.find(name, patN)) then
						matched = true
					end

					if (not matched and forceMatch) then
						matched = true
						Data.forced[achievementId] = string.format("%s----%s", name, description)
					end

					if (matched) then
						if (CheckVet(description)) then
							flags = BitOr(flags, F_VET)
						end

						if ((sampleAchIsHM and achievementId == zone[i][1]) or CheckHMById(achievementId)) then
							flags = BitOr(flags, F_HM)
						elseif (CheckChallenger(zoneId, name)) then -- ESOCB
							flags = BitOr(flags, F_MISC)
						elseif (CheckND(description)) then
							flags = BitOr(flags, CheckSR(description) and F_TRI or F_ND)
						elseif (CheckSR(description)) then
							flags = BitOr(flags, CheckND2(description) and F_TRI or F_SR)
						elseif (CheckHM(description, name)) then
							flags = BitOr(flags, F_HM)
						elseif (CheckClearN(description, name)) then
							flags = BitOr(flags, F_NCLR)
						elseif (CheckClearV(description, name)) then
							flags = BitOr(flags, F_VCLR)
						elseif (CheckMeta(description)) then
							flags = BitOr(flags, RCR.ZONES.T[zoneId] and F_MISC or F_VET) -- ESOCB
						end
					end
				end

				if (matched) then
					Seen[achievementId] = zoneId
					if (zoneId == IA_ZONE) then flags = 0 end -- Nothing from IA should be flagged
					results[zoneId][Hex(flags)] = results[zoneId][Hex(flags)] or { }
					results[zoneId][Hex(flags)][achievementId] = string.format("%s----%s", name, description)
					table.insert(achievements, { achievementId, flags })
					if (expectNormal and BitAnd(flags, F_VET) == F_VET) then
						RCR.Msg(string.format("[WARNING] Unexpected Veteran: %d/%s", achievementId, name))
					end
				end
			end
		end

		for _, achievement in ipairs(InjectedAchievements[zoneId] or { }) do
			table.insert(achievements, achievement)
		end

		table.insert(classified, { zoneId = zoneId, achievements = achievements })
		table.insert(trophies, results[zoneId].trophy)
	end

	for achievementId, status in pairs(Seen) do
		if (status == true) then
			Data.unmatched[achievementId] = string.format("%s----%s", GetAchievementInfoEx(achievementId))
			RCR.Msg(string.format("[WARNING] Unmatched: %d/%s", achievementId, GetAchievementInfoEx(achievementId)))
		end
	end

	for zoneId, data in pairs(results) do
		CheckGroup(data, F_NCLR, 1, "normal clear", zoneId)
		CheckGroup(data, F_VCLR, 1, "vet clear", zoneId)
		CheckGroup(data, F_HM, GetExpectedHMCount(zoneId), "hard mode", zoneId)
		CheckGroup(data, F_SR, 1, "speedrun", zoneId)
		CheckGroup(data, F_ND, 1, "no-death", zoneId)
		CheckGroup(data, F_TRI, zoneId < 975 and 0 or 1, "trifecta", zoneId)
		-- ESOCB
		CheckGroup(data, F_MISC, ShouldExpectMisc(zoneId) and 1 or 0, "misc", zoneId)
	end

	local encoded = { }
	for _, data in ipairs(classified) do
		table.sort(data.achievements, function( a, b )
			return a[1] < b[1]
		end)
		MarkFinalHardMode(data.zoneId, data.achievements) -- ESOCB
		local fields = { LCCC.Encode(data.zoneId, FIELD_SIZE) }
		for _, achievement in ipairs(data.achievements) do
			table.insert(fields, LCCC.Encode(achievement[1], FIELD_SIZE) .. LCCC.Encode(achievement[2], FLAGS_SIZE))
		end
		table.insert(encoded, table.concat(fields, ""))
	end

	local signature = string.format("Generated by RCR_AchievementClassifier on %s (%d: %s)", os.date("%Y/%m/%d %H:%M:%S", GetTimeStamp()), GetAPIVersion(), GetESOVersionString())
	Data.encoded = LCCC.Chunk(table.concat(encoded, ","))
	Data.encoded.signature = signature
	RCR.Msg(signature)

	Data.trophies = table.concat(trophies, ",")
end

LCCC.RunAfterInitialLoadscreen(function( )
	SLASH_COMMANDS["/rcrach"] = Process
end)
