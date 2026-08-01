if not EHT then EHT = { } end
if not EHT.Housing then EHT.Housing = { } end
local matrix = EHT.Matrix

local RAD45, RAD90, RAD120, RAD180, RAD240, RAD270, RAD360 = math.rad( 45 ), math.rad( 90 ), math.rad( 120 ), math.rad( 180 ), math.rad( 240 ), math.rad( 270 ), math.rad( 360 )
local ceil, floor, min, max, cos, sin, rad, deg = math.ceil, math.floor, math.min, math.max, math.cos, math.sin, math.rad, math.deg
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
math.roundInt = function( n ) return 0 < n and math.ceil( n ) or math.floor( n ) end
local GIMBAL_OFFSET = math.rad( 0.02 )
local MAX_AABB_DIMENSION = 2000

PATH_NODE_DIMENSIONS = { 190, 10, 224 }
PATH_NODE_OFFSETS = { 0, 0, 0 }

EHT.BASE_EFFECT_ITEM_TYPE_ID = 1000000
EHT.LINK_UNKNOWN_EFFECT = string.format( "|H1:effect%s|h|h", string.rep( ":0", 4 ) )
EHT.LINK_UNKNOWN_ITEM = string.format( "|H1:item%s|h|h", string.rep( ":0", 20 ) )

EHT.UnitPositions = { }
local unitPositions = EHT.UnitPositions

for index = 0, GROUP_SIZE_MAX do
	unitPositions[ index ] = { 0, 0, 0 }
end

EHT.FurnitureCache = { }

---[ Orientation ]---

local OrientationWin, OrientationTex

local function SetupOrientation()
	if not OrientationWin then
		local w = WINDOW_MANAGER:CreateTopLevelWindow( "EHTOrientation" )
		OrientationWin = w
		w:SetHidden( false )
		w:SetDimensions( 1, 1 )
		w:SetMovable( true )
		w:SetMouseEnabled( false )
		w:SetClampedToScreen( false )
		w:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, -10, -10 )
		w:Create3DRenderSpace()
	end

	if not OrientationTex then
		local t = WINDOW_MANAGER:CreateControl( nil, OrientationWin, CT_TEXTURE )
		OrientationTex = t
		t:SetHidden( true )
		t:Create3DRenderSpace()
		t:Set3DRenderSpaceOrigin( 0, 0, 0 )
		t:Set3DRenderSpaceOrientation( 0, 0, 0 )
	end

	return OrientationTex, OrientationWin
end

function EHT.Housing.TransformOrientation( pitch, yaw, roll, oPitch, oYaw, oRoll )
	local t = OrientationTex or SetupOrientation()
	t:Set3DRenderSpaceOrientation( oPitch, oYaw, oRoll )
	return t:Convert3DLocalOrientationToWorldOrientation( pitch, yaw, roll )
end

function EHT.Housing.TransformVector( pitch, yaw, roll, x, y, z )
	local t = OrientationTex or SetupOrientation()
	t:Set3DRenderSpaceOrigin( 0, 0, 0 )
	t:Set3DRenderSpaceOrientation( pitch, yaw, roll )
	return t:Convert3DLocalPositionToWorldPosition( x, y, z )
end

function EHT.Housing.OnWorldChange()
	local t, w = SetupOrientation()

	w:Destroy3DRenderSpace()
	w:Create3DRenderSpace()

	t:Destroy3DRenderSpace()
	t:Create3DRenderSpace()
end

---[ Housing : Geometry and Matrix Math ]---

function EHT.Housing.VectorCrossProduct( x1, y1, z1, x2, y2, z2 )
	local x = y1 * z2 - y2 * z1
	local y = z1 * x2 - z2 * x1
	local z = x1 * y2 - x2 * y1

	return x, y, z
end

function EHT.Housing.CorrectGimbalLock( pitch, yaw, roll, reserved, id )
	pitch, yaw, roll = (pitch or 0) % RAD360, (yaw or 0) % RAD360, (roll or 0) % RAD360

	if id and EHT.Housing.IsEffectId(id) then
		return pitch, yaw, roll
	end

	if 0 ~= pitch and RAD360 ~= pitch and 0 == pitch % RAD90 then
		pitch = pitch + GIMBAL_OFFSET
	end

	return pitch, yaw, roll
end

function EHT.Housing.ReverseGimbalLockCorrection( pitch, yaw, roll )
	pitch, yaw, roll = pitch % RAD360, yaw % RAD360, roll % RAD360
	return pitch, yaw, roll
end

function EHT.Housing.OrderItemIdsByPosition( itemIds )
	if "table" ~= type( itemIds ) then return { } end
	if 1 >= #itemIds then return itemIds end

	local minX, minY, minZ, maxX, maxY, maxZ = math.huge, math.huge, math.huge, -99999, -99999, -99999
	local items = { }
	local x, y, z

	for index, id in ipairs( itemIds ) do
		x, y, z = EHT.Housing.GetFurniturePosition( id )
		x, y, z = x or 0, y or 0, z or 0

		table.insert( items, { Id = id, X = x, Y = y, Z = z } )

		minX, minY, minZ = math.min( minX, x ), math.min( minY, y ), math.min( minZ, z )
		maxX, maxY, maxZ = math.max( maxX, x ), math.max( maxY, y ), math.max( maxZ, z )
	end

	local centerX, centerY, centerZ = 0.5 * ( minX + maxX ), 0.5 * ( minY + maxY ), 0.5 * ( minZ + maxZ )

	for index, item in ipairs( items ) do
		item.X, item.Y, item.Z = item.X - centerX, item.Y - centerY, item.Z - centerZ
		item.Rank = EHT.World:GetNormalVector( item.X, item.Y, item.Z ) -- math.sin( math.atan2( item.X, item.Z ) )
	end

	table.sort( items, function( itemA, itemB ) return itemA.Rank < itemB.Rank end )

	for index, item in ipairs( items ) do
		itemIds[index] = item.Id
	end

	return itemIds
end

function EHT.Housing.LevelOrientation( pitch, yaw, roll )
	pitch, roll = EHT.Housing.NearestRightAngle( pitch ), EHT.Housing.NearestRightAngle( roll )
	return pitch, yaw, roll
end

function EHT.Housing.GetItemLinkTags( link, categoryFilter )
	local tags = { }

	local numTags = GetItemLinkNumItemTags( link )
	if numTags and 0 < numTags then
		for index = 1, numTags do
			local name, category = GetItemLinkItemTagInfo( link, index )
			if not categoryFilter or category == categoryFilter then
				local tag = { name = name, category = category }
				table.insert( tags, tag )
			end
		end
	end

	return tags
end

function EHT.Housing.GetItemLinkFurnitureBehaviorTags( link )
	return EHT.Housing.GetItemLinkTags( link, TAG_CATEGORY_FURNITURE_BEHAVIOR )
end

do
	local ym, pm = matrix { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }, matrix { { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } }

	function EHT.Housing.GetRotationMatrix( pitch, yaw, roll )
		pitch, yaw, roll = EHT.Housing.CorrectGimbalLock( pitch, yaw, roll )
		local s, c

		s, c = math.sin( yaw ), math.cos( yaw )
		ym[1][1], ym[1][2], ym[1][3] = 1, 0, 0
		ym[2][1], ym[2][2], ym[2][3] = 0, c, -s
		ym[3][1], ym[3][2], ym[3][3] = 0, s, c

		s, c = math.sin( pitch ), math.cos( pitch )
		pm[1][1], pm[1][2], pm[1][3] = c, 0, s
		pm[2][1], pm[2][2], pm[2][3] = 0, 1, 0
		pm[3][1], pm[3][2], pm[3][3] = -s, 0, c

		s, c = math.sin( roll ), math.cos( roll )
		local rm = matrix {
			{ c, -s, 0 },
			{ s, c, 0 },
			{ 0, 0, 1 }
		}

		return matrix.mul( rm, matrix.mul( pm, ym ) )
	end
end

function EHT.Housing.GetRotationMatrixPosition( m )
	local y = m[1][1]
	local x = m[1][2]
	local z = m[1][3]

	return round( y, 2 ), round( x, 2 ), round( z, 2 )
end

function EHT.Housing.GetRotationMatrixOrientation( m )
	local pitch = -math.asin( m[3][1] )
	local yaw = -math.atan2( -m[3][2], m[3][3] )
	local roll = -math.atan2( -m[2][1], m[1][1] )

	return math.unnan( pitch, 0 ), math.unnan( yaw, 0 ), math.unnan( roll, 0 )
end

function EHT.Housing.CalculateRotation( targetPitch, targetYaw, targetRoll,		currentPitch, currentYaw, currentRoll,		currentX, currentY, currentZ,		relativePitch, relativeYaw, relativeRoll,		relativeX, relativeY, relativeZ )
	local x, y, z, pitch, yaw, roll = nil, nil, nil, nil, nil, nil

	-- Build target rotation transformation matrix.
	local targetTransform = EHT.Housing.GetRotationMatrix( targetPitch, targetYaw, targetRoll )

	local inverseRelativeOrientationTransform = nil
	if nil ~= relativePitch then
		-- Build inverse relative rotation transformation matrix.
		inverseRelativeOrientationTransform = matrix.invert( EHT.Housing.GetRotationMatrix( relativePitch, relativeYaw, relativeRoll ) )
	end

	-- [ Rotate Position ]

	if nil ~= currentX and nil ~= relativeX then
		local newPosition = matrix { { currentY, currentX, currentZ } }

		-- Offset position by relative position.
		newPosition[1][1], newPosition[1][2], newPosition[1][3] = newPosition[1][1] - relativeY, newPosition[1][2] - relativeX, newPosition[1][3] - relativeZ

		if nil ~= inverseRelativeOrientationTransform then
			-- Offset position by relative orientation.
			newPosition = matrix.mul( newPosition, inverseRelativeOrientationTransform )
		end

		-- Rotate position using target pitch, yaw and roll.
		newPosition = matrix.mul( newPosition, targetTransform )

		-- Extract y, x and z from rotation output matrix.
		y, x, z = EHT.Housing.GetRotationMatrixPosition( newPosition )

		-- Reverse offset position by relative position.
		y, x, z = y + relativeY, x + relativeX, z + relativeZ
	end

	-- [ Rotate Orientation ]

	if nil ~= currentPitch then
		-- Current orientation matrix.
		local newOrientation = EHT.Housing.GetRotationMatrix( currentPitch, currentYaw, currentRoll )

		if nil ~= inverseRelativeOrientationTransform then
			-- Offset orientation by relative orientation.
			newOrientation = matrix.mul( newOrientation, inverseRelativeOrientationTransform )
		end

		-- Rotate orientation using target pitch, yaw and roll.
		newOrientation = matrix.mul( newOrientation, targetTransform )

		-- Extract pitch, yaw and roll from rotation output matrix.
		pitch, yaw, roll = EHT.Housing.GetRotationMatrixOrientation( newOrientation )
	end

	return pitch, yaw, roll, x, y, z
end

function EHT.Housing.CalculateRotationById( targetPitch, targetYaw, targetRoll, furnitureId, relativePitch, relativeYaw, relativeRoll, relativeX, relativeY, relativeZ )
	local x, y, z = EHT.Housing.GetFurniturePosition( furnitureId )
	local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( furnitureId )
	return EHT.Housing.CalculateRotation( targetPitch, targetYaw, targetRoll, pitch, yaw, roll, x, y, z, relativePitch, relativeYaw, relativeRoll, relativeX, relativeY, relativeZ )
end

function EHT.Housing.RotateById( targetPitch, targetYaw, targetRoll, furnitureId, relativePitch, relativeYaw, relativeRoll, relativeX, relativeY, relativeZ )
	local pitch, yaw, roll, x, y, z = EHT.Housing.CalculateRotationById( targetPitch, targetYaw, targetRoll, furnitureId, relativePitch, relativeYaw, relativeRoll, relativeX, relativeY, relativeZ )
	EHT.Housing.SetFurniturePositionAndOrientation( furnitureId, x, y, z, pitch, yaw, roll )
	return pitch, yaw, roll, x, y, z
end

function EHT.Housing.RotateOrientation( currentPitch, currentYaw, currentRoll, offsetPitch, offsetYaw, offsetRoll )
	currentPitch, currentYaw, currentRoll = currentPitch % RAD360, currentYaw % RAD360, currentRoll % RAD360
	local transform = EHT.Housing.GetRotationMatrix( currentPitch, currentYaw, currentRoll )

	if nil == offsetPitch and nil == offsetYaw and nil == offsetRoll then
		local inverseTransform = matrix.invert( transform )

		if nil ~= inverseTransform then
			transform = matrix.mul( transform, inverseTransform )
		end
	else
		offsetPitch, offsetYaw, offsetRoll = offsetPitch % RAD360, offsetYaw % RAD360, offsetRoll % RAD360
		local offsetTransform = EHT.Housing.GetRotationMatrix( offsetPitch, offsetYaw, offsetRoll )
		local currentTransform = EHT.Housing.GetRotationMatrix( currentPitch, currentYaw, currentRoll )
		local inverseTransform = matrix.invert( currentTransform )

		if nil == inverseTransform then
			transform = matrix.mul( transform, offsetTransform )
		else
			transform = matrix.mul( transform, inverseTransform )
			transform = matrix.mul( transform, offsetTransform )
			transform = matrix.mul( transform, currentTransform )
		end
	end

	local pitch, yaw, roll = EHT.Housing.GetRotationMatrixOrientation( transform )
	pitch, yaw, roll = math.unnan( pitch % RAD360 ), math.unnan( yaw % RAD360 ), math.unnan( roll % RAD360 )

	return pitch, yaw, roll
end

function EHT.Housing.RotateAroundOrigin( x, y, z, pitch, yaw, roll )
	_, _, _, x, y, z = EHT.Housing.CalculateRotation( pitch, yaw, roll,		0, 0, 0,	x, y, z,	nil, nil, nil,	0, 0, 0 )
	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.AreAllItemDimensionsCached( group )
	if nil == group then return true end

	local itemId
	for index, item in ipairs( group ) do
		if not EHT.Housing.IsEffectId( item.Id ) then
			itemId = EHT.Housing.GetFurnitureItemId( item.Id )
			if nil == itemId or nil == EHT.SavedVars.Dimensions[ itemId ] then return false end
		end
	end

	return true
end

function EHT.Housing.GetEffectById( id )
	if "number" ~= type( id ) then id = EHT.Housing.FindFurnitureId( id ) end

	if EHT.Housing.IsEffectId( id ) then
		return EHT.Data.GetEffectByRecordId( id )
	end

	return nil
end

function EHT.Housing.GetMinMaxItemDimensions( group )
	local itemId, dim, minX, minY, minZ, maxX, maxY, maxZ = nil, nil, 9999999, 9999999, 9999999, 0, 0, 0
	local empty = true

	if group and 0 < #group then
		empty = false

		for index, item in ipairs( group ) do
			local x, y, z = EHT.Housing.GetFurnitureDimensions( item.Id )
			minX, minY, minZ = math.min( minX, x ), math.min( minY, y ), math.min( minZ, z )
			maxX, maxY, maxZ = math.max( maxX, x ), math.max( maxY, y ), math.max( maxZ, z )
		end
	end

	if empty then
		return 0, 0, 0, 0, 0, 0
	end

	return minX, minY, minZ, maxX, maxY, maxZ
end

function EHT.Housing.NearestRightAngle( angle, offsetAngle )
	angle, offsetAngle = ( angle or 0 ) % RAD360, ( offsetAngle or 0 ) % RAD360

	local nearestAngle, angleDistance = nil, nil
	local newAngle, newDistance = offsetAngle, nil

	for index = 1, 4 do
		newDistance = ( newAngle - angle ) % RAD360
		if newDistance > RAD180 then newDistance = RAD360 - newDistance end

		if nil == angleDistance or newDistance < angleDistance then
			angleDistance, nearestAngle = newDistance, newAngle
		end

		newAngle = ( newAngle + RAD90 ) % RAD360
	end

	return nearestAngle
end

function EHT.Housing.CalculateSnapOrientation( currentPitch, currentYaw, currentRoll, targetPitch, targetYaw, targetRoll )
	local pitch = EHT.Housing.NearestRightAngle( currentPitch, targetPitch )
	local yaw = EHT.Housing.NearestRightAngle( currentYaw, targetYaw )
	local roll = EHT.Housing.NearestRightAngle( currentRoll, targetRoll )

	return pitch, yaw, roll
end

function EHT.Housing.TranslatePoint( x, y, z, tX, tY, tZ ) return x + tX, y + tY, z + tZ end

function EHT.Housing.MirrorAngle( angle, axisAngle )
	angle, axisAngle = angle % RAD360, axisAngle % RAD360

	if angle >= ( axisAngle - RAD90 ) % RAD360 and angle <= axisAngle then
		angle = axisAngle + ( axisAngle - angle )
	elseif angle <= ( axisAngle + RAD90 ) % RAD360 and angle >= axisAngle then
		angle = axisAngle - ( angle - axisAngle )
	else

		axisAngle = ( axisAngle + RAD180 ) % RAD360

		if angle >= ( axisAngle - RAD90 ) % RAD360 and angle <= axisAngle then
			angle = axisAngle + ( axisAngle - angle )
		else
			angle = axisAngle - ( angle - axisAngle )
		end

	end

	return angle % RAD360
end

function EHT.Housing.HorizontalMirrorPoint( origin, x, y, z, pitch, yaw, roll )
	local newYaw = math.deg( yaw ) % 360
	if 0 > newYaw then newYaw = 360 + newYaw end

	local quaternion = math.floor( newYaw / 90 ) + 1

	if 1 == quaternion then newYaw = 90 + ( 90 - newYaw )
	elseif 2 == quaternion then newYaw = 180 - newYaw
	elseif 3 == quaternion then newYaw = 180 - newYaw
	else newYaw = 270 + ( 270 - newYaw ) end

	yaw = math.rad( newYaw )

	x, y, z = EHT.Housing.TranslatePoint( x, y, z, -1 * origin.X, 0, -1 * origin.Z )
	z = -1 * z
	x, y, z = EHT.Housing.TranslatePoint( x, y, z, origin.X, 0, origin.Z )

	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.VerticalMirrorPoint( origin, x, y, z, pitch, yaw, roll )
	local newRoll = math.deg( roll ) % 360
	if 0 > newRoll then newRoll = 360 + newRoll end

	local quaternion = math.floor( newRoll / 90 ) + 1

	if 1 == quaternion then newRoll = 90 + ( 90 - newRoll )
	elseif 2 == quaternion then newRoll = 180 - newRoll
	elseif 3 == quaternion then newRoll = 180 - newRoll
	else newRoll = 270 + ( 270 - newRoll ) end

	roll = math.rad( newRoll )

	x, y, z = EHT.Housing.TranslatePoint( x, y, z, 0, -1 * origin.Y, 0 )
	y = -1 * y
	x, y, z = EHT.Housing.TranslatePoint( x, y, z, 0, origin.Y, 0)

	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.RotatePointOnAxisX( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return x	,	y * c - z * s	,	y * s + z * c
end

function EHT.Housing.RotatePointOnAxisY( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return z * s + x * c	,	y	,	z * c - x * s
end

function EHT.Housing.RotatePointOnAxisZ( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return x * c - y * s	,	x * s + y * c	,	z
end

function EHT.Housing.Midpoint( x1, y1, z1, x2, y2, z2 )
	return ( x1 + x2 ) / 2, ( y1 + y2 ) / 2, ( z1 + z2 ) / 2
end

---[ Housing : Collision Detection ]---

-- Vertices must be a table containing 0 or more 7-element tables, integer indexed.
-- Each 7-element table consists of the integer indexed elements:
--  1 = X, 2 = Y, 3 = Z, 4 = Pitch, 5 = Yaw, 6 = Roll, 7 = Distance from Center Point (calculated by this function)
function EHT.Housing.SortVerticesByDistance( vertices, centerX, centerY, centerZ, sortAscending )
	if nil == sortAscending then sortAscending = true end

	local v, vi, vj, x, y, z, pitch, yaw, roll, distance, snapCoeffX, snapCoeffY, snapCoeffZ, adjCoeffX, adjCoeffY, adjCoeffZ

	if nil ~= centerX and nil ~= centerY and nil ~= centerZ then
		for i = 1, #vertices do
			v = vertices[i]
			if nil ~= v[1] and nil ~= v[2] and nil ~= v[3] then
				v[7] = math.abs( zo_distance3D( v[1], v[2], v[3], centerX, centerY, centerZ ) )
			end
		end
	end

	for i = 1, ( #vertices - 1 ) do
		for j = i + 1, #vertices do
			vi, vj = vertices[i], vertices[j]
			if nil ~= vi and nil ~= vj and nil ~= vj[1] and nil ~= vj[2] and nil ~= vj[3] then
				if ( sortAscending and vi[7] > vj[7] ) or ( not sortAscending and vi[7] < vj[7] ) then
					x, y, z, pitch, yaw, roll, distance, snapCoeffX, snapCoeffY, snapCoeffZ, adjCoeffX, adjCoeffY, adjCoeffZ = vi[1], vi[2], vi[3], vi[4], vi[5], vi[6], vi[7], vi[8], vi[9], vi[10], vi[11], vi[12], vi[13]
					vi[1], vi[2], vi[3], vi[4], vi[5], vi[6], vi[7], vi[8], vi[9], vi[10], vi[11], vi[12], vi[13] = vj[1], vj[2], vj[3], vj[4], vj[5], vj[6], vj[7], vj[8], vj[9], vj[10], vj[11], vj[12], vj[13]
					vj[1], vj[2], vj[3], vj[4], vj[5], vj[6], vj[7], vj[8], vj[9], vj[10], vj[11], vj[12], vj[13] = x, y, z, pitch, yaw, roll, distance, snapCoeffX, snapCoeffY, snapCoeffZ, adjCoeffX, adjCoeffY, adjCoeffZ
				end
			else
				table.remove( vertices, j )
			end
		end
	end
end

function EHT.Housing.CreateAxisAlignedBoundingBox( furnitureId, itemName, x, y, z, minX, minY, minZ, maxX, maxY, maxZ, maxGapRadius )
	if nil == maxGapRadius then maxGapRadius = 0 end

	local bbox = {
		Id = furnitureId,
		Name = itemName,
		X = x,
		Y = y,
		Z = z,
		MinX = minX - maxGapRadius,
		MinY = minY - maxGapRadius,
		MinZ = minZ - maxGapRadius,
		MaxX = maxX + maxGapRadius,
		MaxY = maxY + maxGapRadius,
		MaxZ = maxZ + maxGapRadius
	}

	return bbox
end

function EHT.Housing.AreBoundingBoxesIntersecting( bb1, bb2 )
	return	( bb1.MinX <= bb2.MaxX and bb1.MaxX >= bb2.MinX ) and
			( bb1.MinY <= bb2.MaxY and bb1.MaxY >= bb2.MinY ) and
			( bb1.MinZ <= bb2.MaxZ and bb1.MaxZ >= bb2.MinZ )
end

function EHT.Housing.MinBoundingBoxDistance( bb, x, y, z )
	local dist = EHT.World.GetMinPointLineSegmentDistance

	return math.min(
		dist( nil,	x, y, z,	bb.MinX, bb.MinY, bb.MinZ,	bb.MaxX, bb.MinY, bb.MinZ ),
		dist( nil,	x, y, z,	bb.MinX, bb.MinY, bb.MinZ,	bb.MinX, bb.MinY, bb.MaxZ ),
		dist( nil,	x, y, z,	bb.MinX, bb.MaxY, bb.MinZ,	bb.MaxX, bb.MaxY, bb.MinZ ),
		dist( nil,	x, y, z,	bb.MinX, bb.MaxY, bb.MinZ,	bb.MinX, bb.MaxY, bb.MaxZ ),
		dist( nil,	x, y, z,	bb.MinX, bb.MinY, bb.MinZ,	bb.MinX, bb.MaxY, bb.MinZ ),
		dist( nil,	x, y, z,	bb.MaxX, bb.MinY, bb.MinZ,	bb.MaxX, bb.MaxY, bb.MinZ ),
		dist( nil,	x, y, z,	bb.MinX, bb.MinY, bb.MinZ,	bb.MinX, bb.MaxY, bb.MaxZ ),
		dist( nil,	x, y, z,	bb.MaxX, bb.MinY, bb.MaxZ,	bb.MaxX, bb.MaxY, bb.MaxZ )
	)
end

function EHT.Housing.IsPointInsideBoundingBox( x, y, z, minX, minY, minZ, maxX, maxY, maxZ )
	return x <= maxX and x >= minX and y <= maxY and y >= minY and z <= maxZ and z >= minZ
end

function EHT.Housing.IsCameraFacingPoint( x, y, z )
	local fx, fy, fz = EHT.World:GetCameraForward()
	local cx, cy, cz = EHT.World:GetCameraPosition()
	local dx, dy, dz = cx - x, cy - y, cz - z
	local cangle = math.atan2( fx, fz )
	local pangle = math.atan2( dx, dz )
	local theta = ( cangle - pangle ) % RAD360
	local facing = theta >= RAD120 and theta <= RAD240
	return facing
end

function EHT.Housing.IsCameraFacingPoints( points )
	local fx, fy, fz = EHT.World:GetCameraForward()
	local cx, cy, cz = EHT.World:GetCameraPosition()
	local cangle = math.atan2( fx, fz )

	for index, p in ipairs( points ) do
		local dx, dy, dz = cx - p[1], cy - p[2], cz - p[3]
		local pangle = math.atan2( dx, dz )
		local theta = ( cangle - pangle ) % RAD360
		local facing = theta >= RAD120 and theta <= RAD240
		if not facing then return false end
	end

	return true
end

---[ Housing : House ]---

function EHT.Housing.GetHouseId()
	return GetCurrentZoneHouseId()
end

function EHT.Housing.IsHouseZone()
	return 0 ~= GetCurrentZoneHouseId()
end

function EHT.Housing.IsOwner()
	return IsOwnerOfCurrentHouse()
end

function EHT.Housing.InOwnedHouse( houseId )
	return EHT.Housing.IsOwner() and tonumber( EHT.Housing.GetHouseId() ) == tonumber( houseId )
end

function EHT.Housing.GetHouseOwner()
	return GetCurrentHouseOwner() or "", GetCurrentZoneHouseId() or 0
end

function EHT.Housing.IsDisabledMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_DISABLED
end

function EHT.Housing.IsSelectionMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_SELECTION
end

function EHT.Housing.IsPlacementMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_PLACEMENT
end

function EHT.Housing.IsHUDMode()
	return GetHousingEditorMode() == HOUSING_EDITOR_MODE_DISABLED
end

function EHT.Housing.GetNoteHouseInfo( note )
	if nil ~= note and "" ~= note then
		local startIndex, endIndex = string.find( string.lower( note ), "eht%(" )
		if nil ~= endIndex and 0 < endIndex then
			startIndex = endIndex + 1
			endIndex = string.find( note, "%)", startIndex )
			if nil ~= endIndex then
				local separatorIndex = string.find( note, "%,", startIndex )
				if nil ~= separatorIndex and separatorIndex > startIndex and separatorIndex < endIndex then
					noteHouseId = EHT.Util.Trim( string.sub( note, startIndex, separatorIndex - 1 ) )
					noteHouseName = EHT.Util.Trim( string.sub( note, separatorIndex + 1, endIndex - 1 ) )

					if nil ~= noteHouseId and "" ~= noteHouseId and nil ~= noteHouseName and "" ~= noteHouseName then
						return startIndex - 4, endIndex, noteHouseId, noteHouseName
					end
				end

				return startIndex - 4, endIndex
			end
		end
	end
end

function EHT.Housing.GetAllGuildNoteHouseInfo()
	local numGuilds = GetNumGuilds()
	local guildId, guildInfo, note, memberIndex, houseId, houseName
	local guilds = { }

	for guildIndex = 1, numGuilds do
		guildId = GetGuildId( guildIndex )
		guildInfo = { GuildId = guildId, GuildName = GetGuildName( guildId ) }
		table.insert( guilds, guildInfo )

		memberIndex = GetPlayerGuildMemberIndex( guildId )
		if nil ~= memberIndex and 0 < memberIndex then
			_, note = GetGuildMemberInfo( guildId, memberIndex )
			if nil ~= note and "" ~= note then
				_, _, houseId, houseName = EHT.Housing.GetNoteHouseInfo( note )
				if nil ~= houseId and nil ~= houseName then
					guildInfo.HouseId, guildInfo.HouseName = houseId, houseName
				end
			end
		end
	end

	return guilds
end

function EHT.Housing.GetHouseName( houseId )
	local collectibleId = GetCollectibleIdForHouse( houseId or GetCurrentZoneHouseId() )
	return GetCollectibleName( collectibleId ) or ""
end

function EHT.Housing.GetHouseNickname( houseId )
	if not houseId then
		houseId = GetCurrentZoneHouseId()
	end
	local collectibleId = GetCollectibleIdForHouse( houseId )

	return GetCollectibleNickname( collectibleId ) or ""
end

function EHT.Housing.GetHouseInfo()
	local houseId, owner, isOwner, houseName, houseNickname = GetCurrentZoneHouseId(), GetCurrentHouseOwner(), IsOwnerOfCurrentHouse(), "", ""
	local customHouseName = nil
	houseId, owner = houseId or 0, owner or ""

	if 0 ~= houseId then
		local collectibleId = GetCollectibleIdForHouse( houseId )
		houseName = GetCollectibleName( collectibleId ) or ""
		if isOwner then
			houseNickname = EHT.Util.Trim( GetCollectibleNickname( collectibleId ) or "" )
		end
	end

	if not isOwner and owner and "" ~= owner then
		local openHouse = EssentialHousingHub:GetOpenHouse( houseId, owner )
		if openHouse and openHouse.houseName and "" ~= openHouse.houseName then
			customHouseName = openHouse.houseName
		end
	end

	if not customHouseName and nil ~= owner and "" ~= owner then
		local memberIndex, note
		for guildId = 1, GetNumGuilds() do
			memberIndex = GetGuildMemberIndexFromDisplayName( guildId, owner )
			if nil ~= memberIndex and 0 < memberIndex then
				_, note = GetGuildMemberInfo( guildId, memberIndex )
				if nil ~= note and "" ~= note then
					local startIndex, endIndex, noteHouseId, noteHouseName = EHT.Housing.GetNoteHouseInfo( note )
					if nil ~= noteHouseId and tostring( houseId ) == noteHouseId and nil ~= noteHouseName and "" ~= noteHouseName then
						customHouseName = noteHouseName
						break
					end
				end
			end
		end
	end

	return houseId, owner, isOwner, houseName, houseNickname, customHouseName
end

function EHT.Housing.PublishHouseInfoToGuild( guildId, houseId, houseName )
	local memberIndex = GetPlayerGuildMemberIndex( guildId )
	if nil == memberIndex or 0 >= memberIndex then
		return false, string.format( "Cannot publish to '|cffffff%s|r':\nCannot determine your Guild Member Index.", GetGuildName( guildId ) or "" )
	end

	local _, note = GetGuildMemberInfo( guildId, memberIndex )
	if nil == note or "" == note then
		note = ""
	else
		local startIndex, endIndex, noteHouseId, noteHouseName = EHT.Housing.GetNoteHouseInfo( note )
		if startIndex and endIndex then
			note = string.sub( note, 1, startIndex - 1 ) .. string.sub( note, endIndex + 1 )
		end
	end

	note = EHT.Util.Trim( note )
	if "" ~= note and "\n" ~= string.sub( note, -1 ) then note = note .. "\n" end

	note = note .. string.format( "EHT(%s,%s)", tostring( houseId ), houseName )

	if #note > EHT.CONST.MAX_GUILD_NOTE_LENGTH then
		return false, string.format( "Cannot publish to '|cffffff%s|r':\nYour Guild Member Note would exceed %d characters. Please reduce the length of your Guild Member Note and try again.", GetGuildName( guildId ) or "", EHT.CONST.MAX_GUILD_NOTE_LENGTH )
	end

	SetGuildMemberNote( guildId, memberIndex, note )
	return true, nil
end

do
	local lastRun = 0
	local houseId, houseNickname
	local messages = { }
	local validGuilds = { }

	function EHT.Housing.PublishHouseInfo( confirm )

		if 6 > ( GetGameTimeSeconds() - lastRun ) then
			EHT.UI.ShowAlertDialog( "", "Please wait a few seconds before re-running this tool." )
			return false, nil
		end

		local nicknameInstructions = "You may use the |cffffffRename|r button on the |cffffffCollections|r || |cffffffHousing|r tab to set or change your nickname for a house."

		local numGuilds = GetNumGuilds() or 0
		if 0 >= numGuilds then
			return false, "You must be a member of at least one guild."
		end

		local owner, isOwner, houseName, customHouseName
		houseId, owner, isOwner, houseName, houseNickname, customHouseName = EHT.Housing.GetHouseInfo()

		if nil == houseId or 0 >= houseId or not isOwner then
			return false, "You must be in one of your houses."
		end

		houseNickname = string.gsub( houseNickname or "", "%)", "" )

		if nil == houseNickname or "" == houseNickname then
			return false, string.format( "You have not set a nickname for this house.\n\n%s", nicknameInstructions )
		end

		if not confirm then
			EHT.UI.ShowConfirmationDialog(
				"Publish House Information",
				string.format( "Do you want to publish '|cffffff%s|r' as the nickname of this house to the members of your %d guild(s)?\n\n" ..
					"Please note the following:\n" ..
					"- You may publish only one house nickname.\n" ..
					"- You must publish again if you change your house nickname.\n" ..
					"- Publishing for a different house will remove any previously published house nickname.\n" ..
					"- Publishing will only work for guilds that grant you access to change your Guild Member Note.\n" ..
					"- %s", houseNickname, numGuilds, nicknameInstructions ),
				function() EHT.Housing.PublishHouseInfo( true ) end )
			return true, nil
		end

		lastRun = GetGameTimeSeconds()
		messages = { }
		validGuilds = { }

		for guildIndex = 1, numGuilds do
			local guildId = GetGuildId( guildIndex )

			zo_callLater( function()
				local success, message = EHT.Housing.PublishHouseInfoToGuild( guildId, houseId, houseNickname )
				if not success then
					if message then table.insert( messages, message ) end
				else
					validGuilds[ guildId ] = true
				end
			end, guildIndex * 500 )
		end

		EHT.UI.ShowAlertDialog( "", "Updating your guilds...\nThis should only take a moment." )
		local callbackDelay = 8000
		zo_callLater( function() EHT.UI.HideAllDialogs() end, callbackDelay - 500 )
		zo_callLater( function() EHT.Housing.PublishHouseInfoCompleted() end, callbackDelay )

		return true, nil

	end


	function EHT.Housing.PublishHouseInfoCompleted()

		local updates = EHT.Housing.GetAllGuildNoteHouseInfo()
		local numGuilds = GetNumGuilds()

		if nil ~= updates then
			for _, update in ipairs( updates ) do
				if update.GuildId and validGuilds[ update.GuildId ] then
					if tostring( update.HouseId or "" ) ~= tostring( houseId or "" ) or tostring( update.HouseName or "" ) ~= tostring( houseNickname or "" ) then
						table.insert( messages, string.format(
							"Cannot publish to '|cffffff%s|r':\nYou do not have permission to update your Guild Member Note.", update.GuildName or "" ) )
					end
				end
			end
		end

		if 0 < #messages then
			local message = string.format( "Failed to publish to %d of %d guild(s):\n\n%s", #messages, numGuilds, table.concat( messages, "\n\n" ) )
			EHT.UI.ShowAlertDialog( "Publish Failed", message )
			return false, message
		end

		EHT.UI.ShowAlertDialog( "Publish Complete", string.format( "Successfully published to your %d guild(s).", numGuilds ) )
		return true, nil

	end

end

local houseIdCache = nil

function EHT.Housing.GetAllHouses( refresh )
	if nil == houseIdCache or true == refresh then
		local collected, collectibleId, house, houseName, houseNickname, houseIcon, houseImage
		houseIdCache = { }

		for houseId = 1, 1000 do
			collectibleId = GetCollectibleIdForHouse( houseId )

			if nil ~= collectibleId and 0 ~= collectibleId then
				houseName = GetCollectibleName( collectibleId ) or ""
				houseNickname = GetCollectibleNickname( collectibleId ) or ""
				collected = IsCollectibleUnlocked( collectibleId )
				houseImage = GetHousePreviewBackgroundImage( houseId ) or ""
				_, _, houseIcon = GetCollectibleInfo( collectibleId )
				houseIcon = houseIcon or ""

				house = {
					Collected = collected,
					CollectibleId = collectibleId,
					Id = houseId,
					Name = houseName,
					Nickname = houseNickname,
					Description = string.format( "%s%s%s%s", houseName, "" ~= houseNickname and " (" or "", houseNickname, "" ~= houseNickname and ")" or "" ),
					Icon = houseIcon,
					Image = houseImage,
				}

				houseIdCache[ houseId ] = house
			end
		end
	end

	return houseIdCache
end

function EHT.Housing.GetHouseById( houseId )
	local houses = EHT.Housing.GetAllHouses()
	return houses[ houseId ]
end

function EHT.Housing.GetHouseByCollectibleId( collectibleId )
	collectibleId = tonumber( collectibleId )

	local houses = EHT.Housing.GetAllHouses()
	for _, house in pairs( houses ) do
		if collectibleId == house.CollectibleId then
			return house
		end
	end

	return nil
end

function EHT.Housing.GetHouseIdByCollectibleId( collectibleId )
	local house = EHT.Housing.GetHouseByCollectibleId( collectibleId )

	if house then
		return house.Id
	end

	return nil
end

function EHT.Housing.FindHousesByName( s, includeNicknames )
	if nil == s or "" == s then return { } end
	if nil == includeNicknames then includeNicknames = true end

	local searchText = string.lower( s )
	local houses = EHT.Housing.GetAllHouses()
	local matches = { }

	for houseId, house in pairs( houses ) do
		if PlainStringFind( string.lower( house.Name ), searchText ) or ( includeNicknames and PlainStringFind( string.lower( house.Nickname ), searchText ) ) then
			table.insert( matches, house )
		end
	end

	return matches
end

function EHT.Housing.GetHouseByName( houseName )
	local EXCLUDE_NICKNAMES = false
	local houses = EHT.Housing.FindHousesByName( houseName, EXCLUDE_NICKNAMES )

	if 1 == #houses then
		return houses[1]
	end
end

function EHT.Housing.GetLimitName( limitType )
	return EHT.CONST.LIMIT_TYPES[ limitType ] or ""
end

function EHT.Housing.GetLimit( limitType, houseId )
	if not houseId or 0 == houseId then
		houseId = GetCurrentZoneHouseId()
		if not houseId or 0 == houseId then
			return 0
		end
	end

	local limitMax = GetHouseFurnishingPlacementLimit( houseId, limitType )
	local limitUsed = GetNumHouseFurnishingsPlaced( limitType )
	local limitName = EHT.Housing.GetLimitName( limitType )
	return limitName, limitMax, limitUsed
end

function EHT.Housing.GetLimits()
	local limits = { }
	local limitMax, limitUsed, limitName = 0, 0, nil
	local houseId = GetCurrentZoneHouseId()

	if nil == houseId or 0 == houseId then return limits end

	for limitType = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		limitName, limitMax, limitUsed = EHT.Housing.GetLimit( limitType )
		table.insert( limits, { Type = limitType, Name = limitName, Max = limitMax, Used = limitUsed } )
	end

	return limits
end

function EHT.Housing.GetFurnitureIdsByLimitType( limitType )
	local ids = { }
	local id = GetNextPlacedHousingFurnitureId()

	while id do
		if limitType == EHT.Housing.GetFurnitureLimitTypeByFurnitureId( id ) then
			table.insert( ids, id )
		end
		id = GetNextPlacedHousingFurnitureId( id )
	end

	return ids
end

function EHT.Housing.PrevalidateItemLimits( items )
	if EHT.IgnoreHouseLimits then return { } end

	local limits = { }

	for index, limit in ipairs( EHT.Housing.GetLimits() ) do
		limits[ limit.Type ] = limit.Max - limit.Used
	end

	local limitType

	for link, count in pairs( items ) do
		limitType = EHT.Housing.GetFurnitureLimitType( link )

		if limitType and limits[ limitType ] then
			limits[ limitType ] = limits[ limitType ] - count
		end
	end

	local exceeded = { }

	for limitType, available in pairs( limits ) do
		if 0 > available then
			table.insert( exceeded, { Type = limitType, Name = EHT.Housing.GetLimitName( limitType ), Amount = limits[ limitType ] } )
		end
	end

	return exceeded
end

function EHT.Housing.GetFurnitureIdInfo( id )
	if not id then return end
	
	local furnitureId, pathIndex
	local isPathNode, separatorIndex = EHT.Housing.IsFurniturePathNodeId( id )

	if isPathNode and separatorIndex then
		furnitureId = string.sub( id, 1, separatorIndex - 1 )
		pathIndex = tonumber( string.sub( id, separatorIndex + 1 ) )
	else
		furnitureId = id
	end

	local numericId = EHT.Housing.FindFurnitureId( furnitureId )
	if numericId then
		furnitureId = numericId
	end

	return furnitureId, pathIndex
end

function EHT.Housing.CastFurnitureId( id )
	if "number" == type( id ) then
		return id, string.fromId64( id )
	elseif "string" == type( id ) then
		return EHT.Housing.FindFurnitureId( id ), id
	end
end

local function GetFurnitureCache()
	if not EHT.FurnitureCache then EHT.FurnitureCache = { } end
	return EHT.FurnitureCache
end

function EHT.Housing.CreateFurnitureCacheObject(id)
	local sid
	id, sid = EHT.Housing.CastFurnitureId(id)

	if not id or not sid then
		return
	end

	if EHT.Housing.IsEffectId( id ) then
		return
	end

	local link = EHT.Housing.GetFurnitureLink( id )
	local x, y, z, pitch, yaw, roll, speed, delayTime = EHT.Housing.GetFurniturePositionAndOrientation( id )
	local item = { x, y, z, pitch, yaw, roll, link, speed, delayTime }
	return item
end

function EHT.Housing.AddCachedFurniture(id, x, y, z, pitch, yaw, roll, speed, delayTime)
	local sid
	id, sid = EHT.Housing.CastFurnitureId(id)

	if not id or not sid then
		return
	end

	if EHT.Housing.IsEffectId(id) then
		return
	end

	local cache = GetFurnitureCache()
	local r = cache[sid]

	if not r then
		r = {}
		cache[sid] = r

		if not x and not pitch then
			r[1], r[2], r[3], r[4], r[5], r[6], r[8], r[9] = EHT.Housing.GetFurniturePositionAndOrientation(id)
		else
			if not x then
				r[1], r[2], r[3] = EHT.Housing.GetFurniturePosition(id)
			elseif not pitch then
				r[4], r[5], r[6] = EHT.Housing.GetFurnitureOrientation(id)
			end
		end

		r[7] = EHT.Housing.GetFurnitureLink(id)
	end

	if x then
		r[1], r[2], r[3] = x, y, z
	end

	if pitch then
		r[4], r[5], r[6] = pitch, yaw, roll
	end

	if speed then
		r[8] = speed
	end

	if delayTime then
		r[9] = delayTime
	end
end

function EHT.Housing.RemoveCachedFurniture(id)
	local _, sid = EHT.Housing.CastFurnitureId(id)
	if sid then
		GetFurnitureCache()[sid] = nil
	end
end

function EHT.Housing.GetCachedFurniture(id)
	local _, sid = EHT.Housing.CastFurnitureId(id)
	if sid then
		local record = GetFurnitureCache()[sid]
		return record
	end
end

function EHT.Housing.GetAllCachedFurniture()
	return GetFurnitureCache()
end

function EHT.Housing.ClearFurnitureCache()
	local cache = EHT.FurnitureCache
	if not cache then
		cache = {}
		EHT.FurnitureCache = cache
	else
		ZO_ClearTable(cache)
	end
end

function EHT.Housing.RefreshCachedFurniture(id)
	local sid
	id, sid = EHT.Housing.CastFurnitureId(id)

	if not id or not sid then
		return
	end

	if EHT.Housing.IsEffectId(id) then
		return
	end

	local cache = GetFurnitureCache()
	local r = cache[sid]
	local x, y, z, pitch, yaw, roll, speed, delayTime = EHT.Housing.GetFurniturePositionAndOrientation(id)
	local link = EHT.Housing.GetFurnitureLink(id)

	if not r then
		r = {}
		cache[sid] = r
	end

	r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9] = x, y, z, pitch, yaw, roll, link, speed, delayTime
end

local function RefreshFurnitureCache()
	EVENT_MANAGER:UnregisterForUpdate("EHT.Housing.RefreshFurnitureCache")

	local id = GetNextPlacedHousingFurnitureId()
	while id do
		EHT.Housing.RefreshCachedFurniture(id)
		id = GetNextPlacedHousingFurnitureId(id)
	end
end

function EHT.Housing.RefreshFurnitureCache()
	EVENT_MANAGER:RegisterForUpdate("EHT.Housing.RefreshFurnitureCache", 300, RefreshFurnitureCache)
end

function EHT.Housing.RegisterFurnitureId(id)
	if "number" ~= type(id) then
		return
	end

	local sid = string.fromId64(id)
	if nil == sid or "" == sid then
		return
	end

	EHT.Housing.RegisterFurnitureIdString(sid, id)
end

function EHT.Housing.RegisterFurnitureIdString(sid, id)
	if nil == sid or "" == sid or nil == id then
		return
	end

	if not EHT.FurnitureIdList[sid] then
		EHT.FurnitureIdList[sid] = id
		table.insert(EHT.FurnitureIds, {id, sid})

		EHT.Housing.AddCachedFurniture(id)
		EHT.Housing.RegisterAllFurniturePathNodes(id)
		EHT.UI.QueueRefreshSelection()
	end
end

function EHT.Housing.UnregisterFurnitureId(id)
	if "number" ~= type(id) then
		return
	end

	local sid = string.fromId64(id)
	if nil == sid or "" == sid then
		return
	end
	
	EHT.Housing.UnregisterFurnitureIdString(sid, id)
end

function EHT.Housing.UnregisterFurnitureIdString(sid)
	if nil == sid or "" == sid then
		return
	end

	local idList = EHT.FurnitureIdList
	local id = idList[sid]

	if id then
		local ids = EHT.FurnitureIds
		local numIds = #ids
		for index = numIds, 1, -1 do
			if sid == ids[index][2] then
				table.remove(ids, index)
			end
		end

		idList[sid] = nil
		EHT.Housing.RemoveCachedFurniture(id)
	end
end

function EHT.Housing.CompareFurniturePathNodes( id1, pathIndex1, id2, pathIndex2 )
	if not id1 or not id2 then
		return
	end

	id1 = string.fromId64( id1 )
	id2 = string.fromId64( id2 )
	if id1 == id2 and pathIndex1 and pathIndex2 then
		if pathIndex1 < pathIndex2 then
			return -1
		elseif pathIndex1 > pathIndex2 then
			return 1
		else
			return 0
		end
	end

	return nil
end

function EHT.Housing.CompareIds(left, right)
	return nil ~= left and string.fromId64(left) == string.fromId64(right)
end

function EHT.Housing.UnregisterAllFurniturePathNodes(id)
	if "number" ~= type(id) then
		return
	end

	local sid = string.fromId64(id)

	if nil == sid or "" == sid then
		return
	end

	local nodePrefix = sid .. "."
	local nodePrefixLength = #nodePrefix

	for furnitureIdString in pairs(EHT.FurnitureIdList) do
		if string.sub(furnitureIdString, 1, nodePrefixLength) == nodePrefix then
			EHT.Housing.UnregisterFurnitureIdString(furnitureIdString)
		end
	end
end

function EHT.Housing.RegisterAllFurniturePathNodes(id)
	EHT.Housing.UnregisterAllFurniturePathNodes(id)

	local numNodes = EHT.Housing.GetNumFurniturePathNodes(id)

	if 0 == numNodes then
		return
	end

	local sid = string.fromId64(id)

	if nil == sid or "" == sid then
		return
	end

	local nodePrefix = sid .. "."
	local nodePrefixLength = #nodePrefix
	
	for nodeIndex = 1, numNodes do
		local pathNodeId = nodePrefix .. tostring(nodeIndex)
		EHT.Housing.RegisterFurnitureIdString(pathNodeId)
	end
end

do
	local nextFurnitureId
	iterationCount = 0

	function EHT.Housing.MaintainFurnitureIds()
		if not EHT.Housing.IsHouseZone() then
			EVENT_MANAGER:UnregisterForUpdate("EHT.Housing.MaintainFurnitureIds")
			return
		end

		nextFurnitureId = GetNextPlacedHousingFurnitureId(nextFurnitureId)

		while nextFurnitureId and iterationCount < 100 do
			EHT.Housing.RegisterFurnitureId(nextFurnitureId)
			nextFurnitureId = GetNextPlacedHousingFurnitureId(nextFurnitureId)
			iterationCount = iterationCount + 1
		end
		
		iterationCount = 0
	end
end

function EHT.Housing.RefreshFurnitureIds()
	EHT.Housing.ClearFurnitureCache()

	local idList = EHT.FurnitureIdList
	if idList then
		ZO_ClearTable(idList)
	else
		idList = {}
		EHT.FurnitureIdList = idList
	end
	
	local ids = EHT.FurnitureIds
	if ids then
		ZO_ClearNumericallyIndexedTable(ids)
	else
		ids = {}
		EHT.FurnitureIds = ids
	end

	if not EHT.Housing.IsHouseZone() then
		return
	end

	local isOwner = EHT.Housing.IsOwner()
	if isOwner then
		local effects = EHT.Data.GetEffectRecordsByHouseId(EHT.Housing.GetHouseId())
		if effects then
			for _, effect in ipairs(effects) do
				if not effect.Id then effect.Id = EHT.Data.AcquireNewEffectId() end
				EHT.Housing.RegisterFurnitureId(tonumber(effect.Id))
			end
		end
	end

	local id = GetNextPlacedHousingFurnitureId()
	while id do
		EHT.Housing.RegisterFurnitureId(id)
		id = GetNextPlacedHousingFurnitureId(id)
	end

	EVENT_MANAGER:RegisterForUpdate("EHT.Housing.MaintainFurnitureIds", 250, EHT.Housing.MaintainFurnitureIds)
end

function EHT.Housing.GetNextFurnitureId(previousId)
	local ids = EHT.FurnitureIds
	local previousIdString = previousId and string.fromId64(previousId) or nil

	if previousIdString then
		for index, idData in ipairs(ids) do
			if idData[2] == previousIdString then
				local nextData = ids[index + 1]
				return nextData and nextData[1] or nil
			end
		end

		return nil
	end
	
	local firstData = ids[1]
	return firstData and firstData[1] or nil
end
--[[
do
	local lastKey, lastIndex
	local reentryCount = 0

	function EHT.Housing.GetNextFurnitureId(previousId)
		local sid = previousId and string.fromId64(previousId) or nil
		local ids = EHT.FurnitureIds

		if sid then
			local reentry = lastKey == sid
			
			if reentry then
				reentryCount = reentryCount + 1
				if reentryCount > 3000 then
					reentryCount, lastIndex, lastKey = 0, nil, nil
					return nil
				end
			else
				reentryCount = 0
			end
			
			local numIds = #ids
			local startIndex = reentry and lastIndex or 1

			for index = startIndex, numIds do
				local idstrng = Id64ToString(ids[index])
				if idstring == sid then
					lastIndex = index + 1
					lastKey = Id64ToString(ids[lastIndex])
					if not lastKey then
						lastIndex = nil
					end
					return ids[lastIndex]
				end
			end

			lastIndex, lastKey = nil, nil
			return nil
		end

		reentryCount, lastIndex, lastKey = 0, 1, Id64ToString(ids[1])
		return ids[1]
	end
end
]]
--[[
function EHT.Housing.RefreshFurnitureIds()
	EHT.FurnitureIdList = { }
	EHT.FurnitureIdListHead = nil
	EHT.FurnitureIdListTail = nil
	EHT.Housing.ClearFurnitureCache()

	if EHT.Housing.IsHouseZone() then
		local isOwner = EHT.Housing.IsOwner()
		if isOwner then
			local effects = EHT.Data.GetEffectRecordsByHouseId( EHT.Housing.GetHouseId() )
			if effects then
				for _, effect in ipairs( effects ) do
					if not effect.Id then effect.Id = EHT.Data.AcquireNewEffectId() end
					EHT.Housing.RegisterFurnitureId( tonumber( effect.Id ) )
				end
			end
		end

		local id
		repeat
			id = GetNextPlacedHousingFurnitureId( id )
			if id then
				EHT.Housing.RegisterFurnitureId( id )
			end
		until not id

		EVENT_MANAGER:RegisterForUpdate( "EHT.Housing.MaintainFurnitureIds", 1000, EHT.Housing.MaintainFurnitureIds )
	end
end

if EHT.DEBUG_MODE then
	SLASH_COMMANDS[ "/dfids" ] = function()
		local node = EHT.FurnitureIdListHead
		if node then
			df( "Head: %f", node[1] )
		end
		while node do
			df( "Id: %f, Prev: %f, Next: %f", node[1], node[2] and node[2][1] or 0, node[3] and node[3][1] or 0 )
			node = node[3]
		end
		if EHT.FurnitureIdListTail then
			df( "Tail: %f", EHT.FurnitureIdListTail[1] )
		end
	end

	SLASH_COMMANDS[ "/dfkeys" ] = function()
		for sid, _ in pairs( EHT.FurnitureIdList ) do
			d( sid )
		end
	end
end

function EHT.Housing.GetNextFurnitureId( previousId )
	if not previousId then
		if EHT.FurnitureIdListHead then
			return EHT.FurnitureIdListHead[1]
		end
	else
		local node = EHT.FurnitureIdList[ string.fromId64( previousId ) ]
		if node and node[3] then
			return node[3][1]
		end
	end
end
]]
function EHT.Housing.FindFurnitureByProximity( itemId, x, y, z, maxDistance, excludedIds )
	maxDistance = maxDistance or 99999999
	excludedIds = excludedIds or { }

	local id = EHT.Housing.GetNextFurnitureId()
	local items = { }

	while id do
		local sid = string.fromId64( id )

		if not excludedIds[sid] then
			local iX, iY, iZ = EHT.Housing.GetFurniturePosition( id )
			local distance = zo_distance3D( x, y, z, iX, iY, iZ )

			if distance <= maxDistance then
				local iItemId = EHT.Housing.GetFurnitureItemId( id )

				if iItemId == itemId then
					table.insert( items, { id, distance } )
				end
			end
		end

		id = EHT.Housing.GetNextFurnitureId( id )
	end

	table.sort( items, function( item1, item2 ) return item1[2] < item2[2] end )

	return items
end

function EHT.Housing.GetNumPlacedFurniture()
	local totalItems = 0

	for index = HOUSING_FURNISHING_LIMIT_TYPE_MIN_VALUE, HOUSING_FURNISHING_LIMIT_TYPE_MAX_VALUE do
		totalItems = totalItems + GetNumHouseFurnishingsPlaced( index )
	end

	return totalItems
end

function EHT.Housing.GetNumPlacedStatefulFurniture( group )
	local items = 0
	local id = nil

	if nil == group or "table" ~= type( group ) then
		repeat
			id = EHT.Housing.GetNextFurnitureId( id )
			if nil ~= id and 0 < EHT.Housing.GetFurnitureNumStates( id ) then items = items + 1 end
		until nil == id
	else
		for _, item in ipairs( group ) do
			if nil ~= item and nil ~= item.Id and 0 < EHT.Housing.GetFurnitureNumStates( item.Id ) then items = items + 1 end
		end
	end

	return items
end

function EHT.Housing.ForEachFurnishing( func, data, id )
	if not func then
		return
	end

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )

		if nil ~= id then
			local delay, delayFor = func( id, data )

			if delay then
				delayFor = tonumber( delayFor )
				if nil == delayFor or 100 > delayFor then
					delayFor = 100
				end

				zo_callLater( function() EHT.Housing.ForEachFurnishing( func, data, id ) end, delayFor )
				return
			end
		end
	until nil == id
end
EHT.FEF = EHT.Housing.ForEachFurnishing

function EHT.Housing.ForEachGroupFurnishing(onItem, onComplete, group, index, increment)
	if not onItem then
		return
	end

	if nil == group then
		group = EHT.Data.GetCurrentGroup()
		if nil == group then return end
	end

	if nil == increment then
		increment = 1
	end

	if nil == index then
		index = 1
		if 0 > increment then index = #group end
	else
		index = index + increment
	end

	local item
	repeat
		item = group[index]

		if nil ~= item then
			local delay = onItem(index, item)
			if delay then
				if "string" == type(delay) and "cancel" == delay then
					return
				end

				delay = tonumber(delay)
				if nil == delay or 100 > delay then
					delay = 100
				end

				zo_callLater(function()
					EHT.Housing.ForEachGroupFurnishing(onItem, onComplete, group, index, increment)
				end, delay)

				return
			end
		end

		index = index + increment
	until nil == item

	if onComplete then
		onComplete(group)
	end
end
EHT.FEG = EHT.Housing.ForEachGroupFurnishing

function EHT.Housing.GetAllStatefulFurniture()
	local id, items, state = nil, { }, nil

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )
		if nil ~= id then
			state = EHT.Housing.GetFurnitureState( id )
			if nil ~= state then
				items[ string.fromId64( id ) ] = state
			end
		end
	until nil == id

	return items
end

function EHT.Housing.GetStatefulFurnitureConditionally( state, returnItemsInState )
	local items = EHT.Housing.GetAllStatefulFurniture()
	local numItems = 0

	for id, currentState in pairs( items ) do
		if ( returnItemsInState and state ~= currentState ) or
		   ( not returnItemsInState and state == currentState ) then
			items[ id ] = nil
		else
			numItems = numItems + 1
		end
	end

	return items, numItems
end

function EHT.Housing.GetFurnitureCategory( id )
	id = EHT.Housing.FindFurnitureId( id )

	local _, _, dataId = GetPlacedHousingFurnitureInfo( id )
	if nil ~= dataId and 0 < dataId then
		local categoryId, subcategoryId = GetFurnitureDataCategoryInfo( dataId )
		return categoryId, subcategoryId
	end

	return 0, 0
end

function EHT.Housing.IsFurnitureInCategoryOrSubcategory( id, categoryId )
	local furnitureCategoryId, furnitureSubcategoryId = EHT.Housing.GetFurnitureCategory( id )
	return furnitureCategoryId == categoryId or furnitureSubcategoryId == categoryId
end

function EHT.Housing.GetFurnitureByCategory( categoryIds )
	if "table" ~= type( categoryIds ) then return end

	local id, dataId, subcategoryId
	local items = { }

	repeat
		id = GetNextPlacedHousingFurnitureId( id )
		if nil ~= id then
			local _, _, dataId = GetPlacedHousingFurnitureInfo( id )
			if nil ~= dataId and 0 < dataId then
				local _, subcategoryId = GetFurnitureDataCategoryInfo( dataId )
				if nil ~= subcategoryId and EHT.Util.IsListValue( categoryIds, subcategoryId ) then
					table.insert( items, EHT.Data.CreateFurniture( id ) )
				end
			end
		end
	until nil == id

	return items
end

function EHT.Housing.GetAllTargetDummies()
	return EHT.Housing.GetFurnitureByCategory( { EHT.CONST.FURNITURE_CATEGORY_ID.TARGET_DUMMIES } )
end

function EHT.Housing.GetAllAssistants()
	return EHT.Housing.GetFurnitureByCategory( { EHT.CONST.FURNITURE_CATEGORY_ID.ASSISTANT_BANKERS, EHT.CONST.FURNITURE_CATEGORY_ID.ASSISTANT_MERCHANTS } )
end

function EHT.Housing.GetAllCraftingStations( matchId )
	local items = EHT.Housing.GetFurnitureByCategory( { EHT.CONST.FURNITURE_CATEGORY_ID.CRAFTING_STATIONS } )

	local matchSetName = nil
	if nil ~= matchId then
		matchSetName = EHT.Housing.GetFurnitureSetName( matchId )
	end

	if nil == matchSetName then return items end

	for index = #items, 1, -1 do
		if EHT.Housing.GetFurnitureSetName( items[index].Id ) ~= matchSetName then
			table.remove( items, index )
		end
	end

	return items
end

------[[ Housing : Furniture ]]------

function EHT.Housing.RemoveFurniture( furnitureId )
	local effect = EHT.Data.GetEffectByRecordId( furnitureId )
	if effect then
		local record = effect:GetRecord()
		if record then
			if not EHT.Biz.CheckItemLock( furnitureId ) then
				if not EHT.Data.DeleteEffectRecord( record ) then
					effect:Delete()
				end
				return HOUSING_REQUEST_RESULT_SUCCESS
			end
		end
		return nil
	end

	local result
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureId )
	if id and pathIndex then
		EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.REMOVE_PATH_NODE_OP )

		result = HousingEditorRequestRemovePathNode( id, pathIndex )
		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.REMOVE_PATH_NODE_OP )
		end
	else
		EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.REMOVE_OP )

		result = HousingEditorRequestRemoveFurniture( furnitureId )
		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.REMOVE_OP )
		end
	end

	return result
end

function EHT.Housing.PlaceItem( bag, slotIndex, x, y, z, pitch, yaw, roll )
	EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.PLACE_OP )

	local result = HousingEditorRequestItemPlacement( bag, slotIndex, x, y, z, pitch, yaw, roll )
	if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
		EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.PLACE_OP )
	end

	return result
end

function EHT.Housing.PlaceCollectible( collectibleId, x, y, z, pitch, yaw, roll )
	EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.PLACE_OP )

	local result = HousingEditorRequestCollectiblePlacement( collectibleId, x, y, z, pitch, yaw, roll )
	if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
		EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.PLACE_OP )
	end

	return result
end

function EHT.Housing.AreFurnitureIdsEqual( id1, id2 )
	if "string" ~= type( id1 ) then id1 = string.fromId64( id1 ) end
	if "string" ~= type( id2 ) then id2 = string.fromId64( id2 ) end
	return id1 == id2
end

function EHT.Housing.IsItemIdFurniture( itemId )
	local fLink = EHT.Housing.GetFurnitureItemIdLink( itemId )
	if not IsItemLinkPlaceableFurniture( fLink ) then return false, nil, nil end

	local fName = GetItemLinkName( fLink )
	return true, fName, fLink
end

function EHT.Housing.IsItemIdCollectible( itemId )
	local cName = GetCollectibleName( itemId )
	local cLink = GetCollectibleLink( itemId )
	return nil ~= cName and "" ~= cName, cName, cLink
end

function EHT.Housing.IsItemLinkCollectible( link )
	local itemId = EHT.Housing.GetFurnitureLinkItemId( link )
	return nil ~= itemId and EHT.Housing.IsItemIdCollectible( itemId )
end

function EHT.Housing.GenerateEffectLink( effectId, effectTypeId, effectTypeName )
	if not effectTypeId or not effectTypeName then
		return EHT.LINK_UNKNOWN_EFFECT
	else
		return string.format( "|H1:effect:%s:%s:0:0:0:0|h%s|h", tostring( effectTypeId or 0 ), tostring( effectId or 0 ), effectTypeName or "Unknown Effect" )
	end
end

function EHT.Housing.GetFurnitureLink( furnitureId )
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureId )

	if EHT.Housing.IsEffectId( id ) then
		local effectType = EHT.Housing.GetEffectTypeById( id )
		if not effectType then return EHT.LINK_UNKNOWN_EFFECT end

		local effectTypeId = effectType.Index
		local effectTypeName = effectType.Name

		return EHT.Housing.GenerateEffectLink( id, effectTypeId, effectTypeName )
	end

	local link, collectibleLink = GetPlacedFurnitureLink( id, LINK_STYLE_BRACKETS )
	if nil == link or "" == link then link = collectibleLink end
	if nil == link then link = EHT.LINK_UNKNOWN_ITEM end

	if link and pathIndex then
		local linkDataTerminator = string.find( link, "%|h" )
		if linkDataTerminator then
			local linkData = string.sub( link, 1, linkDataTerminator - 1 )
			local linkTerminator = string.sub( link, linkDataTerminator )
			link = string.format( "%s:node%d%s", linkData, pathIndex, linkTerminator )
		end
	end

	return link
end

function EHT.Housing.GetEffectLinkInfo( link )
	if nil == link then return nil end
	local _, _, effectTypeId, effectId = string.find( link, "effect:(%d+):(%d+):" )
	return tonumber( effectId ), tonumber( effectTypeId )
end

function EHT.Housing.GetFurnitureLinkName( link, pathIndex, excludePathIndex )
	if pathIndex == EHT.INVALID_PATH_NODE then
		pathIndex = nil
	end

	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectId and effectTypeId then
		local effectType = EHT.EffectType:GetByIndex( effectTypeId )
		return effectType and effectType.Name or ""
	end

	local name = GetItemLinkName( link )
	if nil == name or "" == name then
		name = GetCollectibleName( GetCollectibleIdFromLink( link ) )
	end

	if link and not pathIndex then
		local _, nodeSeparator = string.find( link, "%:node" )
		if nodeSeparator then
			local nodeStartIndex = nodeSeparator + 1
			nodeSeparator = string.find( link, "%p", nodeStartIndex )
			if nodeSeparator then
				local nodeEndIndex = nodeSeparator - 1
				pathIndex = tonumber( string.sub( link, nodeStartIndex, nodeEndIndex ) )
			end
		end
	end

	if not excludePathIndex and pathIndex and nil ~= name and "" ~= name then
		name = string.format( "(%s%d) %s", EHT.ICON_PATHING, pathIndex, name )
	end

	return name
end

function EHT.Housing.GetFurnitureLinkIconFile( link )
	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectId and effectTypeId then
		return "/esoui/art/treeicons/gamepad/achievement_categoryicon_champion.dds"
	end

	local itemIcon = GetItemLinkIcon( link )
	local collectibleId = GetCollectibleIdFromLink( link )
	if nil ~= collectibleId and 0 ~= collectibleId then _, _, itemIcon = GetCollectibleInfo( collectibleId ) end
	return itemIcon
end

function EHT.Housing.GetFurnitureLinkIcon( link )
	local itemIcon = EHT.Housing.GetFurnitureLinkIconFile( link )
	if nil ~= itemIcon and "" ~= itemIcon then itemIcon = zo_iconFormat( itemIcon ) end
	return itemIcon or ""
end

function EHT.Housing.GetFurnitureDisplayLink( link )
	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectId and effectTypeId then
		return link
	end

	local itemId = EHT.Housing.GetFurnitureLinkItemId( link )
	local displayLink = EHT.Housing.GetFurnitureItemIdLink( itemId )
	return displayLink
end

function EHT.Housing.GetFurnitureSetName( id )
	if EHT.Housing.IsEffectId( id ) then
		return nil
	end

	local link = EHT.Housing.GetFurnitureLink( id )
	local setName = nil

	if nil ~= link then
		setName = EHT.Housing.GetFurnitureLinkSetName( link )
	end

	return setName
end

function EHT.Housing.GetFurnitureLinkSetName( link )
	local setName = nil

	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectId and effectTypeId then return nil end

	if nil ~= link then
		-- Map Name exceptions for consistency

		local itemId = EHT.Housing.GetFurnitureLinkItemId( link )
		if 137874 == itemId then return EHT.Housing.GetFurnitureLinkSetName( EHT.Housing.GetFurnitureItemIdLink( 119711 ) ) end

		-- Otherwise, parse the Set Name from the Item's Name

		local itemName = EHT.Housing.GetFurnitureLinkName( link )
		if nil ~= itemName then
			itemName = string.lower( itemName )

			local indexParen1 = string.find( itemName, "(", 1, true )
			if nil ~= indexParen1 then
				local indexParen2 = string.find( itemName, ")", indexParen1 + 1, true )
				if nil ~= indexParen2 then indexParen2 = indexParen2 - 1 end
				setName = string.sub( itemName, indexParen1 + 1, indexParen2 )
			end
		end
	end

	return setName
end

function EHT.Housing.GetFurnitureLinkItemId( link )
	if nil == link or "" == link or link == LINK_UNKNOWN_EFFECT or link == LINK_UNKNOWN_ITEM then return nil end

	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectTypeId then return EHT.BASE_EFFECT_ITEM_TYPE_ID + effectTypeId end

	local startIndex

	if string.sub( link, 4, 9 ) == ":item:" then
		startIndex = 10
	elseif string.sub( link, 4, 16 ) == ":collectible:" then
		startIndex = 17
	else
		return link
	end

	local colonIndex = string.find( link, ":", startIndex + 1 )
	local pipeIndex = string.find( link, "|", startIndex + 1 )

	if nil == colonIndex and nil == pipeIndex then return nil end
	if nil ~= colonIndex and nil ~= pipeIndex then colonIndex = math.min( colonIndex, pipeIndex ) end

	return tonumber( string.sub( link, startIndex, ( nil ~= colonIndex and colonIndex or pipeIndex ) - 1 ) )
end

function EHT.Housing.GetFurnitureItemId( id )
	local link = EHT.Housing.GetFurnitureLink( id )
	return EHT.Housing.GetFurnitureLinkItemId( link ), link
end

function EHT.Housing.GetFurnitureItemIdLink( itemId )
	itemId = tonumber( itemId )
	if not itemId then
		return nil
	end

	local effectType = EHT.Housing.GetItemIdEffectType( itemId )
	if effectType then
		return EHT.Housing.GenerateEffectLink( nil, effectType.Index, effectType.Name )
	end

	local dataId = GetCollectibleFurnitureDataId( itemId )

	if nil ~= dataId and 0 ~= dataId then
		return GetCollectibleLink( itemId, LINK_STYLE_BRACKETS )
	else
		return string.format( "|H1:item:%s%s|h|h", tostring( itemId ), string.rep( ":0", 20 ) )
	end
end

function EHT.Housing.GetFurnitureItemIdName( itemId )
	local link = EHT.Housing.GetFurnitureItemIdLink( itemId )
	if link then return EHT.Housing.GetFurnitureLinkName( link ) end
	return nil
end

function EHT.Housing.GetFurnitureLimitType( link )
	if nil == link or "" == link then return end

	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	if effectId and effectTypeId then return 1000, 9999 end

	local dataId, itemId, limitType, limitName
	itemId = EHT.Housing.GetFurnitureLinkItemId( link )

	if nil == itemId or 0 >= itemId then return end

	if EHT.Housing.IsItemIdCollectible( itemId ) then
		dataId = GetCollectibleFurnitureDataId( itemId )
	else
		dataId = GetItemLinkFurnitureDataId( link )
	end

	if nil ~= dataId then
		_, _, _, limitType = GetFurnitureDataInfo( dataId )
		limitName = EHT.Housing.GetLimitName( limitType )
	end

	return limitType, limitName
end

function EHT.Housing.GetFurnitureLimitTypeByItemId( itemId )
	return EHT.Housing.GetFurnitureLimitType( EHT.Housing.GetFurnitureItemIdLink( itemId ) )
end

function EHT.Housing.GetFurnitureLimitTypeByFurnitureId( id )
	return EHT.Housing.GetFurnitureLimitType( EHT.Housing.GetFurnitureLink( id ) )
end

function EHT.Housing.GetFurniturePosition( furnitureID )
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureID )
	local x, y, z

	if id and pathIndex then
		x, y, z = HousingEditorGetPathNodeWorldPosition( id, pathIndex )
	else
		local effect = EHT.Data.GetEffectByRecordId( id )
		if effect then
			x, y, z = effect:GetPosition()
		else
			x, y, z = HousingEditorGetFurnitureWorldPosition( id )
		end
	end
--df("GetPos[%d]: %d, %d, %d (%s)", pathIndex or 0, x, y, z, EHT.Util.GetCallstackFunctionNamesString())
	return x, y, z
end

function EHT.Housing.GetFurnitureOrientation( furnitureID )
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureID )

	if id and pathIndex then
		return HousingEditorGetPathNodeOrientation( id, pathIndex )
	end

	local effect = EHT.Data.GetEffectByRecordId( id )
	if effect then
		return effect:GetOrientation()
	end

	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( id )
	return pitch % RAD360, yaw % RAD360, roll % RAD360
end

function EHT.Housing.GetFurniturePositionAndOrientation( furnitureID )
	local pathFurnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureID )
	if pathFurnitureId and pathIndex then
		local x, y, z, yaw, speed, delayTime = EHT.Housing.GetFurniturePathNodeInfo( pathFurnitureId, pathIndex )
		return x, y, z, 0, yaw, 0, speed, delayTime
	end

	local x, y, z = EHT.Housing.GetFurniturePosition( furnitureID )
	local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( furnitureID )
	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.FastGetFurniturePositionAndOrientation( furnitureID )
	local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureID )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureID )
	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.GetFirstFurnitureByItemId( itemId )
	local id = EHT.Housing.GetNextFurnitureId()

	while id do
		local iid = EHT.Housing.GetFurnitureItemId( id )

		if iid and iid == itemId then
			return id
		end

		id = EHT.Housing.GetNextFurnitureId( id )
	end

	return nil
end

function EHT.Housing.GetSelectedFurnitureAndNode()
	local id = HousingEditorGetSelectedFurnitureId()
	if not id then
		id = HousingEditorGetSelectedPathNodeFurnitureId()
		if 0 == id then
			id = nil
		end
	end
	local pathIndex = HousingEditorGetSelectedPathNodeIndex()
	if pathIndex and pathIndex ~= EHT.INVALID_PATH_NODE then
		id = EHT.Housing.GetFurniturePathNodeId( id, pathIndex )
	end
	return id
end

function EHT.Housing.GetTargetFurnitureId()
	return EHT.Housing.GetFurniturePathNodeId( HousingEditorGetTargetInfo() )
end

function EHT.Housing.GetFurnitureInfo( id )
	local furnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( id )
	if nil == furnitureId then return nil end

	local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
	if ( nil == x or ( 0 == x and 0 == y and 0 == z ) ) and not EHT.Housing.IsEffectId( furnitureId ) then return nil end

	local link = EHT.Housing.GetFurnitureLink( id )
	local itemId = EHT.Housing.GetFurnitureLinkItemId( link )
	local name = EHT.Housing.GetFurnitureLinkName( link, pathIndex )
	local icon = EHT.Housing.GetFurnitureLinkIconFile( link )
	local collectibleId = nil
	local limitType = nil
	local dataId = nil

	if EHT.Housing.IsItemIdCollectible( itemId ) then
		collectibleId = itemId
		dataId = GetCollectibleFurnitureDataId( collectibleId )
	else
		dataId = GetItemLinkFurnitureDataId( link )
	end

	if nil ~= dataId then
		_, _, _, limitType = GetFurnitureDataInfo( dataId )
	end

	return x, y, z, pitch, yaw, roll, itemId, collectibleId, link, name, icon, dataId, limitType
end

function EHT.Housing.GetKnownFurniturePositionAndOrientation( furnitureId )
	local x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha
	local house, group, item
	local houseId = EHT.Housing.GetHouseId()

	house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then return end

	local rec = EHT.Housing.GetCachedFurniture( furnitureId )
	if rec then
		x, y, z, pitch, yaw, roll = rec[1], rec[2], rec[3], rec[4], rec[5], rec[6]
	else
		x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( furnitureId )
		if EHT.Housing.IsEffectId( furnitureId ) then
			local effect = EHT.Data.GetEffectByRecordId( furnitureId )
			if effect then
				sizeX, sizeY, sizeZ = effect:GetSize()
				color, alpha = effect:GetCompressedColor()
				metaData = EHT.Util.CloneTable( effect:GetMetaDataTable() )
			end
		end
	end

	return x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha
end

function EHT.Housing.SetFurniturePosition(furnitureId, x, y, z)
	local result
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo(furnitureId)
	local currentX, currentY, currentZ = EHT.Housing.GetFurniturePosition(furnitureId)
	
	x, y, z = x or currentX, y or currentY, z or currentZ

	if id and pathIndex then
		result = EHT.Housing.SetFurniturePathNodeInfo( id, pathIndex, x, y, z )
	else
		EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )

		local effect = EHT.Data.GetEffectByRecordId( id )
		if effect then
			if not EHT.Biz.CheckItemLock( id ) then
				result = effect:SetPosition( x, y, z )
				EHT.Data.UpdateEffectRecord( effect:GetRecord(), effect )
			end
		else
			result = HousingEditorRequestChangePosition( id, x, y, z )
		end

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )
		end
	end

	EHT.UI.QueueRefreshGroupedIndicators()
	EHT.UI.QueueRefreshGroupOutlineIndicators()
	EHT.UI.QueueRefreshLockedIndicators()

	return result
end

function EHT.Housing.SetFurnitureOrientation(furnitureId, pitch, yaw, roll)
	local result
	local id, pathIndex = EHT.Housing.GetFurnitureIdInfo(furnitureId)
	local currentPitch, currentYaw, currentRoll = EHT.Housing.GetFurnitureOrientation(furnitureId)

	pitch, yaw, roll = EHT.Housing.CorrectGimbalLock(pitch or currentPitch, yaw or currentYaw, roll or currentRoll, false, furnitureId)

	if id and pathIndex then
		result = EHT.Housing.SetFurniturePathNodeInfo( id, pathIndex, nil, nil, nil, yaw )
	else
		EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )

		local effect = EHT.Data.GetEffectByRecordId( id )
		if effect then
			if not EHT.Biz.CheckItemLock( id ) then
				result = effect:SetOrientation( pitch, yaw, roll )
				EHT.Data.UpdateEffectRecord( effect:GetRecord(), effect )
			end
		else
			result = HousingEditorRequestChangeOrientation( id, pitch, yaw, roll )
		end

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )
		end
	end

	EHT.UI.QueueRefreshGroupedIndicators()
	EHT.UI.QueueRefreshGroupOutlineIndicators()
	EHT.UI.QueueRefreshLockedIndicators()

	return result
end

function EHT.Housing.SetFurniturePositionAndOrientation( furnitureId, x, y, z, pitch, yaw, roll, speed, delayTime )
	local result

	if nil ~= x and nil ~= pitch then
		local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureId )
		local effect = EHT.Data.GetEffectByRecordId( id )
		local currentX, currentY, currentZ, currentPitch, currentYaw, currentRoll = EHT.Housing.GetFurniturePositionAndOrientation( furnitureId )

		x, y, z = x or currentX, y or currentY, z or currentZ
		pitch, yaw, roll = EHT.Housing.CorrectGimbalLock(pitch or currentPitch, yaw or currentYaw, roll or currentRoll, false, id )

		local EPSILON = 1
		if	math.floor( math.abs( currentX - x ) ) < EPSILON and
			math.floor( math.abs( currentY - y ) ) < EPSILON and
			math.floor( math.abs( currentZ - z ) ) < EPSILON and
			math.floor( math.abs( 10000 * ( currentPitch % RAD360 ) - 10000 * ( pitch % RAD360 ) ) ) < EPSILON and
			math.floor( math.abs( 10000 * ( currentYaw % RAD360 ) - 10000 * ( yaw % RAD360 ) ) ) < EPSILON and
			math.floor( math.abs( 10000 * ( currentRoll % RAD360 ) - 10000 * ( roll % RAD360 ) ) ) < EPSILON then
			return HOUSING_REQUEST_RESULT_SUCCESS
		end

		if id and pathIndex then
			result = EHT.Housing.SetFurniturePathNodeInfo( id, pathIndex, x, y, z, yaw, speed, delayTime )
--df("EHT.Housing.SetFurniturePathNodeInfo( %s, %d ): %s", string.fromId64( id ) or "nil", pathIndex or -1, EHT.GetHousingRequestResultName( result ) or "nil")
		else
			if effect then
				if not EHT.Biz.CheckItemLock( id ) then
					result = effect:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
					EHT.Data.UpdateEffectRecord( effect:GetRecord(), effect )
				end
			else
				EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )

				result = HousingEditorRequestChangePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
				if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
					EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_OP )
				end
			end
		end

		EHT.UI.QueueRefreshGroupedIndicators()
		EHT.UI.QueueRefreshGroupOutlineIndicators()
		EHT.UI.QueueRefreshLockedIndicators()
	elseif nil ~= x then
		result = EHT.Housing.SetFurniturePosition( furnitureId, x, y, z )
	elseif nil ~= pitch then
		result = EHT.Housing.SetFurnitureOrientation( furnitureId, pitch, yaw, roll )
	end

	return result
end

function EHT.Housing.HasFurnitureChanged(
	x1, y1, z1, pitch1, yaw1, roll1, sizeX1, sizeY1, sizeZ1, color1, alpha1,
	x2, y2, z2, pitch2, yaw2, roll2, sizeX2, sizeY2, sizeZ2, color2, alpha2 )

	if	nil == x1 or nil == x2 or
		nil == y1 or nil == y2 or
		nil == z1 or nil == z2 or
		nil == pitch1 or nil == pitch2 or
		nil == yaw1 or nil == yaw2 or
		nil == roll1 or nil == roll2 or
		0 == x1 or 0 == x2 or
		0 == y1 or 0 == y2 or
		0 == z1 or 0 == z2 then
		return false
	end

	x1, x2 = math.floor( x1 ), math.floor( x2 )
	y1, y2 = math.floor( y1 ), math.floor( y2 )
	z1, z2 = math.floor( z1 ), math.floor( z2 )
	pitch1, pitch2 = pitch1 % RAD360, pitch2 % RAD360
	yaw1, yaw2 = yaw1 % RAD360, yaw2 % RAD360
	roll1, roll2 = roll1 % RAD360, roll2 % RAD360
	sizeX1, sizeY1, sizeZ1 = zo_roundToNearest( sizeX1 or 0, 0.01 ), zo_roundToNearest( sizeY1 or 0, 0.01 ), zo_roundToNearest( sizeZ1 or 0, 0.01 )
	sizeX2, sizeY2, sizeZ2 = zo_roundToNearest( sizeX2 or 0, 0.01 ), zo_roundToNearest( sizeY2 or 0, 0.01 ), zo_roundToNearest( sizeZ2 or 0, 0.01 )
	
	if nil ~= color1 and nil ~= color2 then
		color1, color2 = zo_roundToNearest( color1 or 0, 0.001 ), zo_roundToNearest( color2 or 0, 0.001 )
	end

	if nil ~= alpha1 and nil ~= alpha2 then
		alpha1, alpha2 = zo_roundToNearest( alpha1 or 1, 0.001 ), zo_roundToNearest( alpha2 or 1, 0.001 )
	end

	local hasChanged =
		x1 ~= x2 or
		y1 ~= y2 or
		z1 ~= z2 or
		0.00001 < math.abs( pitch1 - pitch2 ) or
		0.00001 < math.abs( yaw1 - yaw2 ) or
		0.00001 < math.abs( roll1 - roll2 ) or
		sizeX1 ~= sizeX2 or
		sizeY1 ~= sizeY2 or
		sizeZ1 ~= sizeZ2 or
		color1 ~= color2 or
		alpha1 ~= alpha2
	return hasChanged
end

function EHT.Housing.HasFurnitureIdChanged( furnitureId, x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha, groups )
	local cx, cy, cz, cpitch, cyaw, croll = EHT.Housing.GetFurniturePositionAndOrientation( furnitureId )
	local csizeX, csizeY, csizeZ, ccolor, calpha --, cgroups

	local effect = EHT.Data.GetEffectByRecordId( furnitureId )
	if effect then
		csizeX, csizeY, csizeZ = effect:GetSize()
		ccolor, calpha = effect:GetCompressedColor()
		-- cgroups = effect:GetEffectGroupBitmask()
	end

	local hasChanged = EHT.Housing.HasFurnitureChanged(
		cx, cy, cz, cpitch, cyaw, croll, csizeX, csizeY, csizeZ, ccolor, calpha,
		x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha )
	return hasChanged
end

function EHT.Housing.FindFurnitureId(furnitureId, link)
	local idType = type(furnitureId)

	if "number" ~= idType and "string" ~= idType then
		return
	end

	local sid = furnitureId

	if "number" == idType then
		sid = string.fromId64(furnitureId)
	elseif EHT.Housing.IsFurniturePathNodeId(sid) then
		return sid
	end

	local id = EHT.FurnitureIdList[sid]

	if not id then
		return
	end

	if nil ~= id and nil ~= link and "" ~= link then
		if GetPlacedFurnitureLink(id) ~= link then
			local itemId = EHT.Housing.GetFurnitureLinkItemId(link)
			local furnItemId = EHT.Housing.GetFurnitureItemId(id)

			if itemId ~= furnItemId then
				id = nil
			end
		end
	end

	return id
end

EHT.FID = EHT.Housing.FindFurnitureId

function EHT.Housing.GetAllFurnitureBounds( radius, itemNameFilter, maxDimension )
	local list = { }
	local verts = { }
	local id, dimMax, pitch, yaw, roll, x, y, z, minX, minY, minZ, maxX, maxY, maxZ, itemName

	maxDimension = maxDimension or MAX_AABB_DIMENSION

	for index = 1, 8 do
		verts[index] = { 0, 0, 0 }
	end

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )
		if id then
			local EXCLUDE_PATH_NODE = true
			itemName = EHT.Housing.GetFurnitureLinkName( EHT.Housing.GetFurnitureLink( id, LINK_STYLE_BRACKETS ), nil, EXCLUDE_PATH_NODE )
			if not itemNameFilter or itemName == itemNameFilter then
				x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
				minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureLocalBounds( id )

				verts[1][1],verts[1][2],verts[1][3] = EHT.World.Rotate( minX, minY, minZ, pitch, yaw, roll )
				verts[2][1],verts[2][2],verts[2][3] = EHT.World.Rotate( maxX, minY, minZ, pitch, yaw, roll )
				verts[3][1],verts[3][2],verts[3][3] = EHT.World.Rotate( minX, maxY, minZ, pitch, yaw, roll )
				verts[4][1],verts[4][2],verts[4][3] = EHT.World.Rotate( maxX, maxY, minZ, pitch, yaw, roll )
				verts[5][1],verts[5][2],verts[5][3] = EHT.World.Rotate( minX, minY, maxZ, pitch, yaw, roll )
				verts[6][1],verts[6][2],verts[6][3] = EHT.World.Rotate( maxX, minY, maxZ, pitch, yaw, roll )
				verts[7][1],verts[7][2],verts[7][3] = EHT.World.Rotate( minX, maxY, maxZ, pitch, yaw, roll )
				verts[8][1],verts[8][2],verts[8][3] = EHT.World.Rotate( maxX, maxY, maxZ, pitch, yaw, roll )

				minX, minY, minZ = math.huge, math.huge, math.huge
				maxX, maxY, maxZ = -999999, -999999, -999999

				for _, v in ipairs( verts ) do
					minX, minY, minZ = math.min( minX, v[1] ), math.min( minY, v[2] ), math.min( minZ, v[3] )
					maxX, maxY, maxZ = math.max( maxX, v[1] ), math.max( maxY, v[2] ), math.max( maxZ, v[3] )
				end

				--if math.abs( minX ) > maxDimension then minX = -maxDimension end
				--if math.abs( minY ) > maxDimension then minY = -maxDimension end
				--if math.abs( minZ ) > maxDimension then minZ = -maxDimension end
				--if math.abs( maxX ) > maxDimension then maxX = maxDimension end
				--if math.abs( maxY ) > maxDimension then maxY = maxDimension end
				--if math.abs( maxZ ) > maxDimension then maxZ = maxDimension end
				if maxX - minX > maxDimension then
					local dimDelta = 0.5 * ( ( maxX - minX ) - maxDimension )
					minX, maxX = minX + dimDelta, maxX - dimDelta
				end

				if maxY - minY > maxDimension then
					local dimDelta = 0.5 * ( ( maxY - minY ) - maxDimension )
					minY, maxY = minY + dimDelta, maxY - dimDelta
				end

				if maxZ - minZ > maxDimension then
					local dimDelta = 0.5 * ( ( maxZ - minZ ) - maxDimension )
					minZ, maxZ = minZ + dimDelta, maxZ - dimDelta
				end

				minX, minY, minZ = x + minX, y + minY, z + minZ
				maxX, maxY, maxZ = x + maxX, y + maxY, z + maxZ
				dimMax = math.max( maxX - minX, maxY - minY, maxZ - minZ )

				table.insert( list, EHT.Housing.CreateAxisAlignedBoundingBox( id, itemName, x, y, z, minX, minY, minZ, maxX, maxY, maxZ, radius ) ) -- dimMax <= radius and radius or 0 ) )
			end
		end
	until not id

	return list
end

do
	function CreateFurnitureMatchKey( itemId, x, y, z, pitch, yaw, roll )
		return string.format( "%s_%d_%d_%d_%d_%d_%d", tostring( itemId ), floor( x ), floor( y ), floor( z ), floor( math.deg( pitch % RAD360 ) ), floor( math.deg( yaw % RAD360 ) ), floor( math.deg( roll % RAD360 ) ) )
	end

	function CompareFurniture( itemA, itemB, exactMatch )
		local pitchA, pitchB = ( itemA.Pitch and itemA.Pitch or itemA[3] ) % RAD360, ( itemB.Pitch and itemB.Pitch or itemB[3] ) % RAD360
		local yawA, yawB = ( itemA.Yaw and itemA.Yaw or itemA[4] ) % RAD360, ( itemB.Yaw and itemB.Yaw or itemB[4] ) % RAD360
		local rollA, rollB = ( itemA.Roll and itemA.Roll or itemA[5] ) % RAD360, ( itemB.Roll and itemB.Roll or itemB[5] ) % RAD360

		pitchA, pitchB = exactMatch and pitchA or floor( math.deg( pitchA ) ), exactMatch and pitchB or floor( math.deg( pitchB ) )
		yawA, yawB = exactMatch and yawA or floor( math.deg( yawA ) ), exactMatch and yawB or floor( math.deg( yawB ) )
		rollA, rollB = exactMatch and rollA or floor( math.deg( rollA ) ), exactMatch and rollB or floor( math.deg( rollB ) )

		return	1 >= math.abs( floor( pitchA * 1000 ) - floor( pitchB * 1000 ) ) and
				1 >= math.abs( floor( yawA * 1000 ) - floor( yawB * 1000 ) ) and
				1 >= math.abs( floor( rollA * 1000 ) - floor( rollB * 1000 ) )
	end

	function EHT.Housing.FuzzyMatchFurniture( items )
		local results = { }
		local resultsById = { }
		local validById = { }

		if "table" ~= type( items ) then
			return results
		end

		for index, item in ipairs( items ) do
			local id = string.fromId64( item.Id )
			local itemId = tonumber( item.ItemId )
			local x, y, z, pitch, yaw, roll = item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll

			if not itemId then
				itemId = EHT.Housing.GetFurnitureLinkItemId( item.Link )
			end

			if id and "" ~= id and itemId then
				validById[ "i" .. id ] = true
			else
				x, y, z = math.floor( x ), math.floor( y ), math.floor( z )
				pitch, yaw, roll = round( math.deg( pitch ), 2 ), round( math.deg( yaw ), 2 ), round( math.deg( roll ), 2 )

				local result = {
					Index = index,
					Item = item,
					Id = id,
					ItemId = itemId,
					X = x,
					Y = y,
					Z = z,
					Pitch = pitch,
					Yaw = yaw,
					Roll = roll,
				}

				table.insert( results, result )
				resultsById[ "i" .. id ] = result
			end
		end

		local placed = { }
		local nextId = EHT.Housing.GetNextFurnitureId()

		while nextId do
			local id = nextId
			local itemId = EHT.Housing.GetFurnitureItemId( id )
			local matched = false

			id, itemId = string.fromId64( id ), tonumber( itemId )
			local valid = validById[ "i" .. id ]

			if not valid then
				local resultById = resultsById[ "i" .. id ]

				if resultById and itemId == resultById.ItemId then
					resultById.MatchId = id
					matched = true
				else
					local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( nextId )

					x, y, z = math.floor( x ), math.floor( y ), math.floor( z )
					pitch, yaw, roll = round( math.deg( pitch ), 2 ), round( math.deg( yaw ), 2 ), round( math.deg( roll ), 2 )

					local placedItem = {
						Id = id,
						ItemId = itemId,
						X = x,
						Y = y,
						Z = z,
						Pitch = pitch,
						Yaw = yaw,
						Roll = roll,
					}

					table.insert( placed, placedItem )
				end
			end

			nextId = EHT.Housing.GetNextFurnitureId( nextId )
		end

		for index, result in ipairs( results ) do
			if not result.MatchId then
				local itemId, x, y, z, pitch, yaw, roll = result.ItemId, result.X, result.Y, result.Z, result.Pitch, result.Yaw, result.Roll

				for itemIndex, item in ipairs( placed ) do
					if itemId == item.ItemId and x == item.X and y == item.Y and z == item.Z and pitch == item.Pitch and yaw == item.Yaw and roll == item.Roll then
						result.MatchId = item.Id
						table.remove( placed, itemIndex )

						break
					end
				end
			end
		end

		for index, result in ipairs( results ) do
			if not result.MatchId then
				local itemId = result.ItemId
				local x, y, z = result.X or 0, result.Y or 0, result.Z or 0
				local bestMatchId, bestMatchIndex, bestDistance = nil, nil, math.huge

				for itemIndex, item in ipairs( placed ) do
					if itemId == item.ItemId then
						local distance = zo_distance3D( item.X, item.Y, item.Z, x, y, z )

						if distance < bestDistance then
							bestDistance = distance
							bestMatchIndex = itemIndex
							bestMatchId = item.Id
						end
					end
				end

				if bestMatchId then
					result.MatchId = bestMatchId
					table.remove( placed, bestMatchIndex )
				end
			end
		end

		return results
	end
--[[
			if not matched then
				local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
				local key = CreateFurnitureMatchKey( itemId, x, y, z, pitch, yaw, roll )
				local list = unmatched[key]

				if not list then
					list = { }
					unmatched[key] = list
				end

				table.insert( list, { id, itemId, pitch, yaw, roll } )
			end

		end

		local exactMatch = true
		local loops, matches = 0, 0

		while 2 > loops do
			for _, item in pairs( items ) do
				if not item.MatchId and item.ItemId and item.X and item.Y and item.Z and item.Pitch and item.Yaw and item.Roll then
					local itemId = item.ItemId
					local key = CreateFurnitureMatchKey( itemId, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
					local list = unmatched[key]

					if list then
						for listIndex, listItem in pairs( list ) do
							if CompareFurniture( item, listItem, exactMatch ) then
								item.MatchId = listItem[1]
								table.remove( list, listIndex )
								matches = matches + 1

								break
							end
						end
					end
				end
			end

			if exactMatch then
				exactMatch = false
			else
				break
			end

			loops = loops + 1
		end

		for _, item in pairs( items ) do
			if not item.MatchId then
				local itemId = tonumber( item.ItemId )
				if itemId then
					local matched = false

					for _, list in pairs( unmatched ) do
						for listIndex, listItem in pairs( list ) do
							if tonumber( listItem[2] ) == itemId then
								item.MatchId = listItem[1]
								table.remove( list, listIndex )
								matches = matches + 1
								matched = true

								break
							end
						end

						if matched then
							break
						end
					end
				end
			end
		end

		return items
	end
]]
end

function EHT.Housing.FindNearbyFurniture( matchId, radius, homogenous )
	local cX, cY, cZ = EHT.Housing.GetFurnitureCenter( matchId )
	local id = EHT.Housing.GetNextFurnitureId()
	local list = { }
	local x, y, z, link, name, matchLink, matchName
	local EXCLUDE_PATH_NODE = true

	if homogenous then
		matchLink = EHT.Housing.GetFurnitureLink( matchId )
		matchName = EHT.Housing.GetFurnitureLinkName( matchLink, nil, EXCLUDE_PATH_NODE )
	end

	while id do
		if matchName then
			link = EHT.Housing.GetFurnitureLink( id )
			name = EHT.Housing.GetFurnitureLinkName( link, nil, EXCLUDE_PATH_NODE )
		end

		if not matchName or name == matchName then
			x, y, z = EHT.Housing.GetFurnitureCenter( id )

			if zo_distance3D( cX, cY, cZ, x, y, z ) <= radius then
				table.insert( list, id )
			end
		end

		id = EHT.Housing.GetNextFurnitureId( id )
	end

	return list
end

function EHT.Housing.FindAdjacentFurniture( furnitureIdOrObject, radius, matchItem, matchConnected, maxRange )
	if nil == matchItem then matchItem = false end
	if nil == matchConnected then matchConnected = false end
	if nil == radius then radius = EHT.SavedVars.SelectionRadius end

	local furnitureId, sFurnitureId, dimX, dimY, dimZ, dimMax, x, y, z, minX, minY, minZ, maxX, maxY, maxZ, itemName, itemLink, collectibleLink
	local matches = { }

	if "table" == type( furnitureIdOrObject ) then
		local f = furnitureIdOrObject

		furnitureId = f.Id
		x, y, z = f.X, f.Y, f.Z
		minX, minY, minZ, maxX, maxY, maxZ = f.MinX, f.MinY, f.MinZ, f.MaxX, f.MaxY, f.MaxZ
		itemLink = EHT.Housing.GetFurnitureLink( furnitureId )
		local EXCLUDE_PATH_NODE = true
		itemName = EHT.Housing.GetFurnitureLinkName( itemLink, nil, EXCLUDE_PATH_NODE )
	else
		furnitureId = furnitureIdOrObject
		x, y, z = EHT.Housing.GetFurnitureCenter( furnitureId )
		minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureWorldBounds( furnitureId )
		itemLink = EHT.Housing.GetFurnitureLink( furnitureId )
		local EXCLUDE_PATH_NODE = true
		itemName = EHT.Housing.GetFurnitureLinkName( itemLink, nil, EXCLUDE_PATH_NODE )
	end

	if nil == x or nil == minX or 0 == x or 0 == minX then
		return matches
	end

	sFurnitureId = string.fromId64( furnitureId )
 	local items = EHT.Housing.GetAllFurnitureBounds( radius, matchItem and itemName, maxRange or MAX_AABB_DIMENSION )

	for index, item in ipairs( items ) do
		if sFurnitureId == string.fromId64( item.Id ) then
			table.insert( matches, item )
			table.remove( items, index )
			break
		end
	end

	if not matches[1] then
		return matches
	end

	local centerX, centerY, centerZ = matches[1].X, matches[1].Y, matches[1].Z
	local itemsAdded

	repeat
		itemsAdded = 0

		for index = #items, 1, -1 do
			for matchIndex = 1, #matches do
				if EHT.Housing.AreBoundingBoxesIntersecting( items[ index ], matches[ matchIndex ] ) then
					if not maxRange or EHT.Housing.MinBoundingBoxDistance( items[index], centerX, centerY, centerZ ) <= maxRange then
						table.insert( matches, items[ index ] )
						table.remove( items, index )
						itemsAdded = itemsAdded + 1

						break
					end
				end

				if not matchConnected then
					break
				end
			end
		end
	until 0 == itemsAdded

	if 0 < #matches then
		local itemIds = { }
		for index, item in ipairs( matches ) do
			itemIds[ index ] = item.Id
		end

		local pathNodeIds = EHT.Housing.FindPathNodes( furnitureId )
		if pathNodeIds and 0 < #pathNodeIds then
			itemIds = EHT.Util.UnionTables( itemIds, pathNodeIds, string.fromId64 )
		end

		return itemIds
	else
		return { }
	end
end

function EHT.Housing.FindPathNodes( furnitureId )
	furnitureId = EHT.Housing.GetFurnitureIdInfo( furnitureId )
	furnitureId = EHT.Housing.FindFurnitureId( furnitureId )
	local ids = { }

	if furnitureId then
		local numPathNodes = EHT.Housing.GetNumFurniturePathNodes( furnitureId )
		if numPathNodes and 0 < numPathNodes then
			for pathIndex = 1, numPathNodes do
				local id = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
				table.insert( ids, id )
			end
		end
	end

	return ids
end

function EHT.Housing.IsValidFurnitureId( furnitureId, furnitureItemId, furnitureLink )
	local pathFurnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureId )
	if pathFurnitureId and pathIndex then
		local x, y, z, yaw, speed, delayTime = EHT.Housing.GetFurniturePathNodeInfo( pathFurnitureId, pathIndex )
		return nil ~= x and 0 ~= x
	end

	furnitureId = EHT.Housing.FindFurnitureId( furnitureId )
	local itemId = EHT.Housing.GetFurnitureItemId( furnitureId )

	if not furnitureId or not itemId then
		return false
	end

	if not furnitureItemId or "" == furnitureItemId or 0 == furnitureItemId then
		if nil ~= furnitureLink and "" ~= furnitureLink then
			furnitureItemId = EHT.Housing.GetFurnitureLinkItemId( furnitureLink )
		else
			furnitureItemId = nil
		end
	end

	if furnitureItemId and tostring( itemId ) ~= tostring( furnitureItemId ) then
		return false
	end

	return true
end

function EHT.Housing.FindInventoryFurniture( furnitureLink, bagId )
	if nil ~= furnitureLink then
		local itemName = EHT.Housing.GetFurnitureLinkName( furnitureLink )

		if nil ~= itemName then
			local bagIds = nil
			
			if nil ~= bagId then
				bagIds = { bagId }
			else
				bagIds = EHT.CONST.BAG_IDS
			end

			for _, bagId in ipairs( bagIds ) do
				local slots = GetBagSize( bagId ) - 1

				for index = 0, slots do
					if EHT.Housing.GetFurnitureLinkName( GetItemLink( bagId, index ) ) == itemName then
						return bagId, index
					end
				end
			end
		end
	end

	return nil, nil
end

function EHT.Housing.GetBagFurnitureCounts( bagId, useItemName )
	local bagIds = nil

	if nil ~= bagId then
		bagIds = { bagId }
	else
		bagIds = EHT.CONST.BAG_IDS
	end

	local itemTotals = { }
	local itemLink = nil

	for _, bagId in pairs( bagIds ) do
		local slots = GetBagSize( bagId ) - 1

		for index = 0, slots do
			itemLink = GetItemLink( bagId, index )

			if nil ~= itemLink and "" ~= itemLink then
				if useItemName then
					itemLink = EHT.Housing.GetFurnitureLinkName( itemLink )
				end

				local itemCount = itemTotals[ itemLink ] or 0
				itemCount = itemCount + ( GetSlotStackSize( bagId, index ) or 0 )
				itemTotals[ itemLink ] = itemCount
			end
		end
	end

	return itemTotals
end

function EHT.Housing.GetListFurnitureCounts( list, useItemName )
	local itemTotals = { }

	for index, item in ipairs( list ) do
		local itemLink = item.Link
		if nil == item.CollectibleId and nil ~= itemLink and not EHT.Housing.IsEffectId( item.Id ) and not EHT.Housing.IsEffectItemLink( itemLink ) and not EHT.Housing.IsFurniturePathNodeId( item.Id ) then
			if useItemName then
				itemLink = EHT.Housing.GetFurnitureLinkName( itemLink )
			end
			itemTotals[ itemLink ] = ( itemTotals[ itemLink ] or 0 ) + 1
		end
	end

	return itemTotals
end

function EHT.Housing.InFrontOfPlayer( horizontalOffset, verticalOffset )
	if nil == horizontalOffset then horizontalOffset = 200 end
	if nil == verticalOffset then verticalOffset = 0 end

	local x, y, z, r = GetPlayerWorldPositionInHouse()
	local oX, oY, oZ = EHT.Housing.RotatePointOnAxisY( 0, verticalOffset, -1 * horizontalOffset, r )
	x, y, z = x + oX, y + oY, z + oZ

	return x, y, z, r
end

function EHT.Housing.DeltaToPlayer( origin )
	local x, y, z, r = GetPlayerWorldPositionInHouse()
	if nil ~= origin then x, y, z = x - origin.X, y - origin.MinY, z - origin.Z end
	return { X = x, Y = y, Z = z, Rotation = r }
end

do
	local function CalculateOrigin( items, minIndex, maxIndex )
		local minX, minY, minZ, maxX, maxY, maxZ, origin = math.huge, math.huge, math.huge, 0, 0, 0, { }
		if not items or 0 >= #items then return origin end
		if not minIndex then minIndex = 1 end
		if not maxIndex then maxIndex = #items end

		if "table" == type( items.Frames ) then
			for _, frame in ipairs( items.Frames ) do
				for _, state in pairs( frame.State ) do
					local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureWorldBounds( state.Id, state.Pitch, state.Yaw, state.Roll )

					if x1 and 0 ~= x1 then
						if x1 < minX then minX = x1 end
						if y1 < minY then minY = y1 end
						if z1 < minZ then minZ = z1 end
						if x2 > maxX then maxX = x2 end
						if y2 > maxY then maxY = y2 end
						if z2 > maxZ then maxZ = z2 end
					end
				end
			end
		else
			for index, item in ipairs( items ) do
				if index > maxIndex then break end

				if index >= minIndex then
					local x1, y1, z1, x2, y2, z2
					if "table" == type( item ) then
						x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureWorldBounds( item.Id, item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll )
						--x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBounds( item.Id )
					else
						local id = item
						x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureWorldBounds( id )
						--x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBounds( item )
					end
--[[
					if item.X and item.Y and item.Z then
						x1, y1, z1 = item.X + x1, item.Y + y1, item.Z + z1
						x2, y2, z2 = item.X + x2, item.Y + y2, item.Z + z2
					end
]]
					if x1 and 0 ~= x1 then
						if x1 < minX then minX = x1 end
						if y1 < minY then minY = y1 end
						if z1 < minZ then minZ = z1 end
						--if x2 < minX then minX = x2 end
						--if y2 < minY then minY = y2 end
						--if z2 < minZ then minZ = z2 end

						--if x1 > maxX then maxX = x1 end
						--if y1 > maxY then maxY = y1 end
						--if z1 > maxZ then maxZ = z1 end
						if x2 > maxX then maxX = x2 end
						if y2 > maxY then maxY = y2 end
						if z2 > maxZ then maxZ = z2 end
					end
				end
			end
		end

		origin.MinX, origin.MinY, origin.MinZ, origin.MaxX, origin.MaxY, origin.MaxZ = minX, minY, minZ, maxX, maxY, maxZ
		origin.LenX, origin.LenY, origin.LenZ = maxX - minX, maxY - minY, maxZ - minZ
		origin.X, origin.Y, origin.Z = ( minX + maxX ) / 2, ( minY + maxY ) / 2, ( minZ + maxZ ) / 2
		return origin
	end

	function EHT.Housing.CalculateFurnitureOrigin( items )
		return CalculateOrigin( items )
	end

	function EHT.Housing.CalculateFurnitureBoundsOrigin( items, minIndex, maxIndex )
		return CalculateOrigin( items, minIndex, maxIndex )
	end
end

function EHT.Housing.CalculateSceneOrigin( scene )
	local minX, minY, minZ, maxX, maxY, maxZ = 0, 0, 0, 0, 0, 0
	local x, y, z = 0, 0, 0
	local id = nil
	local origin = { }

	if nil == scene or 0 >= #scene.Frames then return origin end

	for frameIndex, frame in ipairs( scene.Frames ) do
		for stateIndex, state in pairs( frame.State ) do
			x, y, z = state.X, state.Y, state.Z

			if 0 ~= x and 0 ~= y and 0 ~= z then
				if 0 == minX or x < minX then minX = x end
				if 0 == minY or y < minY then minY = y end
				if 0 == minZ or z < minZ then minZ = z end
				if 0 == maxX or x > maxX then maxX = x end
				if 0 == maxY or y > maxY then maxY = y end
				if 0 == maxZ or z > maxZ then maxZ = z end
			end
		end
	end

	origin.MinX, origin.MinY, origin.MinZ = minX, minY, minZ
	origin.MaxX, origin.MaxY, origin.MaxZ = maxX, maxY, maxZ
	origin.LenX, origin.LenY, origin.LenZ = maxX - minX, maxY - minY, maxZ - minZ
	origin.X, origin.Y, origin.Z = ( minX + maxX ) / 2, ( minY + maxY ) / 2, ( minZ + maxZ ) / 2

	return origin
end

---[ Housing : Furniture State ]---

local DEFAULT_FURNITURE_STATES = { EHT.STATE.ON, EHT.STATE.OFF, EHT.STATE.ON2, EHT.STATE.ON3, EHT.STATE.ON4, EHT.STATE.ON5 }

EHT.FurnitureStates = { }
EHT.FurniturePendingStates = { }
EHT.FurnitureStateQueue = { }

function EHT.Housing.GetFurnitureNumStates( furnitureId )
	return GetPlacedHousingFurnitureNumObjectStates( EHT.Housing.FindFurnitureId( furnitureId ) ) or 0
end

function EHT.Housing.GetFurnitureStateByStateName( stateName, furnitureId )
	if nil == stateName then return nil end
	stateName = EHT.Util.Trim( string.lower( stateName ) )

	if "open" == stateName then
		return EHT.STATE.ON
	end

	if "closed" == stateName then
		return EHT.STATE.OFF
	end

	if	"on" == stateName or
		"lit" == stateName or
		"light" == stateName or
		"active" == stateName or
		"inact" == stateName or
		"raised" == stateName or
		"turned up" == stateName or
		"cheesiest" == stateName or
		"stacked" == stateName or
		"scrying" == stateName or
		"sealed" == stateName then
		return EHT.STATE.ON
	end

	if	"off" == stateName or
		"extinguish" == stateName or
		"extinguished" == stateName or
		"inactive" == stateName or
		"broken" == stateName or
		"lowered" == stateName or
		"turned down" == stateName or
		"cheesy" == stateName or
		"scattered" == stateName or
		"closed" == stateName or
		"close" == stateName then
		return EHT.STATE.OFF
	end

	if	"magically lit" == stateName or
		"blue light" == stateName or
		"calm" == stateName then
		return EHT.STATE.ON
	end

	if	"naturally lit" == stateName or
		"green light" == stateName or
		"regal" == stateName or
		"open" == stateName then
		return EHT.STATE.ON2
	end

	if	"red light" == stateName or
		"passionate" == stateName then
		return EHT.STATE.ON3
	end

	if	"pure" == stateName then
		return EHT.STATE.ON4
	end

	if	"radiant" == stateName then
		return EHT.STATE.ON5
	end

	-- Fallbacks

	if furnitureId then
		-- State name lookup
		local numStates = EHT.Housing.GetFurnitureNumStates( furnitureId )
		local matchingStateIndex

		for stateIndex = 1, numStates do
			local furnitureStateName = EHT.Util.Trim( string.lower( GetPlacedFurniturePreviewVariationDisplayName( furnitureId, stateIndex ) or "" ) )
			if stateName == furnitureStateName then
				matchingStateIndex = stateIndex
				break
			end
		end
		
		if matchingStateIndex then
			-- Return furniture state at the index of the matching state's index within the furniture's "array" of possible states
			return DEFAULT_FURNITURE_STATES[ matchingStateIndex ]
		end
	end
	
	-- Partial state name
	
	if string.find(stateName, " up") or string.find(stateName, " on") or string.find(stateName, " active") or string.find(stateName, " open") then
		return EHT.STATE.ON
	elseif string.find(stateName, " down") or string.find(stateName, " off") or string.find(stateName, " inactive") or string.find(stateName, " close") then
		return EHT.STATE.OFF
	end

	return nil
end

function EHT.Housing.DoesFurnitureHaveIndexableStateNames( furnitureId )
	local key = string.fromId64( furnitureId )
	if not key then
		return false
	end

	if EHT.FurnitureStates[key] then
		return true
	end

	local numStates = GetPlacedHousingFurnitureNumObjectStates( furnitureId )
	if 0 == numStates then
		return false
	end

	local stateNames = {}
	for stateIndex = 1, numStates do
		local stateName = string.lower( GetPlacedFurniturePreviewVariationDisplayName( furnitureId, stateIndex ) or "" )
		if stateNames[stateName] then
			return false
		end
		stateNames[stateName] = true
	end

	return true
end

function EHT.Housing.GetFurnitureStateIndex( furnitureId, state )
	if nil == state or state == EHT.STATE.TOGGLE then return nil end

	local numStates = EHT.Housing.GetFurnitureNumStates( furnitureId )
	if nil == numStates or 0 == numStates then return nil end

	local stateName, stateIndex
	if EHT.Housing.DoesFurnitureHaveIndexableStateNames( furnitureId ) then
		for variationIndex = 1, numStates do
			stateName = GetPlacedFurniturePreviewVariationDisplayName( furnitureId, variationIndex )
			if state == EHT.Housing.GetFurnitureStateByStateName( stateName, furnitureId ) then
				stateIndex = variationIndex - 1
				break
			end
		end
	end

	if not stateIndex then
		stateIndex = EHT.Util.GetIndexOfListValue( DEFAULT_FURNITURE_STATES, state )
		if stateIndex then
			stateIndex = stateIndex - 1
		end
	end

	return stateIndex
end

-- Furniture is assumed to be stateful.
function EHT.Housing.GetFurnitureStateByStateIndex( furnitureId, stateIndex )
	if not stateIndex then
		return nil
	end

	local stateName = GetPlacedFurniturePreviewVariationDisplayName( furnitureId, stateIndex )
	local state = EHT.Housing.GetFurnitureStateByStateName( stateName, furnitureId )
	return state or DEFAULT_FURNITURE_STATES[ stateIndex ]
end

function EHT.Housing.GetFurnitureState( furnitureId )
	local key = string.fromId64( furnitureId )
	if not key then
		return
	end

	local state = EHT.FurniturePendingStates[ key ]
	if state then
		return state
	end

	if EHT.Housing.IsEffectId( furnitureId ) then
		return nil
	end
	furnitureId = EHT.Housing.FindFurnitureId( furnitureId )

	if 0 == GetPlacedHousingFurnitureNumObjectStates( furnitureId ) then
		return nil
	end

	local stateIndex = GetPlacedHousingFurnitureCurrentObjectStateIndex( furnitureId )
	return EHT.Housing.GetFurnitureStateByStateIndex( furnitureId, stateIndex + 1 )
end

function EHT.Housing.SetFurnitureState( furnitureIds, state )
	local result = true
	if "table" == type( furnitureIds ) then
		for index, furnitureId in ipairs( furnitureIds ) do
			result = result and EHT.Housing.SetFurnitureStateInternal( furnitureId, state )
		end
	else
		result = EHT.Housing.SetFurnitureStateInternal( furnitureIds, state )
	end

	return result
end

function EHT.Housing.SetFurnitureStateInternal( furnitureId, state )
	local key = string.fromId64( furnitureId )
	if not key then
		return false
	end

	local queueState = EHT.FurniturePendingStates[ key ]
	if queueState then
		for queueIndex, queueEntry in ipairs( EHT.FurnitureStateQueue ) do
			if queueEntry.key == key then
				table.remove( EHT.FurnitureStateQueue, queueIndex )
				break
			end
		end
	end

	EHT.FurniturePendingStates[ key ] = state
	table.insert( EHT.FurnitureStateQueue, { key = key, state = state } )
	EVENT_MANAGER:RegisterForUpdate( "EHT.Housing.UpdateFurnitureStateQueue", 1, EHT.Housing.UpdateFurnitureStateQueue )
	return true
end

function EHT.Housing.UpdateFurnitureStateQueue()
	EVENT_MANAGER:UnregisterForUpdate("EHT.Housing.UpdateFurnitureStateQueue")

	local queueEntry = EHT.FurnitureStateQueue[1]
	if not queueEntry then
		return
	end

	local lastChangeTimestamp = EHT.FurnitureStateTimestamps[queueEntry.key]
	local currentTimestamp = GetFrameTimeMilliseconds()
	if lastChangeTimestamp and (currentTimestamp - lastChangeTimestamp) < EHT.CONST.HOUSING_STATE_REQUEST_DELAY_PER_ITEM then
		EVENT_MANAGER:RegisterForUpdate("EHT.Housing.UpdateFurnitureStateQueue", EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN, EHT.Housing.UpdateFurnitureStateQueue)
		return
	end

	table.remove(EHT.FurnitureStateQueue, 1)
	EHT.FurniturePendingStates[queueEntry.key] = nil

	local furnitureId = EHT.Housing.FindFurnitureId(queueEntry.key)
	if furnitureId then
		local numStates = EHT.Housing.GetFurnitureNumStates(furnitureId)
		if 0 < numStates then
			if queueEntry.state ~= EHT.Housing.GetFurnitureState(furnitureId) then
				local stateIndex = EHT.Housing.GetFurnitureStateIndex(furnitureId, queueEntry.state)
				EHT.FurnitureStateTimestamps[queueEntry.key] = currentTimestamp
				HousingEditorRequestChangeState(furnitureId, stateIndex)

				EVENT_MANAGER:RegisterForUpdate("EHT.Housing.UpdateFurnitureStateQueue", EHT.CONST.HOUSING_STATE_REQUEST_DELAY_MIN, EHT.Housing.UpdateFurnitureStateQueue)
				return
			end
		end
	end

	EVENT_MANAGER:RegisterForUpdate("EHT.Housing.UpdateFurnitureStateQueue", 1, EHT.Housing.UpdateFurnitureStateQueue)
end

function EHT.Housing.GetAllFurnitureStates( includeHouse, includeBags )
	if nil == includeHouse then includehouse = true end
	if nil == includeBags then includeBags = true end

	local states = EHT.SavedVars.FurnitureStates
	if nil == states then
		states = { }
		EHT.SavedVars.FurnitureStates = states
	end

	local function addState( state )
		if nil ~= state and "" ~= state and nil == states[ state ] then
			states[ state ] = variationIndex
		end
	end

	if includeHouse then
		local id
		repeat
			id = EHT.Housing.GetNextFurnitureId( id )
			if nil ~= id then
				for variationIndex = 0, 10 do
					local state = GetPlacedFurniturePreviewVariationDisplayName( id, variationIndex )
					if nil ~= state and "" ~= state and nil == states[ state ] then
						states[ state ] = variationIndex
					end
				end
			end
		until nil == id
	end

	if includeBags then
		for _, bagId in ipairs( EHT.CONST.BAG_IDS ) do
			local bagSize = GetBagSize( bagId ) - 1
			for slotIndex = 0, bagSize do
				for variationIndex = 0, 10 do
					local state = GetInventoryItemAsFurniturePreviewVariationDisplayName( bagId, slotIndex, variationIndex )
					if nil ~= state and "" ~= state and nil == states[ state ] then
						states[ state ] = variationIndex
					end
				end
			end
		end
	end

	if not includeBags and not includeHouse then
		local bagId = BAG_BACKPACK
		local bagSize = GetBagSize( bagId ) - 1
		for slotIndex = 0, bagSize do
			for variationIndex = 0, 10 do
				local state = GetInventoryItemAsFurniturePreviewVariationDisplayName( bagId, slotIndex, variationIndex )
				if nil ~= state and "" ~= state and nil == states[ state ] then
					states[ state ] = variationIndex
				end
			end
		end
	end

	local statesSorted = { }
	for state, index in pairs( states ) do
		table.insert( statesSorted, state )
	end
	table.sort( statesSorted )

	d( "_____________" )
	d( "Furniture States" )
	d( "------------------" )
	for index, state in pairs( statesSorted ) do
		df( "%d. %s", index, state )
	end

	return states
end
--[[
local function GetAllCraftingStationItemIds( itemId, items )

	if nil == itemId then itemId = 0 end
	if nil == items then items = { } end

	local itemIndex, itemLink, itemName = 0, nil, nil
	while itemIndex < 1000 do

		itemLink = "|H1:item:" .. tostring( itemId ) .. string.rep( ":0", 20 ) .. "|h|h"
		itemName = GetItemLinkName( itemLink )

		if nil ~= itemName then
			itemName = string.lower( itemName )
			if	nil ~= string.find( itemName, "alchemy station" ) or
				nil ~= string.find( itemName, "blacksmithing station" ) or
				nil ~= string.find( itemName, "clothing station" ) or
				nil ~= string.find( itemName, "dye station" ) or
				nil ~= string.find( itemName, "enchanting station" ) or
				nil ~= string.find( itemName, "jewelry crafting station" ) or
				nil ~= string.find( itemName, "outfit station" ) or
				nil ~= string.find( itemName, "provisioning station" ) or
				nil ~= string.find( itemName, "transmute station" ) or
				nil ~= string.find( itemName, "woodworking station" ) or
				nil ~= string.find( itemName, "hagraven altar, alchemical" ) or
				nil ~= string.find( itemName, "cauldron, provisioning" ) then
				items[ itemId ] = 1
			end
		end

		itemIndex = itemIndex + 1
		itemId = itemId + 1

	end

	if 200000 > itemId then
		zo_callLater( function() GetAllCraftingStationItemIds( itemId, items ) end, 100 )
		df( "Processing Item Id %d", itemId )
	else
		EHT.SavedVars.CraftingStationItemIds = items
		d( "Operation complete." )
	end

end
]]

--[[
-- /script EHT.Housing.GetAllLimitTypeItems()
-- /script d( EHT.SavedVars.LimitItemIds )
function EHT.Housing.GetAllLimitTypeItems( searchLimit, itemId, items )

	if nil == itemId then itemId = 0 end
	if nil == items then items = { } end
	if nil == searchLimit then searchLimit = HOUSING_FURNISHING_LIMIT_TYPE_HIGH_IMPACT_ITEM end

	local itemIndex, itemLink, itemName = 0, nil, nil
	while itemIndex < 1000 do

		itemLink = "|H1:item:" .. tostring( itemId ) .. string.rep( ":0", 20 ) .. "|h|h"
		local limitType, limitName = EHT.Housing.GetFurnitureLimitType( itemLink )

		if limitType == searchLimit then
			table.insert( items, { Limit = limitName, ItemId = itemId, Link = itemLink } )
		end

		itemIndex = itemIndex + 1
		itemId = itemId + 1

	end

	if 200000 > itemId then
		zo_callLater( function() EHT.Housing.GetAllLimitTypeItems( searchLimit, itemId, items ) end, 100 )
		df( "Processing Item Id %d", itemId )
	else
		EHT.SavedVars.LimitItemIds = items
		d( "Operation complete." )
	end

end
]]
--[[
-- /script EHT.Housing.GetOverlappingItemIds()
local cCount, iCount, oCount = 0, 0, 0
function EHT.Housing.GetOverlappingItemIds( itemId, items )

	if nil == itemId then itemId, cCount, iCount, oCount = 0, 0, 0, 0 end
	if nil == items then items = { } end

	local itemIndex, itemLink, itemName = 0, nil, nil
	while itemIndex < 1000 do

		local cLink = GetCollectibleLink( itemId, LINK_STYLE_BRACKETS )
		local iLink = string.format( "|H1:item:%s%s|h|h", tostring( itemId ), string.rep( ":0", 20 ) )
		local cIsFurniture, iIsFurniture = false, false

		if 0 ~= GetCollectibleFurnitureDataId( itemId ) then cIsFurniture = true end
		if 0 ~= GetItemLinkFurnitureDataId( iLink ) then iIsFurniture = true end

		if cIsFurniture and iIsFurniture then -- and nil ~= GetCollectibleIdFromLink( cLink ) and "" ~= GetItemLinkName( iLink ) then
			table.insert( items, { ItemLink = iLink, CollectibleLink = cLink } )
			oCount = oCount + 1
		end

		if cIsFurniture then cCount = cCount + 1 end
		if iIsFurniture then iCount = iCount + 1 end

		itemIndex = itemIndex + 1
		itemId = itemId + 1

	end

	if 200000 > itemId then
		zo_callLater( function() EHT.Housing.GetOverlappingItemIds( itemId, items ) end, 100 )
		df( "Processing Item Id %d", itemId )
	else
		EHT.SavedVars.OverlappingItemIds = items
		df( "Operation complete." )
		df( "Furniture Collectible Ids: %d", cCount )
		df( "Furniture Item Ids: %d", iCount )
		df( "Overlapping Ids: %d", oCount )
	end

end
]]
---[ Housing : Furniture Hierarchy ]---

function EHT.Housing.FindLinked( furnitureId )
	if nil == furnitureId then return { } end

	local matches = EHT.Housing.GetLinked( furnitureId )
	if nil == matches then matches = { string.fromId64( furnitureId ) } end

	return matches
end

function EHT.Housing.FindLinkedChildren( furnitureId )
	if nil == furnitureId then return { } end

	local matches = EHT.Housing.GetDescendants( furnitureId )
	if nil == matches then matches = { string.fromId64( furnitureId ) } end

	return matches
end

function EHT.Housing.LinkGroup( onChange, onComplete, group )
	if not HousingEditorRequestSetFurnitureParent then
		if onComplete then onComplete() end
		return
	end

	if "table" ~= type( group ) then group = nil end
	local id, headId, logicalIndex, parentId = nil, nil, 0, nil

	EHT.Housing.ForEachGroupFurnishing(
		function(index, item)
			id = EHT.Housing.FindFurnitureId( item.Id )
			if nil ~= id then
				local delay = EHT.CONST.HOUSING_LINK_DELAY
				logicalIndex = logicalIndex + 1

				if 1 == logicalIndex % ( HOUSING_MAX_FURNITURE_CHILDREN - 1 ) then
					if nil ~= parentId then
						-- Link this parent to the previous parent in the linked list.
						HousingEditorRequestSetFurnitureParent(id, parentId)
						delay = delay + EHT.CONST.HOUSING_LINK_DELAY
					else
						-- This parent is the head of the linked list.
						headId = id
					end

					parentId = id
				else
					-- Link this child to the current linked list parent.
					HousingEditorRequestSetFurnitureParent(id, parentId)
				end

				if onChange then
					if not onChange(index, item) then
						return "cancel"
					end
				end

				return delay
			end

			if onChange then
				if not onChange(index, item) then
					return "cancel"
				end
			end
		end,
		onComplete,
		group )
end

function EHT.Housing.UnlinkGroup( onChange, onComplete, group )
	if not GetPlacedFurnitureParent or not HousingEditorRequestClearFurnitureParent then
		if onComplete then onComplete() end
		return
	end

	if "table" ~= type( group ) then group = nil end
	local id = nil

	EHT.Housing.ForEachGroupFurnishing(
		function( index, item )
			id = EHT.Housing.FindFurnitureId( item.Id )

			if nil ~= id then
				if nil ~= GetPlacedFurnitureParent( id ) then
					HousingEditorRequestClearFurnitureParent( id )

					if onChange then
						if not onChange(index, item) then
							return "cancel"
						end
					end

					return EHT.CONST.HOUSING_UNLINK_DELAY
				end
			end

			if onChange then
				if not onChange(index, item) then
					return "cancel"
				end
			end
		end,
		onComplete,
		group,
		nil,
		-1 )
end

function EHT.Housing.GetAncestorMap( set )
	if "table" ~= type( set ) then return end
	local map = { }

	for index, item in pairs( set ) do
		local childId = type( item.Id ) == "number" and item.Id or StringToId64( item.Id )
		local childIdString = string.fromId64( childId )
		local parentId = GetPlacedFurnitureParent( childId )

		while parentId do
			local parentIdString = string.fromId64( parentId )
			map[childIdString] = parentIdString
			childId, childIdString = parentId, parentIdString
			parentId = GetPlacedFurnitureParent( childId )
		end
	end

	return map
end

function EHT.Housing.GetDescendants( parentId, children, excludeIndirectDescendants )
	parentId = EHT.Housing.FindFurnitureId( parentId )
	children = children or { }
	index = index or 1

	local childIds = { GetPlacedFurnitureChildren( parentId ) }
	for _, childId in ipairs( childIds ) do
		table.insert( children, string.fromId64( childId ) )
		if true ~= excludeIndirectDescendants then
			EHT.Housing.GetDescendants( childId, children )
		end
	end

	return children
end

function EHT.Housing.GetAllDescendantsByParent()
	local map = { }
	local id = EHT.Housing.GetNextFurnitureId()

	while id do
		local children = EHT.Housing.GetDescendants( id, nil, true )

		if children and 0 < #children then
			local list = { }
			map[ string.fromId64( id ) ] = list

			for _, childId in ipairs( children ) do
				list[string.fromId64( childId )] = true
			end
		end

		id = EHT.Housing.GetNextFurnitureId( id )
	end

	return map
end

function EHT.Housing.GetAncestors( id )
	local list = { }

	id = EHT.Housing.FindFurnitureId( id )
	if not id then return list end

	local parentId = GetPlacedFurnitureParent( id )
	while parentId do
		table.insert( list, string.fromId64( parentId ) )
		parentId = GetPlacedFurnitureParent( parentId )
	end

	return list
end

function EHT.Housing.GetLinked( id )
	local list, queue = { }, { }

	if not GetPlacedFurnitureParent then return list end
	if nil == id then return list end

	id = string.fromId64( id )
	table.insert( queue, id )

	while 0 < #queue do
		local relativeId = table.remove( queue, 1 )
		list[ relativeId ] = true

		local relatives = EHT.Housing.GetDescendants( relativeId )
		if relatives then
			for _, childId in ipairs( relatives ) do
				local descendantId = string.fromId64( childId )

				if not list[ descendantId ] then
					table.insert( queue, descendantId )
					list[ descendantId ] = true
				end
			end
		end

		local relatives = EHT.Housing.GetAncestors( relativeId )
		if relatives then
			for _, parentId in ipairs( relatives ) do
				local ancestorId = string.fromId64( parentId )

				if not list[ ancestorId ] then
					table.insert( queue, ancestorId )
					list[ ancestorId ] = true
				end
			end
		end
	end

	local list2 = list
	list = { }

	for id in pairs( list2 ) do
		table.insert( list, id )
	end

	return list
end

function EHT.Housing.GetListOfNonDependentFurniture( set )
	if "table" ~= type( set ) then return set end
	local index = #set
	local idMap = { }
	local list = { }

	for index, item in ipairs( set ) do
		idMap[ item.Id ] = true
	end

	for index, item in ipairs( set ) do
		local insertItem = true
		local id = item.Id
		if "string" == type( id ) then id = StringToId64( id ) end
		local parentId = GetPlacedFurnitureParent( id )

		while parentId do
			if idMap[ string.fromId64( parentId ) ] then
				insertItem = false
				break
			end
			parentId = GetPlacedFurnitureParent( parentId )
		end

		if insertItem then
			table.insert( list, item )
		end
	end

	return list
end

function EHT.Housing.RemoveDependents( set )
	if not GetPlacedFurnitureParent then return set end
	if "table" ~= type( set ) then return set end
	local index = #set

	while 0 < index do
		local children = EHT.Housing.GetDescendants( set[index].Id )

		for _, childId in ipairs( children ) do
			local sId = string.fromId64( childId )

			for childIndex = #set, 1, -1 do
				if sId == set[childIndex].Id then
					table.remove( set, childIndex )
				end
			end
		end

		index = index - 1
		if index > #set then
			index = #set
		end
	end
end

function EHT.Housing.RemoveAllDependents( set )
	if "table" ~= type( set ) then return set end
	local unrelated = EHT.Util.CloneTable( set )
	if 0 == #unrelated then return unrelated end

	local ids = { }
	for index, item in ipairs( unrelated ) do
		local id = string.fromId64( item.Id )
		if id then
			ids[ id ] = true
		end
	end

	for index, item in ipairs( unrelated ) do
		local id64 = item.Id
		if "number" ~= type( id64 ) then
			id64 = StringToId64( id64 )
		end
		if id64 then
			local children = EHT.Housing.GetDescendants( id64 )
			for childIndex, childItemId in ipairs( children ) do
				ids[ childItemId ] = nil
			end
		end
	end

	local numItems = #unrelated
	for index = numItems, 1, -1 do
		local id = string.fromId64( unrelated[ index ].Id )
		if not id or not ids[ id ] then
			table.remove( unrelated, index )
		end
	end

	return unrelated
end
--[[
function EHT.Housing.SortDependents( set )
	if "table" ~= type( set ) then return set end
	local sorted = EHT.Util.CloneTable( set )
	if 0 >= #sorted then return sorted end

	local function IsChildOf( id, parentId )
		local children = { GetPlacedFurnitureChildren( parentId ) }
		if 0 ~= #children then
			for _, childId in ipairs( children ) do
				if childId == id then
					return true
				end
			end
			for _, childId in ipairs( children ) do
				if IsChildOf( id, childId ) then
					return true
				end
			end
		end
		return false
	end

	local function CompareItems( left, right )
		local leftId = type( left.Id ) == "number" and left.Id or StringToId64( left.Id )
		local rightId = type( right.Id ) == "number" and right.Id or StringToId64( right.Id )
		local leftIsParent = IsChildOf( rightId, leftId )
		local rightIsParent = not leftIsParent and IsChildOf( leftId, rightId )
		local swap = leftIsParent or ( leftId < rightId and not rightIsParent )
--if leftIsParent or rightIsParent then df( "%s (%s) < %s (%s) = %s", string.fromId64( leftId ), leftIsParent and "P" or "C", string.fromId64( rightId ), rightIsParent and "P" or "C", swap and "true" or "false" ) end
		return swap
	end

	for index, item in ipairs( sorted ) do
		item._id = type( item.Id ) == "number" and item.Id or StringToId64( item.Id )
	end

	table.sort( sorted, CompareItems )

	for index, item in ipairs( sorted ) do
		item._id = nil
	end

	return sorted
end
]]
function EHT.Housing.SortDependents( set, getParentFunction )
	if "table" ~= type( set ) then
		return set
	end

	local sorted = EHT.Util.CloneTable( set )
	if 0 >= #sorted then
		return sorted
	end

	getParentFunction = getParentFunction or GetPlacedFurnitureParent
	local allParentIds = { }
	for index, item in ipairs( sorted ) do
		local id = StringToId64( item.Id )
		local parentIds
		local parentId = getParentFunction( id )
		while parentId do
			parentIds = parentIds or { }
			table.insert( parentIds, Id64ToString( parentId ) )
			parentId = getParentFunction( parentId )
		end

		if parentIds then
			allParentIds[ item.Id ] = parentIds
		end
	end

	if not next( allParentIds ) then
		-- The list has no dependent child items.
		return sorted, 0
	end

	local setIds = { }
	for index, item in ipairs( sorted ) do
		local sid = string.fromId64( item.Id )
		setIds[ sid ] = true
	end

	local function getItemIndex( sid )
		if not setIds[ sid ] then
			return nil
		end

		for index, item in ipairs( sorted ) do
			if item.Id == sid then
				return index
			end
		end
	end

	local size = #sorted
	local numIterations = size
	for iteration = 1, size do
		local sortChanged = false

		for index = 1, size do
			local item = sorted[ index ]
			local id = StringToId64( item.Id )
			local parentIds = allParentIds[ item.Id ]

			if parentIds then
				for parentIndex, parentSid in ipairs( parentIds ) do
					local sortedParentIndex = getItemIndex( parentSid )
					if sortedParentIndex then
						if sortedParentIndex > index then
							-- Remove this item from the sorted list.
							table.remove( sorted, index )
							-- Insert this item into the sorted list at the parent's previous index.
							table.insert( sorted, sortedParentIndex, item )

							sortChanged = true
						end

						-- Now that this item follows the most recent parent in the sorted list, we can skip any remaining grandparents.
						break
					end
				end
			end
		end

		if not sortChanged then
			-- List is completely sorted.
			numIterations = iteration
			break
		end
	end

	return sorted, numIterations
end
-- /script EHT.TestSortDependents()
function EHT.TestSortDependents()
	local items =
	{
		{
			Id = "1",
		},
		{
			Id = "2",
		},
		{
			Id = "3",
		},
		{
			Id = "4",
		},
		{
			Id = "5",
		},
		{
			Id = "6",
		},
		{
			Id = "7",
		},
	}

	local parents =
	{
		["1"] = "5",
		["2"] = "1",
		["3"] = "7",
		["4"] = "7",
		["5"] = "3",
		["6"] = "7",
	}

	local function getParentFunction( id )
		local sid = Id64ToString( id )
		local parentId = StringToId64( parents[ sid ] )
		if 0 ~= parentId then
			return parentId
		end
		return nil
	end
	
	for childId, parentId in pairs( parents ) do
		if Id64ToString( getParentFunction( StringToId64( childId ) ) ) ~= parentId then
			df( "getParentFunction failed to map %s to %s", childId, parentId )
			return
		end
	end

	d("original...")
	d(items)
	d("------")

	d("sorted with no parents...")
	local sorted, numIterations = EHT.Housing.SortDependents( items, function() end )
	d(sorted)
	df("iterations: %d", numIterations)
	
	d("------")
	d("parents...")
	d(parents)
	d("------")

	local sorted, numIterations = EHT.Housing.SortDependents( items, getParentFunction )
	d("sorted...")
	d(sorted)
	df("iterations: %d", numIterations)
	d("------")

	return sorted, numIterations
end

---[ Operations : Coordinates ]---

function EHT.Housing.GetUnitPositions()
	local position, unitTag, mapX, mapY, mapZ, heading, sameMap
	local x, y, z = GetPlayerWorldPositionInHouse()

	position = unitPositions[0]
	position[1], position[2], position[3] = x, y, z

	local groupSize = GetGroupSize() or 0
	if 2 > groupSize then
		for index = 1, GROUP_SIZE_MAX do unitPositions[index][1], unitPositions[index][2], unitPositions[index][3] = 0, 0, 0 end
		return unitPositions
	end

	local zone = GetUnitZoneIndex( "player" )

	for index = 1, GROUP_SIZE_MAX do
		unitTag = "group" .. tostring( index )
		position = unitPositions[ index ]

		if not IsUnitGrouped( unitTag ) or not IsUnitOnline( unitTag ) or GetUnitZoneIndex( unitTag ) ~= zone then
			position[1], position[2], position[3] = 0, 0, 0
		else
			_, mapX, mapY, mapZ = EHT.GetPlayerPosition( unitTag )
			position[1], position[2], position[3] = mapX, mapY, mapZ
		end
	end

	return unitPositions
end

function EHT.Housing.IsCollectibleId( id )
	local collectibleId = GetCollectibleIdFromFurnitureId( id )
	return nil ~= collectibleId, collectibleId
end

------[ Effects ]------

function EHT.Housing.GetEffectTypeById( id )
	local record = EHT.Data.GetEffectRecordById( id )
	if not record then return nil end

	local effectType = EHT.EffectType:GetByIndex( record.EffectType )
	return effectType
end

function EHT.Housing.GetItemIdEffectType( itemId )
	itemId = tonumber( itemId )
	if not itemId then return nil end
	local id = tonumber( itemId ) - EHT.BASE_EFFECT_ITEM_TYPE_ID
	return EHT.EffectType:GetByIndex( id )
end

function EHT.Housing.IsEffectItemId( itemId )
	return nil ~= EHT.Housing.GetItemIdEffectType( itemId )
end

function EHT.Housing.IsEffectItemLink( link )
	local effectId, effectTypeId = EHT.Housing.GetEffectLinkInfo( link )
	return nil ~= effectTypeId
end

function EHT.Housing.IsEffectId( id )
	return id == id and ( ( "number" == type( id ) and 8 >= #tostring( id ) ) or ( "string" == type( id ) and 8 >= #id and "-" ~= string.sub( tostring( id ), 1, 1 ) ) )
end

function EHT.Housing.IsEffectGroupId( id )
	if EHT.Housing.IsEffectId( id ) then
		id = tonumber( id )
		if id and id >= EHT.CONST.EFFECT_GROUP_ID_MIN and id <= EHT.CONST.EFFECT_GROUP_ID_MAX then
			return true, id
		end
	end
	return false, nil
end

function EHT.Housing.GetEffectGroupBit( id )
	local id = tonumber( id )
	if id and id >= EHT.CONST.EFFECT_GROUP_ID_MIN and id <= EHT.CONST.EFFECT_GROUP_ID_MAX then
		local ordinal = 1 + ( id - EHT.CONST.EFFECT_GROUP_ID_MIN )
		return EHT.Bit.New( ordinal )
	end
	return nil
end

function EHT.Housing.GetEffectGroupId( bit )
	bit = tonumber( bit )
	if not bit then return nil end
	local index = EHT.Bit.FirstBit( bit )
	if index then return ( -1 + EHT.CONST.EFFECT_GROUP_ID_MIN ) + index end
	return nil
end

---[ Path Nodes ]---

function EHT.Housing.IsFurniturePathNodeId( id )
	if "string" == type( id ) then
		local separatorIndex = string.find( id, "%." )
		return nil ~= separatorIndex, separatorIndex
	end

	return false, nil
end

function EHT.Housing.GetFurniturePathNodeId( id, pathIndex )
	if not id or not pathIndex or pathIndex == EHT.INVALID_PATH_NODE then
		return id
	end

	local idString
	if "string" == type( id ) then
		if string.find( id, "%." ) then
			return id
		end
		idString = id
	else
		idString = string.fromId64( id )
	end

	return string.format( "%s.%d", idString, pathIndex )
end

function EHT.Housing.GetFurniturePathInfo( id )
	id = EHT.Housing.GetFurnitureIdInfo( id )

	if 0 == EHT.Housing.GetNumFurniturePathNodes( id ) then
		return nil
	end

	local info =
	{
		Id = string.fromId64( id ),
		State = HousingEditorGetFurniturePathState( id ),
		FollowType = HousingEditorGetFurniturePathFollowType( id ),
	}
	return info
end

function EHT.Housing.SetFurniturePathInfo( id, info )
	if not info then
		return false
	end

	id = EHT.Housing.GetFurnitureIdInfo( id )

	local current = EHT.Housing.GetFurniturePathInfo( id )
	if current then
		local changed = false
		for key, value in pairs( current ) do
			if info[key] ~= value then
				changed = true
				break
			end
		end

		if not changed then
			return nil
		end
	end

	local result = HousingEditorRequestChangeFurniturePathData( id, info.State, info.FollowType )
	return true
end

function EHT.Housing.GetNumFurniturePathNodes( id )
	return HousingEditorGetNumPathNodesForFurniture( id )
end

function EHT.Housing.GetFurniturePathNodeInfo( id, pathIndex )
	if not pathIndex then
		id, pathIndex = EHT.Housing.GetFurnitureIdInfo( id )
	end

	if not id or not pathIndex then
		return 0, 0, 0, 0, 0, 0
	end

	local x, y, z = HousingEditorGetPathNodeWorldPosition( id, pathIndex )
	local _, yaw = HousingEditorGetPathNodeOrientation( id, pathIndex )
	local speed = HousingEditorPathNodeSpeed( id, pathIndex )
	local delayTime = HousingEditorPathNodeDelayTime( id, pathIndex )
	if not delayTime or 0 == delayTime then
		delayTime = 0
	else
		delayTime = HousingEditorGetPathNodeValueFromDelayTime( delayTime )
		if delayTime > HOUSING_PATH_DELAY_TIME_EXTREMELY_LONG then
			delayTime = HOUSING_PATH_DELAY_TIME_EXTREMELY_LONG
		end
	end

	return x, y, z, yaw, speed, delayTime
end

function EHT.Housing.SetFurniturePathNodeInfo( id, pathIndex, x, y, z, yaw, speed, delayTime, delayTimeMS )
if EHT.DebugPathNodes then df("SetFurniturePathNodeInfo(%s, %d, %d, %d, %d)", string.fromId64( id ), pathIndex, x, y, z) end
	id = EHT.Housing.FindFurnitureId( id )
	if not id then
		return HOUSING_REQUEST_RESULT_NO_SUCH_FURNITURE
	end

	local result
	local cx, cy, cz, cyaw, cspeed, cdelayTime = EHT.Housing.GetFurniturePathNodeInfo( id, pathIndex )
	if cx and 0 ~= cx then
		x, y, z, yaw, speed, delayTime = x or cx, y or cy, z or cz, yaw or cyaw, speed or cspeed, delayTime or cdelayTime
		if not delayTimeMS then
			delayTimeMS = HousingEditorGetPathNodeDelayTimeFromValue( delayTime )
		end

		EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.MOVE_PATH_NODE_OP )
		result = HousingEditorRequestModifyPathNode( id, pathIndex, x, y, z, yaw, speed, delayTimeMS )
		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.MOVE_PATH_NODE_OP )
		end
	else
		result = HOUSING_REQUEST_RESULT_MOVE_FAILED
	end
if EHT.DebugPathNodes then df(" Result %d", result) end
	return result
end

function EHT.Housing.PlacePathNode( callback, furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
if EHT.DebugPathNodes then df("PlacePathNode(%s, %d, %d, %d, %d)", string.fromId64( furnitureId ), pathIndex, x, y, z) end
	local id = EHT.Housing.FindFurnitureId( furnitureId )
	if not id then
		if callback then callback( furnitureId, pathIndex ) end
		return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
	end

	delayTime = HousingEditorGetPathNodeDelayTimeFromValue( delayTime )

	local function Request()
		if EHT.Biz.HasPendingFurnitureOperations() then
			return
		end

		local numPathNodes = EHT.Housing.GetNumFurniturePathNodes( id )
if EHT.DebugPathNodes then df(" Nodes %d", numPathNodes) end
		if numPathNodes < pathIndex then
			EHT.Biz.IncrementPendingFurnitureOperations( EHT.CONST.PLACE_PATH_NODE_OP )

			local insertPathIndex = numPathNodes + 1
			local result = HousingEditorRequestInsertPathNode( id, insertPathIndex, x, y, z, yaw, speed or HOUSING_PATH_MOVEMENT_SPEED_WALK, delayTime or 0 )
			if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
				EHT.Biz.DecrementPendingFurnitureOperations( EHT.CONST.PLACE_PATH_NODE_OP )
			end
if EHT.DebugPathNodes then df(" Result %d", result) end
			return
		end
if EHT.DebugPathNodes then df(" Complete") end
		return true
	end

	local options =
	{
		callback = callback,
		id = string.fromId64( id ) or "nil",
		pathIndex = pathIndex,
	}
	EHT.Biz.SubmitRequest( Request, options )

	return HOUSING_REQUEST_RESULT_SUCCESS
end

function EHT.Housing.PlaceFurnitureAndPathNode( callback, furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
	local currentX = EHT.Housing.GetFurniturePathNodeInfo( furnitureId, pathIndex )
	if currentX and 0 ~= currentX then
		local result = EHT.Housing.SetFurniturePathNodeInfo( furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
		zo_callLater( function()
			if callback then callback( furnitureId, pathIndex ) end
		end, 100 )

		return result
	else
		local collectibleFurnitureId = furnitureId
		if "number" ~= type( collectibleFurnitureId ) then
			collectibleFurnitureId = StringToId64( collectibleFurnitureId )
		end

		local collectibleId = GetCollectibleIdFromFurnitureId( collectibleFurnitureId )
		if not collectibleId then
			if callback then callback( furnitureId, pathIndex ) end
			return HOUSING_REQUEST_RESULT_ITEM_REMOVE_FAILED
		end

		local function Request()
			if EHT.Biz.HasPendingFurnitureOperations() then
				return
			end

			local id = EHT.Housing.FindFurnitureId( furnitureId )
			if id then
if EHT.DebugPathNodes then d(" Calling PlacePathNode") end
				EHT.Housing.PlacePathNode( callback, furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
				return true
			end

			local result = EHT.Housing.PlaceCollectible( collectibleId, x, y, z, 0, yaw, 0 )
if EHT.DebugPathNodes then df(" PlaceCollectible Return %d", result) end
			if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
				if callback then callback( false ) end
				return false
			end

			return
		end

		local options =
		{
			callback = nil, -- Deliberate. PlacePathNode should handle this.
			collectibleId = collectibleId,
			pathIndex = pathIndex,
		}
		EHT.Biz.SubmitRequest( Request, options )

		return HOUSING_REQUEST_RESULT_SUCCESS
	end
end

function EHT.Housing.SetOrPlaceFurnitureAndPathNode( callback, furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
	local currentX = EHT.Housing.GetFurniturePathNodeInfo( furnitureId, pathIndex )
	if currentX and 0 ~= currentX then
		local requested = false

		local function Request()
			if not requested then
				local result = EHT.Housing.SetFurniturePathNodeInfo( furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
				if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
					return
				end

				requested = true
				return
			end

			if EHT.Biz.HasPendingFurnitureOperations() then
				return
			end

			return true
		end

		local id = EHT.Housing.GetFurniturePathNodeId( furnitureId, pathIndex )
		local options =
		{
			callback = callback,
			id = id,
			pathIndex = pathIndex,
		}
		EHT.Biz.SubmitRequest( Request, options )

		return HOUSING_REQUEST_RESULT_SUCCESS
	else
		return EHT.Housing.PlaceFurnitureAndPathNode( callback, furnitureId, pathIndex, x, y, z, yaw, speed, delayTime )
	end
end

---[ Jumping ]---

function EHT.Housing.JumpToHouse( houseId, owner, suppressNotification )
	owner = ( "" ~= owner and string.lower( GetDisplayName() ) ~= string.lower( owner ) ) and owner or nil
	houseId = 0 ~= houseId and houseId or nil
	local pronoun = owner and string.format( "%s's", owner ) or "your"
	local isOwner = not owner

	StopAllMovement()

	if isOwner then
		if not houseId then
			houseId = GetHousingPrimaryHouse()
		end

		RequestJumpToHouse( houseId )
	else
		if houseId then
			JumpToSpecificHouse( owner, houseId )
		else
			JumpToHouse( owner )
		end
	end

	local house = EHT.Housing.GetHouseById( houseId )
	local houseName = "home"

	if house and house.Name then
		houseName = owner and house.Name or house.Nickname
	end

	if not suppressNotification then
		EHT.UI.DisplayNotification( string.format( "Jumping to %s %s", pronoun, houseName ) )
	end

	return pronoun, houseName
end

---[ Furniture Dimensions ]---

local function MatchPolarity( n, np )
	if ( 0 < np and 0 > n ) or ( 0 > np and 0 < n ) then
		return -n
	end

	return n
end

local function InvertPolarity( n, np )
	if ( 0 < np and 0 < n ) or ( 0 > np and 0 > n ) then
		return -n
	end

	return n
end

local function SnapPositionDistanceComparer( a, b )
	return a[4] < b[4]
end

local function SnapPositionOrdinalComparer( a, b )
	return math.polarity( a[1] ) < math.polarity( b[1] ) and math.polarity( a[2] ) < math.polarity( b[2] ) and math.polarity( a[3] ) < math.polarity( b[3] )
end

function EHT.Housing.GetFurnitureWorldBounds( id, x, y, z, pitch, yaw, roll )
	if not x then
		x, y, z = EHT.Housing.GetFurniturePosition( id )
	end

	if EHT.Housing.IsFurniturePathNodeId( id ) then
		local dx, dy, dz = unpack( PATH_NODE_DIMENSIONS )
		local lx, ly, lz = 0.5 * dx, 0.5 * dy, 0.5 * dz
		return x - lx, y - ly, z - lz, x + lx, y + ly, z + lz
	else
		id = EHT.Housing.FindFurnitureId( id )
		local effect = EHT.Housing.GetEffectById( id )

		if effect then
			return effect:GetBounds()
		else
			local x1, y1, z1, x2, y2, z2 = HousingEditorGetFurnitureWorldBounds( id )
			if 0 == x1 and 0 == y1 and 0 == z1 then
				x, y, z = x or 0, y or 0, z or 0
				return x, y, z, x, y, z
			end
			return x1, y1, z1, x2, y2, z2
		end
	end
end

function EHT.Housing.GetFurnitureLocalBounds( id )
	if EHT.Housing.IsFurniturePathNodeId( id ) then
		local dx, dy, dz = unpack( PATH_NODE_DIMENSIONS )
		local lx, ly, lz = 0.5 * dx, 0.5 * dy, 0.5 * dz
		local ox, oy, oz = unpack( PATH_NODE_OFFSETS )
		return -lx + ox, -ly + oy, -lz + oz, lx + ox, ly + oy, lz + oz
	end

	id = EHT.Housing.FindFurnitureId( id )

	if EHT.Housing.IsEffectId( id ) then
		local effect = EHT.Data.GetEffectByRecordId( id )
		if not effect then return 0, 0, 0, 0, 0, 0 end

		local x, y, z = effect:GetPosition()
		local sizeX, sizeY, sizeZ = effect:GetSize()

		sizeX, sizeY, sizeZ = 0.5 * ( sizeX or 0 ), 0.5 * ( sizeY or 0 ), 0.5 * ( sizeZ or 0 )
		return -sizeX, -sizeY, -sizeZ, sizeX, sizeY, sizeZ
	end

	local minX, minY, minZ, maxX, maxY, maxZ = HousingEditorGetFurnitureLocalBounds( id )
	minX, minY, minZ, maxX, maxY, maxZ = 100 * minX, 100 * minY, 100 * minZ, 100 * maxX, 100 * maxY, 100 * maxZ

	local itemId = EHT.Housing.GetFurnitureItemId( id )
	if itemId and not EHT.ItemIdLocalBoundsCache[itemId] then
		EHT.ItemIdLocalBoundsCache[itemId] = { minX, minY, minZ, maxX, maxY, maxZ }
	end

	return minX, minY, minZ, maxX, maxY, maxZ
end

function EHT.Housing.GetFurnitureDimensions( id )
	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBounds( id )

	if x1 then
		return x2 - x1, y2 - y1, z2 - z1
	end

	return 0, 0, 0
end

function EHT.Housing.GetFurnitureLocalBoundsByItemId( itemId )
	itemId = tonumber( itemId )
	local bounds = EHT.ItemIdLocalBoundsCache[itemId]
	if bounds then
		return unpack( bounds )
	end

	local id = EHT.Housing.GetFirstFurnitureByItemId( itemId )
	if not id then
if EHT.IsDev then df( "*** GetFurnitureLocalBoundsByItemId:\n*** NO ITEM ID FOUND: %s", tostring( itemId ) ) end
		return 0, 0, 0, 0, 0, 0
	end

	local minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureLocalBounds( id )
	return minX, minY, minZ, maxX, maxY, maxZ
end

function EHT.Housing.GetFurnitureLocalOffset( id )
	if EHT.Housing.IsFurniturePathNodeId( id ) then
		local ox, oy, oz = unpack( PATH_NODE_OFFSETS )
		return ox, oy, oz
	end

	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBounds( id )
	return 0.5 * ( x2 + x1 ), 0.5 * ( y2 + y1 ), 0.5 * ( z2 + z1 )
end

function EHT.Housing.GetFurnitureLocalOffsetByItemId( itemId )
	itemId = tonumber( itemId )
	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBoundsByItemId( itemId )
	return 0.5 * ( x2 + x1 ), 0.5 * ( y2 + y1 ), 0.5 * ( z2 + z1 )
end

function EHT.Housing.GetFurnitureLocalDimensions( id )
	if EHT.Housing.IsFurniturePathNodeId( id ) then
		local dx, dy, dz = unpack( PATH_NODE_DIMENSIONS )
		local ox, oy, oz = unpack( PATH_NODE_OFFSETS )
		return dx, dy, dz, ox, oy, oz
	end

	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBounds( id )
	local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
	local ox, oy, oz = EHT.Housing.GetFurnitureLocalOffset( id )
	return dx, dy, dz, ox, oy, oz
end

function EHT.Housing.GetFurnitureLocalDimensionsByItemId( itemId )
	itemId = tonumber( itemId )
	local x1, y1, z1, x2, y2, z2 = EHT.Housing.GetFurnitureLocalBoundsByItemId( itemId )
	local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
	local ox, oy, oz = EHT.Housing.GetFurnitureLocalOffsetByItemId( itemId )
	return dx, dy, dz, ox, oy, oz
end

function EHT.Housing.GetFurnitureWorldOffset( id, pitch, yaw, roll )
	if not pitch or not yaw or not roll then
		local cpitch, cyaw, croll = EHT.Housing.GetFurnitureOrientation( id )
		pitch, yaw, roll = pitch or cpitch, yaw or cyaw, roll or croll
	end
	local ox, oy, oz = EHT.Housing.GetFurnitureLocalOffset( id )
	return EHT.Housing.RotateAroundOrigin( ox, oy, oz, pitch or 0, yaw or 0, roll or 0 )
end

function EHT.Housing.GetFurnitureWorldOffsetByItemId( itemId, pitch, yaw, roll )
	itemId = tonumber( itemId )
	if not pitch or not yaw or not roll then
		local cpitch, cyaw, croll = EHT.Housing.GetFurnitureOrientation( id )
		pitch, yaw, roll = pitch or cpitch, yaw or cyaw, roll or croll
	end
	local ox, oy, oz = EHT.Housing.GetFurnitureLocalOffsetByItemId( itemId )
	return EHT.Housing.RotateAroundOrigin( ox, oy, oz, pitch or 0, yaw or 0, roll or 0 )
end

function EHT.Housing.GetFurnitureWorldBoundsAndOffset( id, x, y, z, pitch, yaw, roll )
	local minX, minY, minZ, maxX, maxY, maxZ = EHT.Housing.GetFurnitureWorldBounds( id, pitch, yaw, roll )
	local oX, oY, oZ = EHT.Housing.GetFurnitureLocalOffset( id, pitch, yaw, roll )
	return minX, minY, minZ, maxX, maxY, maxZ, oX, oY, oZ
end

function EHT.Housing.GetFurnitureCenter( id, x, y, z, pitch, yaw, roll )
	local dx, dy, dz = EHT.Housing.GetFurnitureWorldOffset( id, pitch, yaw, roll )
	if not x then x, y, z = EHT.Housing.GetFurniturePosition( id ) end
	return x + dx, y + dy, z + dz
end

function EHT.Housing.GetFurniturePositionFromCenter( id, x, y, z, pitch, yaw, roll )
	local dx, dy, dz = EHT.Housing.GetFurnitureWorldOffset( id, pitch, yaw, roll )
	return x - dx, y - dy, z - dz
end

function EHT.Housing.GetFurnitureEdgeFromCenter( id, cx, cy, cz, x, y, z, pitch, yaw, roll, marginx, marginy, marginz )
	id = EHT.Housing.FindFurnitureId( id )
	if not id then return 0, 0, 0, 0, 0, 0, 0, 0, 0 end

	if not pitch or not yaw or not roll then
		--local _, _, _, cpitch, cyaw, croll = EHT.Housing.GetKnownFurniturePositionAndOrientation( id )
		local _, _, _, cpitch, cyaw, croll = EHT.Housing.GetFurniturePositionAndOrientation( id )
		pitch, yaw, roll = pitch or cpitch, yaw or cyaw, roll or croll
	end

	local dx, dy, dz = EHT.Housing.GetFurnitureLocalDimensions( id )
	dx, dy, dz = EHT.World.Rotate( ( 0.5 * dx + ( marginx or 0 ) ) * cx, ( 0.5 * dy + ( marginy or 0 ) ) * cy, ( 0.5 * dz + ( marginz or 0 ) ) * cz, pitch, yaw, roll )

	return x + dx, y + dy, z + dz, dx, dy, dz, pitch, yaw, roll
end

function EHT.Housing.GetFurnitureCenterFromEdge( id, cx, cy, cz, x, y, z, pitch, yaw, roll, marginx, marginy, marginz )
	id = EHT.Housing.FindFurnitureId( id )
	if not id then return 0, 0, 0, 0, 0, 0, 0, 0, 0 end

	if not pitch or not yaw or not roll then
		--local _, _, _, cpitch, cyaw, croll = EHT.Housing.GetKnownFurniturePositionAndOrientation( id )
		local _, _, _, cpitch, cyaw, croll = EHT.Housing.GetFurniturePositionAndOrientation( id )
		pitch, yaw, roll = pitch or cpitch, yaw or cyaw, roll or croll
	end

	local dx, dy, dz = EHT.Housing.GetFurnitureLocalDimensions( id )
	dx, dy, dz = 0.5 * dx, 0.5 * dy, 0.5 * dz
	dx, dy, dz = dx + ( marginx or 0 ), dy + ( marginy or 0 ), dz + ( marginz or 0 )
	dx, dy, dz = dx * cx, dy * cy, dz * cz
	dx, dy, dz = EHT.World.Rotate( dx, dy, dz, pitch, yaw, roll )

	return x - dx, y - dy, z - dz, dx, dy, dz, pitch, yaw, roll
end

function EHT.Housing.GetFurniturePositionFromEdge( id, ... )
	local x, y, z, dx, dy, dz, pitch, yaw, roll = EHT.Housing.GetFurnitureCenterFromEdge( id, ... )
	x, y, z = EHT.Housing.GetFurniturePositionFromCenter( id, x, y, z, pitch, yaw, roll )
	return x, y, z, pitch, yaw, roll
end

function EHT.Housing.GetFurnitureSnapPositions( id, snapToId, x, y, z, pitch, yaw, roll )
	id = EHT.Housing.FindFurnitureId( id )
	snapToId = EHT.Housing.FindFurnitureId( snapToId )
	if not id or not snapToId then return false end

	local cx, cy, cz = EHT.Housing.GetFurnitureCenter( id, x, y, z, pitch, yaw, roll )
	local csx, csy, csz = EHT.Housing.GetFurnitureCenter( snapToId )
	local spitch, syaw, sroll = EHT.Housing.GetFurnitureOrientation( snapToId )
	local edges, sedges, positions = { }, { }, { }

	for ix = -1, 1 do
		for iy = -1, 1 do
			for iz = -1, 1 do
				if 0 ~= ix or 0 ~= iy or 0 ~= iz then
					local dx, dy, dz = EHT.Housing.GetFurnitureEdgeFromCenter( snapToId, ix, iy, iz, csx, csy, csz, spitch, syaw, sroll )
					table.insert( sedges, { dx, dy, dz } )

					dx, dy, dz = EHT.Housing.GetFurnitureEdgeFromCenter( id, ix, iy, iz, cx, cy, cz, pitch, yaw, roll )
					table.insert( edges, { dx, dy, dz, ix, iy, iz } )
				end
			end
		end
	end

	for index = 1, #edges do
		for sindex = 1, #sedges do
			local e = edges[index]
			local s = sedges[sindex]
			local dist = zo_distance3D( e[1], e[2], e[3], s[1], s[2], s[3] )

			if not e[7] or dist < e[7] then
				e[7] = dist
			end
		end
	end

	table.sort( edges, function( a, b ) return a[7] < b[7] end )

	local ix, iy, iz = edges[1][4], edges[1][5], edges[1][6]
	local ox, oy, oz = EHT.Housing.GetFurnitureCenterFromEdge( id, ix, iy, iz, 0, 0, 0, pitch, yaw, roll )

	for index = 1, #sedges do
		local e = sedges[index]
		local px, py, pz = e[1] + ox, e[2] + oy, e[3] + oz
		local dist = zo_distance3D( px, py, pz, cx, cy, cz )
		table.insert( positions, { px, py, pz, dist } )
	end

	table.sort( positions, SnapPositionDistanceComparer )

	if 3 < #positions then
		for index = #positions, 4, -1 do
			table.remove( positions, index )
		end
	end

	return positions
end

function EHT.Housing.SetFurnitureCenter( id, x, y, z, pitch, yaw, roll )
	if not id or not x or not y or not z then
		return nil
	end

	x, y, z = EHT.Housing.GetFurniturePositionFromCenter( id, x, y, z, pitch, yaw, roll )
	return EHT.Housing.SetFurniturePositionAndOrientation( id, x, y, z, pitch, yaw, roll )
end

function EHT.Housing.SetupDimensionLookupTable()
	local dimensions = { }
	local mt = {
		__index = function( t, k )
			--local dims = rawget( t, k )
			--if dims then return dims end
			--rawset( t, k, dims )
			return { EHT.Housing.GetFurnitureLocalDimensionsByItemId( tonumber( k ) ) }
		end
	}
	setmetatable( dimensions, mt )
	EHT.SavedVars.Dimensions = dimensions
	return dimensions
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Housing = true