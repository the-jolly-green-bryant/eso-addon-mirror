-- Create namespace
DsRGuildPvPPlayerPos = {}
local DsRGuildPvPPlayerPos = DsRGuildPvPPlayerPos  or {}

DsRGuildPvPPlayerPos.name = "DsRGuildPvPPlayerPos"

AREATYPE_NULL   = 0
AREATYPE_SQUARE = 1
AREATYPE_CIRCLE = 2
			
CKEEPTYPE_UNKNOWN        = 0
CKEEPTYPE_KEEP           = 1
CKEEPTYPE_KEEP_OUTPOST   = 2
CKEEPTYPE_KEEP_RESSOURCE = 3
CKEEPTYPE_KEEP_TOWN      = 4

-------------------------------------------------------------------------------------------------------------------------------------------------
local KEEP = {
	-- KEEPS
	[3] = { x="0.23496166394483", y="0.17516849041107", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Obhut
	[4] = { x="0.17488506947563", y="0.32390998701428", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Rayles
	[5] = { x="0.2747132933661", y="0.27468728914252",  areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Aunebel
	[6] = { x="0.33328178893145", y="0.42149889950874", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Asch
	[7] = { x="0.41124617259583", y="0.2757093733728" , areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Alebrunn
	[8] = { x="0.49267894022955", y="0.10858639806842", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Drachenklaue

	[9]  = { x="0.57823415951631", y="0.28002017374511", areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Chalman
	[10] = { x="0.7022011203966", y="0.32281871600666",  areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Arrius
	[11] = { x="0.7269047630882", y="0.18003571250306" , areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Königsbanner
	[12] = { x="0.83949756446216", y="0.32860747570612", areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Farragut
	[13] = { x="0.66087366969595", y="0.42183768375467", areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Blauweg
	[14] = { x="0.774061722038", y="0.57673203800978",   areaSize = 0.025, keepType = CKEEPTYPE_KEEP },  -- Drakenschein

	[15] = { x="0.56838412160138", y="0.56441008079527", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Alessia
	[16] = { x="0.49386733162885", y="0.68099189435945", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Faregyl
	[17] = { x="0.41679295552443", y="0.57335175299918", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Roebeck
	[18] = { x="0.2272969436466", y="0.57044100701124",  areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Brindle
	[19] = { x="0.40981683922782", y="0.77692891442805", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Schwarzstiefel
	[20] = { x="0.57427674933399", y="0.77264113311602", areaSize = 0.025, keepType = CKEEPTYPE_KEEP }, -- Blutmähne

	-- OUTPOST
	[132] = { x="0.3589751215973", y="0.51108836124248",  areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Nikel
	[133] = { x="0.64385358620698", y="0.50197460871415", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Sejanus
	[134] = { x="0.49476246933883", y="0.26720042551222", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Bleicherswacht
	[163] = { x="0.58112889528275", y="0.16300444304943", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Winterweite
	[164] = { x="0.22129333019257", y="0.49329778552055", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Carmala
	[165] = { x="0.79520887136459", y="0.46179333329201", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_OUTPOST}, -- Harluns

	-- TOWN
	[149] = { x="0.30551332235336", y="0.66135334968567", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_TOWN},  -- Vlastarus
	[151] = { x="0.47736889123917", y="0.17227555811405", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_TOWN},  -- Bruma
	[152] = { x="0.68647330999374", y="0.63144445419312", areaSize = 0.010, keepType = CKEEPTYPE_KEEP_TOWN},  -- Erntefurt

	-- RESSOURCES
	[22] = {x="0.5686074786193", y="0.7289717143166",   areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Blutmähne
	[23] = {x="0.55076466731745", y="0.78176888682497", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Blutmähne
	[24] = {x="0.61028945691538", y="0.75997725698661", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Blutmähne

	[34] = {x="0.38387412323052", y="0.77436375803017", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Roebeck
	[35] = {x="0.44105104236159", y="0.79090536451008", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Roebeck
	[36] = {x="0.43224091802919", y="0.75694311362509", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Roebeck

	[37] = {x="0.82903681321224", y="0.35251430413818", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Farragut
	[38] = {x="0.85682479874296", y="0.3084922815055",  areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Farragut
	[39] = {x="0.80812270054634", y="0.32341004284879", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Farragut

	[40] = {x="0.25027850298144", y="0.20828614758719", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Obhut
	[41] = {x="0.26189171465607", y="0.16670335342572", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Obhut
	[42] = {x="0.20588605451558", y="0.17663077811418", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Obhut

	[43] = {x="0.47224763177326", y="0.66096279158978", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Faregyl
	[44] = {x="0.51748296813573", y="0.69275864097977", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Faregyl
	[45] = {x="0.52305544264356", y="0.65702927556362", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Faregyl

	[46] = {x="0.71142075256284", y="0.28971662108463", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Arrius
	[47] = {x="0.67661517158052", y="0.31927752352913", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Arrius
	[48] = {x="0.72405639059964", y="0.31832098358726", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Arrius

	[49] = {x="0.28398142317501", y="0.3191594041345",  areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Aunebel
	[50] = {x="0.31004492053104", y="0.27932141302688", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Aunebel
	[51] = {x="0.25421191403899", y="0.27614005666758", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Aunebel

	[52] = {x="0.76340764773549", y="0.19464657625477", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Königsbanner
	[53] = {x="0.71005551851841", y="0.16913112960728", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Königsbanner
	[54] = {x="0.70902392900007", y="0.21178116842184", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Königsbanner

	[55] = {x="0.19751579003178", y="0.33996745322543", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Rayles
	[56] = {x="0.16517725583925", y="0.34597408852698", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Rayles
	[57] = {x="0.19590752567162", y="0.28850302986163", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Rayles

	[61] = {x="0.31718794110901", y="0.43829290343513", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Asch
	[62] = {x="0.35393518001145", y="0.39636999062019", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Asch
	[63] = {x="0.30821678124144", y="0.40396097283962", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Asch

	[64] = {x="0.39602536240076", y="0.25396932674216", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Alebrunn
	[65] = {x="0.38724327893681", y="0.30799007429127", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Alebrunn
	[66] = {x="0.43485943357098", y="0.27624597545662", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Alebrunn

	[67] = {x="0.53235128161161", y="0.12504204341084", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Drachenklaue
	[68] = {x="0.4731579620403", y="0.093703693682394", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Drachenklaue
	[69] = {x="0.47739929212729", y="0.13202185906393", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Drachenklaue

	[70] = {x="0.55537626874944", y="0.26988880109766", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Chalman
	[71] = {x="0.5825919062882", y="0.32027451256528",  areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Chalman
	[72] = {x="0.61422087679343", y="0.27246325471154", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Chalman

	[73] = {x="0.68334187070727", y="0.43104816388734", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Blauweg
	[74] = {x="0.65355179076949", y="0.39574141224721", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Blauweg
	[75] = {x="0.62891061760685", y="0.42920927331989", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Blauweg

	[76] = {x="0.76743852761112", y="0.60899502816278", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Drakenschein
	[77] = {x="0.78656302907141", y="0.55640266562982", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Drakenschein
	[78] = {x="0.73985512514513", y="0.56412602579251", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Drakenschein

	[79] = {x="0.58140815331371", y="0.58625631435282", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Alessia
	[80] = {x="0.54058470799412", y="0.54469731170739", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Alessia
	[81] = {x="0.55419253775206", y="0.58883076774038", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Alessia

	[82] = {x="0.39899630986773", y="0.58915818269711", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Roebeck
	[83] = {x="0.43726509218562", y="0.58035002148922", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Roebeck
	[84] = {x="0.40857835098373", y="0.54357215519741", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Roebeck

	[85] = {x="0.20478308901968", y="0.54681319625127", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Mine Brindle
	[86] = {x="0.20809310522736", y="0.58211995887995", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Lumber Brindle
	[87] = {x="0.25222656675463", y="0.58064884422828", areaSize = 0.007, keepType = CKEEPTYPE_KEEP_RESSOURCE}, -- Farm Brindle
}

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPPlayerPos:PlayerIsNearKeepID(argKeepID, areaType, areaSize)
	areaType = areaType or AREATYPE_SQUARE		
	if KEEP[argKeepID] then
		local currentKeep = KEEP[argKeepID]
		areaSize = areaSize or currentKeep.areaSize
		local player_x, player_y, player_z = GetMapPlayerPosition("player")
			
		if areaType == AREATYPE_SQUARE then
			local limit_x_1, limit_x_2 = currentKeep.x + areaSize, currentKeep.x - areaSize
			local limit_y_1, limit_y_2 = currentKeep.y + areaSize, currentKeep.y - areaSize
				
			if player_x < limit_x_1 and player_x > limit_x_2 and player_y < limit_y_1 and player_y > limit_y_2 then
				return true
			else
				return false
			end
				
		elseif areaType == AREATYPE_CIRCLE then
			local distance_X = currentKeep.x - player_x
			local distance_Y = currentKeep.y - player_y
			local distance = math.floor( math.sqrt( math.pow(distance_X, 2) + math.pow(distance_Y,2 ) ) * 1250 )
			local distance = distance / 1000
				
			if distance <= areaSize then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPPlayerPos:getNearestKeep(areaType, areaSize, filter)
	areaType = areaType or AREATYPE_SQUARE		
	filter = filter or { CKEEPTYPE_KEEP, CKEEPTYPE_KEEP_OUTPOST, CKEEPTYPE_KEEP_RESSOURCE, CKEEPTYPE_KEEP_TOWN}
	local resultKeepID = 0
	local player_x, player_y, player_z = GetMapPlayerPosition("player")
	if areaType == AREATYPE_SQUARE then
		for KeepID, KeepValues in pairs(KEEP) do
			for _, filterkey in pairs(filter) do
				if filterkey == KeepValues.keepType then
					areaSize = areaSize or KeepValues.areaSize
					local keep_x, keep_y = KeepValues.x, KeepValues.y
					local limit_x_1, limit_x_2 = keep_x + areaSize, keep_x - areaSize
					local limit_y_1, limit_y_2 = keep_y + areaSize, keep_y - areaSize
						
					if player_x < limit_x_1 and player_x > limit_x_2 and player_y < limit_y_1 and player_y > limit_y_2 then
						resultKeepID = KeepID
						break
					end
				end
			end
		end
	elseif areaType == AREATYPE_CIRCLE then
		for KeepID, KeepValues in pairs(KEEP) do
			local keep_x, keep_y, areaSize = KeepValues.x, KeepValues.y, KeepValues.areaSize
			local distance_X = keep_x - player_x
			local distance_Y = keep_y - player_y
			local distance = math.floor( math.sqrt( math.pow(distance_X, 2) + math.pow(distance_Y,2 ) ) * 1250 )
			local distance = distance / 1000
				
			if distance <= areaSize then
				resultKeepID = KeepID
				break
			end
		end
	end
	return resultKeepID
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPPlayerPos:getKeepType(KeepID)
	if KEEP[KeepID] then
		return KEEP[KeepID].keepType
	else
		return CKEEPTYPE_UNKNOWN
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPvPPlayerPos:getBattlegroundContext()
	local battlegroundContext = BGQUERY_UNKNOWN 
	if GetCurrentCampaignId() == GetAssignedCampaignId() then
		battlegroundContext = BGQUERY_ASSIGNED_CAMPAIGN
	else
		battlegroundContext = BGQUERY_LOCAL 
	end
	return battlegroundContext
end
