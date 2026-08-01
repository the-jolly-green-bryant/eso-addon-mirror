local Utils = FasterTravel.Utils

local Data = {}

local trader_counts = { -- nodeIndex -> traders_count
    [  1] = 1, -- Wyrd Tree Wayshrine
    [  6] = 1, -- Lion Guard Redoubt Wayshrine
    [  9] = 1, -- Oldgate Wayshrine
    [ 14] = 1, -- Koeglin Village Wayshrine
    [ 16] = 1, -- Firebrand Keep Wayshrine
    [ 25] = 1, -- Muth Gnaar Hills Wayshrine
    [ 28] = 7, -- Mournhold Wayshrine
    [ 29] = 1, -- Tal'Deic Grounds Wayshrine
    [ 33] = 5, -- Evermore Wayshrine
    [ 36] = 1, -- Bangkorai Pass Wayshrine
    [ 38] = 1, -- Hallin's Stand Wayshrine
    [ 42] = 1, -- Morwha's Bounty Wayshrine
    [ 43] = 5, -- Sentinel Wayshrine
    [ 44] = 1, -- Bergama Wayshrine
    [ 48] = 5, -- Stormhold Wayshrine
    [ 52] = 1, -- Hissmir Wayshrine
    [ 55] = 5, -- Shornhelm Wayshrine
    [ 56] = 7, -- Wayrest Wayshrine
    [ 62] = 5, -- Daggerfall Wayshrine
    [ 65] = 1, -- Davon's Watch Wayshrine
    [ 67] = 5, -- Ebonheart Wayshrine
    [ 76] = 1, -- Kragenmoor Wayshrine
    [ 78] = 1, -- Venomous Fens Wayshrine
    [ 84] = 1, -- Hoarfrost Downs Wayshrine
    [ 87] = 5, -- Windhelm Wayshrine
    [ 90] = 1, -- Voljar Meadery Wayshrine
    [ 92] = 1, -- Fort Amol Wayshrine
    [101] = 1, -- Dra'bul Wayshrine
    [106] = 5, -- Baandari Post Wayshrine
    [107] = 1, -- Valeguard Wayshrine
    [110] = 5, -- Skald's Retreat Wayshrine
    [114] = 1, -- Fallowstone Hall Wayshrine
    [118] = 1, -- Nimalten Wayshrine
    [121] = 5, -- Skywatch Wayshrine
    [131] = 4, -- Hollow City Wayshrine
    [135] = 1, -- Haj Uxith Wayshrine
    [138] = 1, -- Port Hunding Wayshrine
    [142] = 2, -- Mistral Wayshrine
    [143] = 5, -- Marbruk Wayshrine
    [144] = 1, -- Vinedusk Wayshrine
    [146] = 1, -- Court of Contempt Wayshrine
    [147] = 1, -- Greenheart Wayshrine
    [151] = 1, -- Verrant Morass Wayshrine
    [159] = 1, -- Dune Wayshrine
    [162] = 5, -- Rawl'kha Wayshrine
    [167] = 1, -- Southpoint Wayshrine
    [168] = 1, -- Cormount Wayshrine
    [172] = 1, -- Bleakrock Wayshrine
    [173] = 1, -- Dhalmora Wayshrine
    [175] = 1, -- Firsthold Wayshrine
    [177] = 1, -- Vulkhel Guard Wayshrine
    [181] = 1, -- Stonetooth Wayshrine
    [214] = 7, -- Elden Root Wayshrine
    [220] = 7, -- Belkarth Wayshrine
    [240] = 4, -- Morkul Plain Wayshrine
    [244] = 6, -- Orsinium Wayshrine
    [251] = 3, -- Anvil Wayshrine
    [252] = 3, -- Kvatch Wayshrine
    [255] = 7, -- Abah's Landing Wayshrine
    [275] = 3, -- Balmora Wayshrine
    [281] = 3, -- Sadrith Mora Wayshrine
    [284] = 6, -- Vivec City Wayshrine
    [337] = 6, -- Brass Fortress Wayshrine
    [350] = 3, -- Shimmerene Wayshrine
    [355] = 6, -- Alinor Wayshrine
    [356] = 3, -- Lillandril Wayshrine
    [374] = 6, -- Lilmoth Wayshrine
    [382] = 6, -- Rimmen Wayshrine
    [402] = 6, -- Senchal Wayshrine
    [421] = 6, -- Solitude Wayshrine
    [449] = 6, -- Markarth Wayshrine 
    [458] = 6, -- Leyawiin Wayshrine
    [493] = 6, -- Fargrave Wayshrine
    [513] = 6, -- Gonfalon Square Wayshrine
    [529] = 6, -- Vastyr Wayshrine
    [536] = 6, -- Necrom Wayshrine
    [558] = 6, -- Skingrad City Wayshrine
    [598] = 6, -- Sunport Wayshrine
}

local _zoneNodeLookup = {
    [-2147483648]  = { }, -- is this still needed?
}

local _zoneNodeCache = { }

-- cache for formatted wayshrine names
local _nodeNameCache = { }


local function FillWayshrines()
	local allNodes = {}

	local function InsertExtraWayshrine(zoneId, nodeIndex)
		for name, node in pairs(allNodes) do
			if node.nodeIndex == nodeIndex then	
				-- create an artificial POI with index 0
				local poi = { 
					poiIndex = 0, 
					nodeIndex = nodeIndex,
					name = node.nodeName,
				}
				-- and insert it in the right zone
				local zoneMap = _zoneNodeLookup[zoneId]
				if zoneMap then
					table.insert(zoneMap, poi)
				end
				return
			end
		end
	end

	local nodeName
	for cur = 1, GetNumFastTravelNodes() do
		_, nodeName, _, _, _, _, _, _, _  = GetFastTravelNodeInfo(cur)
		allNodes[Utils.BareName(nodeName)] = {	
			nodeIndex=cur,
			nodeName=nodeName,
		}
	end
	for zoneId = 1, 3000 do
		local zoneName = GetZoneNameById(zoneId)
		if zoneName ~= nil and zoneName ~= "" then
			local zoneIndex = GetZoneIndex(zoneId)
			local numPOIs = GetNumPOIs(zoneIndex)
			local zoneMap = {}
			for poiIndex = 1, numPOIs do
				local nodeName = GetPOIInfo(zoneIndex, poiIndex) -- might be wrong - "X" instead of "Dungeon: X"!
				local node = allNodes[Utils.BareName(nodeName)]  -- that's why we use BareName to strip prefix
				if nodeName ~= "" and node ~= nil  then -- teleportable POI
					-- fix "Darkshade Caverns I" being returned for both DC1 and DC2
					if zoneId == 57 and poiIndex == 60 then -- zone Deshaan, POI 60 is DC2!
						for k, v in pairs(allNodes) do
							if v.nodeIndex == 264 then
								node = v
							end
						end
					end
					local poi = {
						poiIndex = poiIndex, 
						nodeIndex = node.nodeIndex,
						name = node.nodeName, -- node contains correct name… as far as I know :->
					}
					table.insert(zoneMap, poi)
				end
			end
			if #zoneMap > 0 then
				_zoneNodeLookup[zoneId] = zoneMap
			end
		end
	end
	-- extra wayshrines that do not have POI numbers in their zones:
	InsertExtraWayshrine(684, 250)  -- Wrothgar, Maelstrom Arena
	InsertExtraWayshrine(726, 378)  -- Murkmire, Black Rose Prison
	InsertExtraWayshrine(1207, 457) -- The Reach, Vateshran Hollows
	InsertExtraWayshrine(1443, 572) -- West Weald, The Scholarium
	InsertExtraWayshrine(267, 215)  -- Eyevea
	
end

local function GetNodeName(nodeIndex,name)
    local localeName = _nodeNameCache[nodeIndex]

    if localeName == nil then
        localeName = Utils.FormatStringCurrentLanguage(name)
        _nodeNameCache[nodeIndex] = localeName
    end

    return localeName
end

--[ changed in 2.9.0 to get around constant zoneindex changes ]]--
local function GetNodesByZoneIndex(zoneIndex)
    if zoneIndex ~= nil then
		-- lookup by zoneIndex
        local nodes = _zoneNodeCache[zoneIndex]
        if nodes ~= nil then
            return Utils.copy(nodes)
		end
		-- lookup by zoneId
		local zoneId = GetZoneId(zoneIndex)
		if zoneId ~= nil then
			nodes = _zoneNodeLookup[zoneId]
			if nodes ~= nil then
				-- changed in 3.0.0 
				-- add traders info from trader_counts 
				for i, node in ipairs(nodes) do
					local nodeIndex = node.nodeIndex 
					if trader_counts[nodeIndex] ~= nil then
						node.traders_cnt = trader_counts[nodeIndex]
					end
				end
				-- update cache
				_zoneNodeCache[zoneIndex] = nodes
				return Utils.copy(nodes)
			end
		end
    end
    return {}
end

local function GetNodeInfo(nodeIndex)
    if nodeIndex == nil then return nil end
    local  known, name, normalizedX, normalizedY, textureName, textureName, poiType, isShown = GetFastTravelNodeInfo(nodeIndex)
    name = GetNodeName(nodeIndex, name)
    return known, name, normalizedX, normalizedY, textureName, textureName, poiType, isShown
end

Data.GetNodesByZoneIndex = GetNodesByZoneIndex
Data.GetNodeInfo = GetNodeInfo
Data.FillWayshrines = FillWayshrines

FasterTravel.Wayshrine.Data = Data
