-- global namspacing
PITHKA = PITHKA or {} 
PITHKA.data = PITHKA.data or {}
PITHKA.data.generateQR = {}

-- convenient namespace
local api = PITHKA.common.api
local utils = PITHKA.common.utils
local data = PITHKA.data
local utils = PITHKA.common.utils

-- debug printing
local debugEnabled = false -- temporarily enabled to see compression working
local function debug(msg)
    if debugEnabled then
        d('|cF2A5e0[data.generateQR]|r ' .. msg )
    end
end

local debugIncludeAll = false -- include all achievements for debugging

PITHKA.data.TrialA = {1474, 1136, 1503, 1137, 1462, 1138, 1368, 1344, 1391, 1810, 1829, 1838, 1836, 2077, 2085, 2086, 2079, 2087, 2075, 2133, 2134, 2135, 2136, 2139, 2140, 2435, 2469, 2470, 2466, 2467, 2468}
PITHKA.data.TrialB = {2734, 2736, 2737, 2739, 2740, 2746, 2987, 3005, 3006, 3007, 3003, 3004, 3244, 3250, 3251, 3252, 3248, 3249, 3560, 3566, 3567, 3568, 3564, 3565, 4015, 4021, 4022, 4023, 4019, 4020, 4268}
PITHKA.data.TrialC = {4274, 4275, 4276, 4272, 4273, 4517, 4485}
PITHKA.data.DungeonA = {1960, 1965, 1966, 2102, 1976, 1981, 1982, 1983, 2153, 2154, 2158, 2159, 2163, 2164, 2167, 2168, 2261, 2262, 2266, 2267, 2271, 2272, 2275, 2276, 2426, 2427, 2430, 2431, 2416, 2417, 2421}
PITHKA.data.DungeonB = {2422, 2540, 2541, 2545, 2546, 2550, 2551, 2554, 2555, 2695, 2755, 2700, 2701, 2705, 2706, 2709, 2710, 2832, 2833, 2837, 2838, 2842, 2843, 2846, 2847, 3017, 3018, 3022, 3023, 3027, 3028}
PITHKA.data.DungeonC = {3031, 3032, 3105, 3153, 3110, 3111, 3115, 3154, 3119, 3120, 3376, 3377, 3380, 3381, 3395, 3396, 3399, 3400, 3469, 3470, 3473, 3474, 3530, 3531, 3534, 3535, 3811, 3812, 3815, 3816, 3852}
PITHKA.data.DungeonD = {3853, 3856, 3857, 4110, 4111, 4114, 4115, 4129, 4130, 4133, 4134, 2363, 2364, 2368, 4335, 4336, 4339, 4340, 4312, 4313, 4316, 4317}

--lazy-load the inverted lookup table, only initialize it when the user actually asks for a QR Code.
PITHKA.data.lookup = nil

local function addListToLookup(list, name)
	for i, v in ipairs(list) do
		--the bitshift value is 1 less than the array index.
		PITHKA.data.lookup[v] = {maskName=name, shift=i-1}
	end
end

local function buildLookup()
	if PITHKA.data.lookup ~= nil then
		return
	end
	PITHKA.data.lookup = {}
	addListToLookup(PITHKA.data.TrialA, "ta")
	addListToLookup(PITHKA.data.TrialB, "tb")
	addListToLookup(PITHKA.data.TrialC, "tc")
	addListToLookup(PITHKA.data.DungeonA, "da")
	addListToLookup(PITHKA.data.DungeonB, "db")
	addListToLookup(PITHKA.data.DungeonC, "dc")
	addListToLookup(PITHKA.data.DungeonD, "dd")
end

local function getMaskNameAndShift(achievementId)
	if PITHKA.data.lookup == nil then
		buildLookup()
	end
	details = PITHKA.data.lookup[achievementId]
	if(details == nil) then
		return nil, nil
	end
	return details.maskName, details.shift
end

local function addMask(values, masks, achievementId)
	if achievementId ~= nil and api.achievement.IsComplete(achievementId) then 
		local tableName, shift = getMaskNameAndShift(achievementId)
		if(shift ~= nil) then
			masks[tableName] = BitOr(masks[tableName], BitLShift(1, shift))
		else
			table.insert(values, achievementId)
		end
	end
end

local function checksum(qrstring)
	local sum = qrstring:byte(1)
	for i=2, #qrstring do
		 local b = qrstring:byte(i)
		 --why 5? Why not 5.  It's a super simple checksum, just pick something.
		 sum = (BitLShift(sum, 5) + b) % 2147483648 --mod by 2^31
	end
	return sum 
end

local worlds = { "NA Megaserver", "EU Megaserver", "XB1live", "XB1live-eu", "PS4live", "PS4live-eu", "PTS" }

-- Compressed QR generation using hierarchical achievement logic
function data.generateQR.achievementsTableToCSVCompressed(tbl)
    local values = {}
    -- Start with metadata (version v3 includes group finder usage analytics)
    local version = 'v5'
    local date = os.date("%Y%m%d")
    local playerName = GetDisplayName()
	local worldName = GetWorldName()
	local worldId = -1
	for i, v in ipairs(worlds) do
		if v == worldName then
			worldId = i
			break
		end
	end
    
    -- Get group finder usage analytics
    local groupFinderUsage = 0
    local savedVars = PITHKA.data.savedVars
    if savedVars and savedVars.db and savedVars.db.groupFinderUsage then
        groupFinderUsage = savedVars.db.groupFinderUsage.joiningAttempts or 0
    end
    
    table.insert(values, 'PAT')
    table.insert(values, version)
    table.insert(values, 'gf_' .. tostring(groupFinderUsage))
    table.insert(values, playerName)
    table.insert(values, date)
	if worldId == -1 then
		table.insert(values, worldName)
	else
		table.insert(values, worldId)
	end
    
    debug(string.format("QR v5 generation - Group Finder usage: %d joining attempts", groupFinderUsage))
    
	local masks = {
		["ta"]=0,
		["tb"]=0,
		["tc"]=0,
		["da"]=0,
		["db"]=0,
		["dc"]=0,
		["dd"]=0,
	}
	
    -- Process each row with compression logic
    for _, row in ipairs(tbl) do
		--there is no bitmask compression for base game dungeons, we generally don't expect to track those.
		if row.TYPE == 'baseDungeon-wI' or row.TYPE == 'baseDungeon-noI' then
			if row.HM and api.achievement.IsComplete(row.HM) then
				table.insert(values, row.HM)
			elseif row.VET and api.achievement.IsComplete(row.VET) then
				table.insert(values, row.VET)
			end
		else
			addMask(values, masks, row.EXT)
			addMask(values, masks, row.TRI)
			addMask(values, masks, row.HM)
			addMask(values, masks, row.PHM2)
			addMask(values, masks, row.PHM1)
			addMask(values, masks, row.VET)
			addMask(values, masks, row.CHA)
		end
    end
	
	for prefix, value in pairs(masks) do
		if(value ~= 0) then
			table.insert(values, prefix..value)
		end
	end
    
    -- Join all values with commas
    local qrstring = table.concat(values, ",")
	local cs = checksum(qrstring)
	return qrstring .. "," .. cs
end

-- Main QR generation function with compression option
function data.generateQR.get(useCompression)
    useCompression = useCompression or false
    
    screenName = data.savedVars.get('currentScreen')
    local tbl = {}
    
    -- Get the same filtered column data for both cases (your original logic)
    if screenName == 'Starter Dungeons' then
        local t1 = data.filterAchievements({TYPE='baseDungeon-wI'}, {'VET', 'HM', 'TYPE'})
        local t2 = data.filterAchievements({TYPE='baseDungeon-noI'}, {'VET', 'HM', 'TYPE'})
        tbl = utils.concatTables({t1, t2})
    
    elseif screenName == '4 Man Trifectas' then
        local t1 = data.filterAchievements({TYPE='triDungeon'}, {'VET', 'HM', 'CHA', 'TRI', 'TYPE'})
        local t2 = data.filterAchievements({ABBV='BRP'}, {'VET', 'HM', 'CHA', 'TRI', 'TYPE'})
        t2 = {t2} -- since BRP is a single row, we need to nest it in a table
        tbl = utils.concatTables({t1, t2})

    elseif screenName == 'Trials' then
		tbl = data.filterAchievements({TYPE='trial'}, {'VET', 'PHM1', 'PHM2', 'HM', 'TRI', 'EXT', 'TYPE'})
		
    elseif screenName == 'All Scores and Tris' then
        local t1 = data.filterAchievements({TYPE='trial'}, {'TRI', 'TYPE'})
        local t2 = data.filterAchievements({TYPE='arena'}, {'TRI', 'TYPE'})
        local t3 = data.filterAchievements({TYPE='endless'}, {'TRI', 'TYPE'})
        local t4 = data.filterAchievements({TYPE='triDungeon'}, {'TRI', 'TYPE'})
        tbl = utils.concatTables({t1, t2, t3, t4})
    end
    
    local qrString
    if useCompression then
        -- Apply compression logic to the filtered data
        qrString = data.generateQR.achievementsTableToCSVCompressed(tbl)
        debug("Compressed QR string: " .. qrString)
    else
        -- Include all completed achievements from the filtered data
        qrString = data.generateQR.achievementsTableToCSV(tbl)
        debug("Normal QR string: " .. qrString)
    end
    
    return qrString
end

-- Compressed version - now just calls main function with compression flag
function data.generateQR.getCompressed()
    return data.generateQR.get(true)
end 