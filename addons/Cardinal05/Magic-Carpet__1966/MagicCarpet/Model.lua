------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Model then MC.Model = ZO_Object:Subclass() end


------[[ Locals ]]------


local MODEL_VERSION = 2
local MODEL_EOR = "!"
local MODEL_EOC = "\""
local MODEL_BEG = string.rep( MODEL_EOC, 10 )

local MODEL_INVALID_FORMAT = "Invalid model data: %s"
local MODEL_INVALID_EOC_FORMAT = "Invalid model data: Missing end-of-attribute identifier for attribute: %s"
local MODEL_INVALID_EOR_FORMAT = "Invalid model data: Missing end-of-component identifier for component: %s"

local BASE_88 = { }, { }
for base88Index = 0, 87 do
	BASE_88[ string.char( base88Index + 36 ) ] = base88Index
end


------[[ Constructors ]]------

--[[
function MC.Model:New( data, version )

	local components = { }
	if nil == data or "" == data then return components end

	version = version or 1
	local s, component, indexStart, indexEnd = data, nil, 1, 1
	local sLen = string.len( s )

	while indexStart < sLen do
		if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
		indexStart = indexStart + 1
	end

	local _, beginTagIndex = string.find( s, MODEL_BEG, indexStart )
	if nil ~= beginTagIndex then
		indexStart = beginTagIndex + 1
	end

	indexStart = string.find( s, MODEL_EOR, indexStart )
	if nil == indexStart then error( string.format( MODEL_INVALID_FORMAT, "First record not found." ) ) end
	indexStart = indexStart + 1

	if indexStart >= sLen then return components end

	while nil ~= indexStart do

		component = { }

		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "Item ID" ) ) end
		component.ItemId = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		component.Link = MC.Model:GetItemIdLink( component.ItemId )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "X" ) ) end
		component.X = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "Y" ) ) end
		component.Y = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "Z" ) ) end
		component.Z = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "Pitch" ) ) end
		component.Pitch = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		component.Pitch = math.rad( component.Pitch / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( MODEL_INVALID_EOC_FORMAT, "Yaw" ) ) end
		component.Yaw = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		component.Yaw = math.rad( component.Yaw / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, version < 2 and MODEL_EOR or MODEL_EOC, indexStart )
		if nil == indexEnd then error( string.format( version < 2 and MODEL_INVALID_EOR_FORMAT or MODEL_INVALID_EOC_FORMAT, "Roll" ) ) end
		component.Roll = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		component.Roll = math.rad( component.Roll / 100 )

		if version >= 2 then
			local NUM_META_COLUMNS = 6
			for metaIndex = 1, NUM_META_COLUMNS do
				indexStart = indexEnd + 1
				indexEnd = string.find( s, metaIndex < NUM_META_COLUMNS and MODEL_EOC or MODEL_EOR, indexStart )
				if nil == indexEnd then error( string.format( metaIndex < NUM_META_COLUMNS and MODEL_INVALID_EOC_FORMAT or MODEL_INVALID_EOR_FORMAT, string.format( "Meta%d", metaIndex ) ) ) end
			end
		end

		table.insert( components, component )
		indexStart = indexEnd + 1

		while indexStart < sLen do
			if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
			indexStart = indexStart + 1
		end

		if indexStart >= sLen then break end

	end

	local modelObject = ZO_Object.New( self )

	modelObject.Components = components
	modelObject:GenerateRequirements()

	return modelObject

end
]]
local CLIPBOARD_VERSION = 3
local CLIPBOARD_EOR = "!"
local CLIPBOARD_EOC = "\""
local CLIPBOARD_BEG = string.rep( CLIPBOARD_EOC, 10 )
local CLIPBOARD_INVALID_FORMAT = "Invalid clipboard data: %s"
local CLIPBOARD_INVALID_EOC_FORMAT = "Invalid clipboard data: Missing end-of-column identifier for column: %s"
local CLIPBOARD_INVALID_EOR_FORMAT = "Invalid clipboard data: Missing end-of-record identifier for column: %s"
local CLIPBOARD_INVALID_EFFECT_TYPE = "Invalid clipboard data: Undefined effect type index: %s"

function MC.Model:DeserializeClipboardExportData( s )
	local group = { }
	if nil == s or "" == s then return group end

	local item = nil
	local indexStart, indexEnd, indexEnd2 = 1, 1, 1
	local isEffect = false
	local sLen = string.len( s )

	while indexStart < sLen do
		if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
		indexStart = indexStart + 1
	end

	local version = CLIPBOARD_VERSION

	-- Automatically skip any accidentally copied instructional text.

	local _, beginTagIndex = string.find( s, CLIPBOARD_BEG, indexStart )
	if nil ~= beginTagIndex then
		indexStart = beginTagIndex + 1
	end

	local indexVersion = string.find( s, "V", indexStart )
	if indexVersion then
		local indexVersionEnd = string.find( s, CLIPBOARD_EOR, indexVersion )
		if indexVersionEnd then
			version = string.sub( s, indexVersion + 1, indexVersionEnd - 1 )
			if version and "" ~= version then
				version = tonumber( version )
			end
		end
	end

	indexStart = string.find( s, CLIPBOARD_EOR, indexStart )
	if nil == indexStart then error( string.format( CLIPBOARD_INVALID_FORMAT, "First record not found." ) ) end
	indexStart = indexStart + 1

	if indexStart >= sLen then return group end

	while nil ~= indexStart do
		item = { }
		isEffect = false

		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Item ID" ) ) end
		item.ItemId = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		item.Link = MC.Model:GetItemIdLink( item.ItemId )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "X" ) ) end
		item.X = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Y" ) ) end
		item.Y = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Z" ) ) end
		item.Z = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Pitch" ) ) end
		item.Pitch = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		item.Pitch = math.rad( item.Pitch / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Yaw" ) ) end
		item.Yaw = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		item.Yaw = math.rad( item.Yaw / 100 )

		indexStart = indexEnd + 1
		indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
		indexEnd2 = string.find( s, CLIPBOARD_EOC, indexStart )
		if nil == indexEnd2 and nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Roll" ) ) end
		if indexEnd2 and ( not indexEnd or indexEnd2 < indexEnd ) then
			isEffect = true
			indexEnd = indexEnd2
		end
		item.Roll = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
		item.Roll = math.rad( item.Roll / 100 )

		if isEffect then
			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeX" ) ) end
			item.SizeX = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeY" ) ) end
			item.SizeY = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "SizeZ" ) ) end
			item.SizeZ = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

			indexStart = indexEnd + 1
			indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
			if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Color" ) ) end
			item.Color = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )

			if version < 3 then
				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
				if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Alpha" ) ) end
				item.Alpha = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
			else
				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOC, indexStart )
				if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOC_FORMAT, "Alpha" ) ) end
				item.Alpha = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
				if not item.Alpha then item.Alpha = 1 end

				indexStart = indexEnd + 1
				indexEnd = string.find( s, CLIPBOARD_EOR, indexStart )
				if nil == indexEnd then error( string.format( CLIPBOARD_INVALID_EOR_FORMAT, "Contrast" ) ) end
				item.Contrast = self:ConvertBase88ToInteger( string.sub( s, indexStart, indexEnd - 1 ) )
				if not item.Contrast or 0 == item.Contrast then item.Contrast = 1 end
			end
		end

		table.insert( group, item )
		indexStart = indexEnd + 1

		while indexStart < sLen do
			if 33 <= string.byte( string.sub( s, indexStart, indexStart ) ) then break end
			indexStart = indexStart + 1
		end

		if indexStart >= sLen then break end
	end

	return group
end

function MC.Model:New( data )
	if nil == data or "" == data then return { } end

	local components = self:DeserializeClipboardExportData( data )
	if not components then return { } end

	local modelObject = ZO_Object.New( self )
	modelObject.Components = components
	modelObject:NormalizeOffsets()
	modelObject:GenerateRequirements()

	return modelObject
end

------[[ Methods ]]------

function MC.Model:GetComponents()
	return self.Components
end

function MC.Model:GetRequirements()
	return self.Requirements
end

function MC.Model:GenerateRequirements( components )
	local matched, req, list = false, nil, { }

	if nil == components then components = self.Components end
	if "table" ~= type( components ) then return list end

	for _, component in ipairs( components ) do
		matched = false

		if component.Link then
			for _, req in ipairs( list ) do
				if req[1] == component.Link then
					req[2] = req[2] + 1
					matched = true
					break
				end
			end

			if not matched then
				req = { component.Link, 1 }
				table.insert( list, req )
			end
		end
	end

	self.Requirements = list
end

function MC.Model:ConvertBase88ToInteger( base88 )
	assert( nil ~= base88, "Parameter 'base88' must be non-null." )
	assert( "" ~= base88, "Parameter 'base88' must be non-empty." )

	local d, p, n, v = 0, 0, 0, 0
	local sign = 1

	if string.sub( base88, 1, 1 ) == "#" then
		sign = -1
		base88 = string.sub( base88, 2 )
	end

	for i = string.len( base88 ), 1, -1 do
		v = BASE_88[ string.sub( base88, i, i ) ]
		assert( nil ~= v, string.format( "Parameter 'base88' is an invalid Base88 value: '%s'", base88 ) )
		d = math.pow( 88, p ) * v
		n = n + d
		p = p + 1
	end

	return sign * n
end

function MC.Model:GetItemIdLink( itemId )
	if nil == itemId then return nil end

	local dataId = GetCollectibleFurnitureDataId( itemId )
	if nil ~= dataId and 0 ~= dataId then
		return GetCollectibleLink( itemId, LINK_STYLE_DEFAULT )
	else
		return string.format( "|H0:item:%s%s|h|h", tostring( itemId ), string.rep( ":0", 20 ) )
	end
end

function MC.Model:NormalizeOffsets()
	if not self.offsetsNormalized then
		self.offsetsNormalized = true

		local maxX, maxY, maxZ = 0, 0, 0
		local minX, minY, minZ = math.huge, math.huge, math.huge
		local components = self:GetComponents()

		for _, c in ipairs( components ) do
			maxX, maxY, maxZ = math.max( c.X, maxX ), math.max( c.Y, maxY ), math.max( c.Z, maxZ )
			minX, minY, minZ = math.min( c.X, minX ), math.min( c.Y, minY ), math.min( c.Z, maxZ )
		end

		local offX, offY, offZ = -minX + 0.5 * ( maxX - minX ), -minY + 0.5 * ( maxY - minY ), -minZ + 0.5 * ( maxZ - minZ )

		for _, c in ipairs( components ) do
			c.X, c.Y, c.Z = c.X + offX, c.Y + offY, c.Z + offZ
		end
	end
end

function MC.Model:Construct( furnitureList, callback )
	if "table" ~= type( furnitureList ) then
		if callback then callback( false ) end
		return false
	end

	local components = self:GetComponents()
	local matched, items, componentMap = false, { }, { }

	for _, furniture in ipairs( furnitureList ) do
		table.insert( items, furniture )
	end

	for _, component in ipairs( components ) do
		matched = false

		for index, item in ipairs( items ) do
			if MC.Furniture:CompareLinks( component.Link, item:GetLink() ) then
				table.insert( componentMap, { component, item } )
				table.remove( items, index )
				matched = true
				break
			end
		end

		if not matched then
			if callback then callback( false, component ) end
			return false, component
		end
	end

	local originX, originY, originZ = GetPlayerWorldPositionInHouse()
	originY = originY + 500

	MC.Transaction:New(
		"Model Assembly",
		{
			Index = 0,
			List = componentMap,
			OriginX = originX,
			OriginY = originY,
			OriginZ = originZ
		},
		function( tran )
			local data = tran:GetData()
			local index = data.Index + 1
			data.Index = index

			local mapItem = data.List[index]
			if nil == mapItem then return true end

			MC.ProcessUI:SetStatus( string.format( "Assembling items (%d of %d)", index, #data.List ) )

			local component, item = mapItem[1], mapItem[2]
			local x, y, z, pitch, yaw, roll = data.OriginX + component.X, data.OriginY + component.Y, data.OriginZ + component.Z, component.Pitch, component.Yaw, component.Roll
			item:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
		end,
		nil,
		function()
			MC.ProcessUI:SetStatus( "" )
			if callback then callback( true ) end
		end
	)
end
