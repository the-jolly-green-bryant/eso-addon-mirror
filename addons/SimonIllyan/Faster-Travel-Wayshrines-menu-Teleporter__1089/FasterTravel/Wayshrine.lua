
local Wayshrine = FasterTravel.Wayshrine or {}
local Utils = FasterTravel.Utils

local function GetNodes()
	local cur = 0
	local count = GetNumFastTravelNodes()
	return function()
		if cur < count then	
			cur = cur + 1
			return cur,GetFastTravelNodeInfo(cur)
		end
		return nil
	end
end

local function GetNodesByZoneIndex(zoneIndex)

	local nodes = Wayshrine.Data.GetNodesByZoneIndex(zoneIndex)
	
	local known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown
	
	local cur = 0 
	local count = #nodes
	
	return function()
		if cur < count then 
			cur = cur + 1
	
			local node = nodes[cur]
	
			local known, name, normalizedX, normalizedY, textureName, textureName, poiType, isShown = Wayshrine.Data.GetNodeInfo(node.nodeIndex)
			
			return {
					zoneIndex=zoneIndex,
					nodeIndex=node.nodeIndex,
					poiIndex=node.poiIndex,
					traders_cnt=node.traders_cnt,
					known=known,
					name=Utils.ShortName(name),
					barename=Utils.BareName(name),
					normalizedX=normalizedX, 
					normalizedY=normalizedY, 
					textureName=textureName,
					poiType=poiType,
					isShown=isShown,
				}
		end
	end 
end

local function GetKnownWayshrinesByZoneIndex(zoneIndex, nodeIndex)
	local iter = GetNodesByZoneIndex(zoneIndex)
	
	iter = Utils.where(iter,
		function(item)
			return item.known and (nodeIndex == nil or item.nodeIndex ~= nodeIndex)
		end)
	return iter
end

local function GetNodesZoneLookup(locations,func)
	func = func or GetNodesByZoneIndex
	local lookup = {}
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = Utils.toTable(func(loc.zoneIndex))
	end 
	return lookup
end

Wayshrine.GetNodes = GetNodes
Wayshrine.GetNodesByZoneIndex = GetNodesByZoneIndex
Wayshrine.GetKnownWayshrinesByZoneIndex = GetKnownWayshrinesByZoneIndex
Wayshrine.GetNodesZoneLookup = GetNodesZoneLookup

Wayshrine.GetKnownNodesZoneLookup = function(locations)
	return GetNodesZoneLookup(locations,GetKnownWayshrinesByZoneIndex)
end 

FasterTravel.Wayshrine = Wayshrine
