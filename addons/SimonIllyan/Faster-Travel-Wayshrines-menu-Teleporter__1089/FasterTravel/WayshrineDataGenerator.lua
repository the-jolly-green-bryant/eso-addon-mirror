
local Utils = FasterTravel.Utils

local function CreateNodesLookup(nodes,...)
	local count = select('#',...)
	local lookup ={}
	local key
	table.sort(nodes,function(x,y) return x.nodeIndex < y.nodeIndex end) 
	for i=1,count do
		key = select(i,...)
		lookup[key] = nodes[i]
	end 
	return lookup
end

local function UpdateLookup(lookup)
	-- corrections where names differ ={ - for english client only 
	-- poi name | fast travel node name
	local keys = {	
		-- general world wayshrines
		"baandari post wayshrine","baandari tradepost wayshrine",
		"bloodtoil valley wayshrine","bloodtoil wayshrine",
		"wilding vale wayshrine","wilding run wayshrine",
		"camp tamrith wayshrine","tamrith camp wayshrine",
		"seaside sanctuary wayshrine","seaside sanctuary",
		"eyevea wayshrine","eyevea",
		
		-- cyrodiil 
		"north morrowind gate wayshrine","north morrowind wayshrine",
		"south morrowind gate wayshrine","south morrowind wayshrine",
		"western elsweyr gate wayshrine","western elsweyr wayshrine",
		"eastern elsweyr gate wayshrine","eastern elsweyr wayshrine",
		"north highrock gate wayshrine","northern high rock wayshrine",
		"south highrock gate wayshrine","southern high rock wayshrine",
		
		-- trials
		"trial: aetherian archive","aetherian archive wayshrine",
		"trial: hel ra citadel", "hel ra citadel wayshrine",
		"trial: sanctum ophidia","sanctum ophidia wayshrine",
	}
	
	local poiKey,nodeKey 
	for i = 1, #keys-1, 2 do
		poiKey,nodeKey = keys[i],keys[i+1]
		lookup[poiKey] = lookup[nodeKey]
	end
		
	-- correction to handle multiple harborages
	local harborage = lookup["the harborage"]
	if harborage ~= nil and harborage.nodes ~= nil then 
		-- not convinced order can be relied on >_<
		harborage.nodes = CreateNodesLookup(harborage.nodes,2,178,9)
	end
	
	return lookup
end 


local function UpdateNode(item,zoneIndex)
	if item ~= nil and zoneIndex ~= nil and item.nodes ~= nil then -- handle multiple nodes - a manual lookup is required >_<
		local node = item.nodes[zoneIndex]
		if node ~= nil then 
			item = Utils.extend(node) -- shallow copy 
			item.nodes = nil -- drop reference to nodes in copy 
		end 
	end 
	return item
end 


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

local function GetNodesLookup()
	local lookup = {}
	
	local key, node
	
	for index,known,name,normalizedX, normalizedY, textureName ,textureName,poiType,isShown in GetNodes() do
		
		key = string.lower(name)
		node = lookup[key]
		
		if Utils.stringIsEmpty(name) == false then
			local curNode = {	
					nodeIndex=index,
					known=known,
					name=name,
					normalizedX=normalizedX, 
					normalizedY=normalizedY, 
					textureName=textureName ,
					poiType=poiType,
					isShown=isShown 
				}
		
			if node == nil then 
				node = curNode
				lookup[key] = node
			else -- accumulate additional nodes where there are multiple nodes of the same name e.g The harborage.
				if node.nodes == nil then 
					node.nodes = {Utils.extend(node)}
				end 
				table.insert(node.nodes,curNode)
			end
			
		end
	end
	
	lookup = UpdateLookup(lookup)
	
	return lookup
end

local function GetItemFromLookup(lookup,name,zoneIndex)
	if Utils.stringIsEmpty(name) == true then return nil end
	local item = lookup[string.lower(name)]
	
	item = UpdateNode(item,zoneIndex)
	
	return item 
end


local function GetNodesByZoneIndex(zoneIndex)
	zoneIndex = zoneIndex or GetCurrentMapZoneIndex()

	local i = 0
	local count = GetNumPOIs(zoneIndex)
	local lookup = GetNodesLookup()
	local name
	local item 
	
	return function()
		
		while i < count do
			i = i + 1

			name = GetPOIInfo(zoneIndex, i)

			item = GetItemFromLookup(lookup,name,zoneIndex)
			
			if item ~= nil then 
				item.poiIndex = i 
				item.zoneIndex = zoneIndex
				return item
			end
			
		end
		
		return nil
	end
end

local function GetNodesZoneLookup(locations,func)
	func = func or GetNodesByZoneIndex
	local lookup ={}
	for i,loc in ipairs(locations) do 
		lookup[loc.zoneIndex] = Utils.toTable(func(loc.zoneIndex))
	end 
	return lookup
end


local function Generate(locations)
	local lookup = GetNodesZoneLookup(locations)
	
	local newLookup = {}
	
	for zoneIndex,nodes in pairs(lookup) do 
		newLookup[zoneIndex]={}
		df("  [%d] = {", zoneIndex)
		for i,node in ipairs(nodes) do
			df("    { poiIndex = %d, nodeIndex = %d },", node.poiIndex, node.nodeIndex)
			table.insert(newLookup[zoneIndex],{nodeIndex = node.nodeIndex, poiIndex = node.poiIndex})
		end 
		d("  },")
	end 
	return newLookup
end 


FasterTravel.WayshrineDataGenerator = {
	Generate = Generate,
	GetNodesZoneLookup = GetNodesZoneLookup,
	GetNodesByZoneIndex = GetNodesByZoneIndex,
}


