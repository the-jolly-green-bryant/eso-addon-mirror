------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.House then MC.House = ZO_Object:Subclass() end


------[[ Locals ]]------


local LIMIT_TYPES = { }
LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_COLLECTIBLE ] = "Special Collectibles"
LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM ] = "Special Furnishings"
LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_COLLECTIBLE ] = "Collectible Furnishings"
LIMIT_TYPES[ HOUSING_FURNISHING_LIMIT_TYPE_LOW_IMPACT_ITEM ] = "Traditional Furnishings"


------[[ Constructors ]]------


function MC.House:New( ... )

    local obj = ZO_Object.New( self )
    obj:Initialize( ... )
    return obj

end


function MC.House:Initialize( ... )

	local p1 = select( 1, ... )
	if nil ~= p1 then

		if "number" == type( p1 ) then
			self:InitializeById( ... )
			return
		elseif "table" == type( p1 ) then
			self:InitializeByTable( ... )
			return
		end

	else

		self:InitializeCurrentHouse()
		return

	end

end


function MC.House:InitializeCurrentHouse()

	local houseId = GetCurrentZoneHouseId()
	if nil == houseId or 0 >= houseId then return end

	local owner = GetCurrentHouseOwner()
	local isOwner = IsOwnerOfCurrentHouse()

	self:InitializeById( houseId, owner, isOwner )

end


function MC.House:InitializeById( houseId, owner, isOwner )

	self.HouseId = houseId
	self.Owner = owner
	self.IsHouseOwner = isOwner

end


function MC.House:InitializeByTable( tbl )

	self.HouseId = tbl.HouseId
	self.Owner = tbl.Owner
	self.IsHouseOwner = tbl.IsHouseOwner

end


------[[ Static Methods ]]------


function MC.House:IsInstance( obj )

	return getmetatable( obj ) == self

end


function MC.House:Cast( obj )

	if nil == obj or "table" ~= type( obj ) then return end
	setmetatable( obj, self )
	local mt = getmetatable( obj )
	mt.__index = self

end


function MC.House:CastList( list )

	if nil == list or "table" ~= type( list ) then return end

	for index, obj in pairs( list ) do
		if not MC.House:IsInstance( list[index] ) then
			MC.House:Cast( list[index] )
		end
	end

end


function MC.House:CanEditCurrentHouse()

	return HasAnyEditingPermissionsForCurrentHouse()

end


function MC.House:IsCurrentlyInAHouse()

	return 0 < GetCurrentZoneHouseId()

end


function MC.House:GetLimitName( limitType )

	return LIMIT_TYPES[ limitType ] or ""

end


function MC.House:GetCurrentLimit( limitType )

	local houseId = GetCurrentZoneHouseId()
	if nil == houseId or 0 == houseId then return end

	local limitMax, limitUsed, limitName = 0, 0, nil
	limitMax = GetHouseFurnishingPlacementLimit( houseId, limitType )
	limitUsed = GetNumHouseFurnishingsPlaced( limitType )
	limitName = MC.House:GetLimitName( limitType )

	return limitName, limitMax, limitUsed

end


function MC.House:GetCurrentLimits()

	local houseId = GetCurrentZoneHouseId()
	if nil == houseId or 0 == houseId then return nil end

	local limits = { }
	local limitMax, limitUsed, limitName = 0, 0, nil

	for limitType = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		limitName, limitMax, limitUsed = MC.House:GetCurrentLimit( limitType )
		limits[ limitType ] = { Type = limitType, Name = limitName, Max = limitMax, Used = limitUsed }
	end

	return limits

end


------[[ Instance Methods ]]------


function MC.House:GetHouseId()

	if self == MC.House then
		return GetCurrentZoneHouseId()
	else
		return self.HouseId
	end

end


function MC.House:GetCollectibleId()

	return GetCollectibleIdForHouse( self:GetHouseId() )

end


function MC.House:GetName()

	return GetCollectibleName( self:GetCollectibleId() )

end


function MC.House:GetOwner()

	if self == MC.House then
		return GetCurrentHouseOwner()
	else
		return self.Owner
	end

end


function MC.House:IsOwner()

	if self == MC.House then
		return IsOwnerOfCurrentHouse()
	else
		return self.IsHouseOwner
	end

end
