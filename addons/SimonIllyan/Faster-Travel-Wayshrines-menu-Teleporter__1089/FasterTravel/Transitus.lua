
local Transitus = {}

local Utils = FasterTravel.Utils
local ZONE_INDEX_CYRODIIL = FasterTravel.Location.Data.ZONE_INDEX_CYRODIIL

local function GetUnderAttackPinForKeepPin(pinType)
	return ZO_WorldMap_GetUnderAttackPinForKeepPin(pinType)
end

local _keepNames = {}

local function GetNodeInfo(ctx,nodeIndex)

	local keepId, accessible, normalizedX,  normalizedY = GetKeepTravelNetworkNodeInfo(nodeIndex,ctx)

	local pinType,nx,ny  = GetKeepPinInfo(keepId, ctx)

	if normalizedX == 0 and normalizedY == 0 then
		normalizedX,normalizedY = nx,ny
	end

	local name = _keepNames[keepId]

	if name == nil then
		name = Utils.FormatStringCurrentLanguage(GetKeepName(keepId))
		_keepNames[keepId] = name
	end

	local alliance =  GetKeepAlliance(keepId,ctx)

	accessible = accessible or GetKeepAccessible(keepId,ctx)

	local underAttack = GetHistoricalKeepUnderAttack(keepId, ctx, 1)

	if underAttack == true then
		pinType = GetUnderAttackPinForKeepPin(pinType)
	end

	local node = {
		nodeIndex = keepId,
		zoneIndex = ZONE_INDEX_CYRODIIL,
		name=name,
		known=accessible,
		alliance=alliance,
		normalizedX=normalizedX,
		normalizedY=normalizedY,
		isTransitus = true,
		pinType=pinType,
		underAttack = underAttack
		}
	return node
end

local function GetNodes(ctx)

	ZO_WorldMap_RefreshKeeps()

	ctx = ctx or ZO_WorldMap_GetBattlegroundQueryType()

	local nodes = {}

	local count = GetNumKeepTravelNetworkNodes(ctx)

	local node

	for i=1,count do

		node = GetNodeInfo(ctx,i)

		table.insert(nodes, node)

	end

	table.sort(nodes,function(x,y)

		return x.name < y.name

	end)

	return nodes
end

local function GetKnownNodes(nodeIndex,known,ctx)

	local nodes = GetNodes(ctx)

	nodes = Utils.where(nodes,function(node)
		return (known == nil or node.known == known) and (nodeIndex == nil or node.nodeIndex ~= nodeIndex)
	end)

	return nodes
end

Transitus.GetNodeInfo = GetNodeInfo
Transitus.GetNodes = GetNodes
Transitus.GetKnownNodes = GetKnownNodes

FasterTravel.Transitus = Transitus
