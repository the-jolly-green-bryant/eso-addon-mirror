------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Furniture then MC.Furniture = ZO_Object:Subclass() end


------[[ Static Variables ]]------


local FurnitureIdCache = { }
local FurnitureIdCacheTimestamp = 0


local function round( n, dec ) return zo_roundToNearest( n, 1 / 10 ^ dec ) end


------[[ Constructors ]]------


function MC.Furniture:New( ... )

    local obj = ZO_Object.New( self )
    obj:Initialize( ... )
    return obj

end


function MC.Furniture:Initialize( ... )

	local p1 = select( 1, ... )
	if nil ~= p1 then

		if "number" == type( p1 ) then
			self:InitializeById( ... )
			return
		elseif "table" == type( p1 ) then
			self:InitializeByTable( ... )
			return
		end

	end

end


function MC.Furniture:InitializeById( furnitureId )

	local id, collectibleId, itemId
	local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureId )
	local fLink, cLink = GetPlacedFurnitureLink( furnitureId )

	if nil ~= x and nil ~= y and nil ~= z and ( 0 ~= x or 0 ~= y or 0 ~= z ) and ( "" ~= fLink or "" ~= cLink ) then

		if "" == cLink then
			id = furnitureId
			collectibleId = nil
			itemId = GetItemLinkItemId( fLink )
		else
			collectibleId = GetCollectibleIdFromFurnitureId( furnitureId )
		end

		self.Id = nil ~= id and Id64ToString( id ) or nil
		self.CId = collectibleId
		self.ItemId = itemId
		self.Original = {
			X = x,
			Y = y,
			Z = z,
			Yaw = yaw,
			Pitch = pitch,
			Roll = roll
		}

	end

end


function MC.Furniture:InitializeByTable( tbl )

	self.Id = tbl.Id
	self.CId = tbl.CId
	self.ItemId = tbl.ItemId
	self.Original = MC.CloneTable( tbl.Original )

end


------[[ Static Methods ]]------


function MC.Furniture:IsInstance( obj )

	return getmetatable( obj ) == self

end


function MC.Furniture:Cast( obj )

	if nil == obj or "table" ~= type( obj ) then return end
	setmetatable( obj, self )
	local mt = getmetatable( obj )
	mt.__index = self

end


function MC.Furniture:CastList( list )

	if nil == list or "table" ~= type( list ) then return end

	for index, obj in pairs( list ) do
		if not MC.Furniture:IsInstance( list[index] ) then
			MC.Furniture:Cast( list[index] )
		end
	end

end


function MC.Furniture:GetAllPlacedFurniture()

	local list = { }
	local id = nil

	repeat
		id = GetNextPlacedHousingFurnitureId( id )
		if nil ~= id then
			FurnitureIdCache[ Id64ToString( id ) ] = id
			table.insert( list, MC.Furniture:New( id ) )
		end
	until nil == id

	FurnitureIdCacheTimestamp = GetFrameTimeMilliseconds()
	return list

end


function MC.Furniture:RefreshFurnitureIdCache()

	if GetFrameTimeMilliseconds() == FurnitureIdCacheTimestamp then return end
	local id = nil

	repeat
		id = GetNextPlacedHousingFurnitureId( id )
		if nil ~= id then FurnitureIdCache[ Id64ToString( id ) ] = id end
	until nil == id

	FurnitureIdCacheTimestamp = GetFrameTimeMilliseconds()

end


function MC.Furniture:SearchItems( list, options )

	if nil == list or "table" ~= type( list ) then return nil end

	if nil == options or "table" ~= type( options ) then options = { } end
	local searchHouse, searchDistance, searchBackpack, searchBank = options.SearchHouse, options.SearchDistance, options.SearchBackpack, options.SearchBank
	local avgItemDistance, maxDistanceWeight = 0, 300000

	-- As the algorithm has been updated to prefer items
	-- nearest to the player at the time of activation,
	-- the search distance will be overriden to find any
	-- and all matching items.
	-- This should eliminate confusion on the users' part.
	searchDistance = 300000

	if nil == searchHouse then searchHouse = MC.Vars.Settings.SearchHouseItems end
	if nil == searchBackpack then searchBackpack = MC.Vars.Settings.SearchBackpackItems end
	if nil == searchBank then searchBank = MC.Vars.Settings.SearchBankItems end

	local totalItems, matchedItems, results = 0, 0, { }

	-- Construct a denormalized list for easier matching of inventory item stacks against the caller's required "grocery list" of items.

	for _, item in ipairs( list ) do
		if "string" == type( item ) then
			table.insert( results, {
				Link = item,
				Name = string.lower( MC.Furniture:GetName( item ) ),
				BagId = 0,
				FurnitureId = 0,
				CollectibleId = GetCollectibleIdFromLink( item )
			} )
		elseif "table" == type( item ) and 2 <= #item then
			local link, qty = item[1], item[2] or 1
			local name = string.lower( MC.Furniture:GetName( link ) )

			for i = 1, qty do
				table.insert( results, {
					Link = link,
					Name = name,
					BagId = 0,
					FurnitureId = 0,
					CollectibleId = GetCollectibleIdFromLink( link ),
					Distance = maxDistanceWeight
				} )
			end
		end
	end

	-- For convenience while in the players' own homes, pre-match any of the player's unlocked collectibles regardless of whether they are placed or how far away they may be.

	if MC.House:IsOwner() then
		local collectibleId, lockState
		local pX, pY, pZ = GetPlayerWorldPositionInHouse()

		for _, result in ipairs( results ) do
			collectibleId = result.CollectibleId

			if nil ~= collectibleId then
				lockState = GetCollectibleUnlockStateById( collectibleId )

				if lockState ~= COLLECTIBLE_UNLOCK_STATE_LOCKED then
					matchedItems = matchedItems + 1
					result.CollectibleAvailable = true

					local furnitureId = GetFurnitureIdFromCollectibleId( collectibleId )
					local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
					local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureId )

					if 0 ~= x or 0 ~= y or 0 ~= z then
						result.FurnitureId = furnitureId
						result.X, result.Y, result.Z, result.Pitch, result.Yaw, result.Roll, result.Distance = x, y, z, pitch, yaw, roll, zo_distance3D( x, y, z, pX, pY, pZ )
					end
				else
					result.CollectibleAvailable = false
				end
			end
		end
	end

	totalItems = #results

	-- Item Matcher

	local function MatchItems( link, furnitureId, bagId, slot, stackSize, x, y, z, pitch, yaw, roll, distance )
		local itemName = string.lower( MC.Furniture:GetName( link ) )
		local matches = 0
		if nil == stackSize or 0 >= stackSize then stackSize = 1 end

		for resultIndex, result in ipairs( results ) do
			if 0 == result.BagId and 0 == result.FurnitureId and itemName == result.Name then
				result.FurnitureId = furnitureId or 0
				result.BagId = bagId or 0
				result.Slot = slot or 0

				if nil ~= result.FurnitureId and 0 ~= result.FurnitureId then
					result.X, result.Y, result.Z, result.Pitch, result.Yaw, result.Roll, result.Distance = x, y, z, pitch, yaw, roll, distance or maxDistanceWeight
				end

				matches, stackSize = matches + 1, stackSize - 1
				if 0 >= stackSize then return matches end
			end
		end

		return matches
	end

	-- Search House Furniture

	if searchHouse then
		local idList = { }
		local pX, pY, pZ = GetPlayerWorldPositionInHouse()
		local id, x, y, z, pitch, yaw, roll, dist, fLink, cLink

		id = GetNextPlacedHousingFurnitureId( id )

		repeat
			if id then
				x, y, z = HousingEditorGetFurnitureWorldPosition( id )
				dist = zo_distance3D( x, y, z, pX, pY, pZ )

				if dist <= searchDistance then
					pitch, yaw, roll = HousingEditorGetFurnitureOrientation( id )
					table.insert( idList, { id, dist, x, y, z, pitch, yaw, roll } )
				end

				id = GetNextPlacedHousingFurnitureId( id )
			end
		until not id

		table.sort( idList, function( a, b )
			return a[2] < b[2]
		end )

		for _, item in ipairs( idList ) do
			id, dist, x, y, z, pitch, yaw, roll = item[1], item[2], item[3], item[4], item[5], item[6], item[7], item[8]
			fLink, cLink = GetPlacedFurnitureLink( id )

			if "" ~= cLink then
				matchedItems = matchedItems + MatchItems( cLink, id, nil, nil, nil, x, y, z, pitch, yaw, roll, dist )
			else
				matchedItems = matchedItems + MatchItems( fLink, id, nil, nil, nil, x, y, z, pitch, yaw, roll, dist )
			end

			if matchedItems >= totalItems then
				break
			end
		end

	end

	-- Search Bag(s) Furniture

	if searchBackpack or searchBank then
		local bagIds, link, stackSize = { }, nil, nil, nil

		if searchBackpack then
			table.insert( bagIds, BAG_BACKPACK )
		end

		if searchBank then
			table.insert( bagIds, BAG_BANK )
			table.insert( bagIds, BAG_SUBSCRIBER_BANK )
		end

		for _, bagId in ipairs( bagIds ) do
			if matchedItems >= totalItems then
				break
			end

			local bagSize = GetBagSize( bagId )
			for slotIndex = 0, bagSize do
				if matchedItems >= totalItems then
					break
				end

				link = GetItemLink( bagId, slotIndex )

				if "" ~= link then
					stackSize = GetSlotStackSize( bagId, slotIndex )
					matchedItems = matchedItems + MatchItems( link, nil, bagId, slotIndex, stackSize )
				end
			end
		end
	end

	local numResults = #results

	if 0 < numResults and matchedItems >= totalItems then
		avgItemDistance = 0

		for index = 1, numResults do
			avgItemDistance = avgItemDistance + results[index].Distance or maxDistanceWeight
		end

		avgItemDistance = avgItemDistance / numResults
	else
		avgItemDistance = math.huge
	end

	return matchedItems, totalItems, results, avgItemDistance

end


function MC.Furniture:CompareLinks( link1, link2 )

	local collectibleId, itemName1, itemName2

	collectibleId = GetCollectibleIdFromLink( link1 )
	if nil ~= collectibleId and 0 < collectibleId then
		itemName1 = string.lower( GetCollectibleName( collectibleId ) )
	else
		itemName1 = string.lower( GetItemLinkName( link1 ) )
	end

	collectibleId = GetCollectibleIdFromLink( link2 )
	if nil ~= collectibleId and 0 < collectibleId then
		itemName2 = string.lower( GetCollectibleName( collectibleId ) )
	else
		itemName2 = string.lower( GetItemLinkName( link2 ) )
	end

	return itemName1 == itemName2

end


------[[ Instance Methods ]]------


function MC.Furniture:GetFurnitureId()

	if nil ~= self.CId then
		local id = GetFurnitureIdFromCollectibleId( self.CId )
		if GetFurnitureIdFromCollectibleId( nil ) == id then return nil else return id end
	end

	if nil == self.Id then return nil end
	local id = FurnitureIdCache[ self.Id ]

	if nil == id then
		MC.Furniture:RefreshFurnitureIdCache()
		id = FurnitureIdCache[ self.Id ]
	end

	return id

end


function MC.Furniture:GetCollectibleId()

	return self.CId

end


function MC.Furniture:GetItemId()

	return self.CId or self.ItemId

end


function MC.Furniture:GetLink()

	if nil ~= self.CId then
		return GetCollectibleLink( self.CId )
	elseif nil ~= self.ItemId then
		return string.format( "|H1:item:%s%s|h|h", tostring( self.ItemId ), string.rep( ":0", 20 ) )
	end

end


function MC.Furniture:GetName( link )

	if nil == link or "" == link then

		local cId = self:GetCollectibleId()
		if nil ~= cId then
			return GetCollectibleName( cId )
		else
			return GetItemLinkName( self:GetLink() )
		end

	else

		local collectibleId = GetCollectibleIdFromLink( link )
		if nil ~= collectibleId and 0 < collectibleId then
			return GetCollectibleName( collectibleId )
		else
			return GetItemLinkName( link )
		end

	end

end


function MC.Furniture:GetIcon( link )

	if nil == link or "" == link then

		local cId = self:GetCollectibleId()
		if nil ~= cId then
			local _, _, icon = GetCollectibleInfo( cId )
			return icon
		else
			return GetItemLinkIcon( self:GetLink() )
		end

	else

		local cId = GetCollectibleIdFromLink( link )
		if nil ~= cId and 0 < cId then
			local _, _, icon = GetCollectibleInfo( cId )
			return icon
		else
			return GetItemLinkIcon( link )
		end

	end

end


function MC.Furniture:HasId()

	return nil ~= self:GetFurnitureId()

end


function MC.Furniture:IsValid()

	return nil ~= self:GetPosition()

end


function MC.Furniture:IsCollectible()

	return nil ~= self:GetCollectibleId()

end


-- INPUT:	Comparison item in the form of either:
--			 - (String)	Link
--			 - (Number)	Furniture Id
--			 - (Table)	Furniture object
-- RETURN:	True, if both items share the same Item Name.
function MC.Furniture:CompareTo( obj )

	if nil == obj then return false end
	local itemName = string.lower( self:GetName() )

	if "string" == type( obj ) then
		-- Comparison via Link
		local itemName2 = GetItemLinkName( obj )
		return string.lower( itemName2 ) == itemName
	elseif "number" == type( obj ) then
		-- Comparison via Furniture Id
		local itemName2 = GetPlacedHousingFurnitureInfo( obj )
		return string.lower( itemName2 ) == itemName
	elseif "table" == type( obj ) and MC.Furniture:IsInstance( obj ) then
		-- Comparison via Furniture object
		return string.lower( obj:GetName() ) == itemName
	end

	return false

end


function MC.Furniture:GetLimitType( link )

	if nil == link or "" == link then link = self:GetLink() end
	if nil == link or "" == link then return nil end

	local collectibleId = GetCollectibleIdFromLink( link )
	local itemId = GetItemLinkItemId( link )
	if ( nil == collectibleId or 0 >= collectibleId ) and ( nil == itemId or 0 >= itemId ) then return nil end

	local dataId
	if nil ~= collectibleId and 0 < collectibleId then
		dataId = GetCollectibleFurnitureDataId( collectibleId )
	else
		dataId = GetItemLinkFurnitureDataId( link )
	end

	local limitType, limitName = nil, nil
	if nil ~= dataId then
		_, _, _, limitType = GetFurnitureDataInfo( dataId )
		limitName = MC.House:GetLimitName( limitType )
	end

	return limitType, limitName

end


function MC.Furniture:GetPosition()

	local x, y, z = HousingEditorGetFurnitureWorldPosition( self:GetFurnitureId() )
	if 0 ~= x or 0 ~= y or 0 ~= z then return x, y, z end
	return nil

end


function MC.Furniture:GetOrientation()

	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( self:GetFurnitureId() )
	return pitch, yaw, roll

end


function MC.Furniture:GetPositionAndOrientation()

	local x, y, z = self:GetPosition()
	if nil == x then return nil end

	local pitch, yaw, roll = self:GetOrientation()
	return x, y, z, pitch, yaw, roll

end


local function SetPositionOrOrientation( id, x, y, z, pitch, yaw, roll )

	if nil == id then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	local cX, cY, cZ, cPitch, cYaw, cRoll
	local posChanged, orientChanged = false, false

	if nil ~= x or nil ~= y or nil ~= z then
		cX, cY, cZ = HousingEditorGetFurnitureWorldPosition( id )
		if math.floor( cX ) ~= math.floor( x ) or math.floor( cY ) ~= math.floor( y ) or math.floor( cZ ) ~= math.floor( z ) then posChanged = true end
	end

	if nil ~= pitch or nil ~= yaw or nil ~= roll then
		cPitch, cYaw, cRoll = HousingEditorGetFurnitureOrientation( id )
		cPitch, cYaw, cRoll = cPitch % ( 2 * math.pi ), cYaw % ( 2 * math.pi ), cRoll % ( 2 * math.pi )
		pitch, yaw, roll = pitch % ( 2 * math.pi ), yaw % ( 2 * math.pi ), roll % ( 2 * math.pi )
		if math.floor( 1000 * cPitch ) ~= math.floor( 1000 * pitch ) or math.floor( 1000 * cYaw ) ~= math.floor( 1000 * yaw ) or math.floor( 1000 * cRoll ) ~= math.floor( 1000 * roll ) then orientChanged = true end
	end

	if posChanged or orientChanged then
		if EHT and EHT.Interop and EHT.Interop.SuppressFurnitureChange then
			EHT.Interop.SuppressFurnitureChange( id )
		end
	end

	if posChanged and orientChanged then
		return HousingEditorRequestChangePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
	elseif posChanged then
		return HousingEditorRequestChangePosition( id, x, y, z )
	elseif orientChanged then
		return HousingEditorRequestChangeOrientation( id, pitch, yaw, roll )
	end
	
	return HOUSING_REQUEST_RESULT_SUCCESS

end


function MC.Furniture:SetPosition( x, y, z )

	if not self:HasId() then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	local currentX, currentY, currentZ
	if nil == x or nil == y or nil == z then
		currentX, currentY, currentZ = self:GetPosition()
	end

	return SetPositionOrOrientation( self:GetFurnitureId(), x or currentX, y or currentY, z or currentZ )

end


function MC.Furniture:SetOrientation( pitch, yaw, roll )

	if not self:HasId() then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	local currentPitch, currentYaw, currentRoll
	if nil == pitch or nil == yaw or nil == roll then
		currentPitch, currentYaw, currentRoll = self:GetOrientation()
	end

	return SetPositionOrOrientation( self:GetFurnitureId(), nil, nil, nil, pitch or currentPitch, yaw or currentYaw, roll or currentRoll )

end


function MC.Furniture:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )

	if not self:HasId() then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	local currentX, currentY, currentZ
	if nil == x or nil == y or nil == z then
		currentX, currentY, currentZ = self:GetPosition()
	end

	local currentPitch, currentYaw, currentRoll
	if nil == pitch or nil == yaw or nil == roll then
		currentPitch, currentYaw, currentRoll = self:GetOrientation()
	end

	return SetPositionOrOrientation( self:GetFurnitureId(), x or currentX, y or currentY, z or currentZ, pitch or currentPitch, yaw or currentYaw, roll or currentRoll )

end


function MC.Furniture:AdjustPositionAndOrientation( x, y, z, pitch, yaw, roll )

	if not self:HasId() then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	local currentX, currentY, currentZ, currentPitch, currentYaw, currentRoll = self:GetPositionAndOrientation()
	if nil == currentX then return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE end

	x, y, z = x and ( x + currentX ) or currentX, y and ( y + currentY ) or currentY, z and ( z + currentZ ) or currentZ
	pitch, yaw, roll = pitch and ( pitch + currentPitch ) or currentPitch, yaw and ( yaw + currentYaw ) or currentYaw, roll and ( roll + currentRoll ) or currentRoll

	return SetPositionOrOrientation( self:GetFurnitureId(), x, y, z, pitch, yaw, roll )

end
