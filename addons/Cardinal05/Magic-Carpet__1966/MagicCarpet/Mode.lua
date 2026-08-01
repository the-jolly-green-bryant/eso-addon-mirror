------[[ Namespaces ]]------

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Mode then MC.Mode = ZO_Object:Subclass() end

local USE_DEFAULT = math.huge

------[[ Static Variables ]]------


MC.Mode.ATTRIBUTE = { }
MC.Mode.ATTRIBUTE.ANY_AVAILABLE = "Max(Convenience)"
MC.Mode.ATTRIBUTE.KID_TESTED = "Kid Tested / Mother Approved"
MC.Mode.ATTRIBUTE.COMBAT_ENHANCED = "Combat Enhanced"
MC.Mode.ATTRIBUTE.COSMETIC = "Cosmetic / No Flight"
MC.Mode.ATTRIBUTE.FLIGHT = "Flight"
MC.Mode.ATTRIBUTE.PANORAMA_VIEW = "PanoramaView(tm)"
MC.Mode.ATTRIBUTE.LOW_COST = "Budget Friendly"

MC.Mode.PANORAMA_VIEW_MIN_FRAMEFRATE = 45
MC.Mode.PANORAMA_VIEW_MAX_LATENCY = 170

local Modes = { }


------[[ Constructors ]]------


function MC.Mode:New( ... )

    local obj = ZO_Object.New( self )
    obj:Initialize( ... )
    return obj

end


function MC.Mode:Initialize( ... )

	local p1 = select( 1, ... )
	if nil ~= p1 then

		if "string" == type( p1 ) then
			self:InitializeByName( ... )
			return
		elseif "table" == type( p1 ) then
			self:InitializeByTable( ... )
			return
		else
			self:SetSortOrder()
		end

	end

end


function MC.Mode:InitializeByName( name )

	self:InitializeByTable( { Name = name, Active = true, SortOrder = NonContiguousCount( Modes ) } )

end


function MC.Mode:InitializeByTable( tbl )

	if nil == tbl then return end

	self:SetName( tbl.Name )
	if nil ~= tbl.Active then self:SetActive( tbl.Active ) else self:SetActive( true ) end
	self:SetSortOrder( tbl.SortOrder )
	self:SetAuthor( tbl.Author )
	self:SetDescription( tbl.Description )
	self:SetModel( tbl.Model )
	self:SetQuality( tbl.Quality )
	self:SetAttributes( tbl.Attributes )
	self:SetComponents( tbl.Components )
	self:SetSetupFunction( tbl.SetupFunction )
	self:SetUpdateFunction( tbl.UpdateFunction )
	self.SortIndex = tbl.SortIndex or NonContiguousCount( Modes )
	self.CameraDistance = tbl.CameraDistance
	self.CameraVerticalOffset = tbl.CameraVerticalOffset
	self:CreateTrophy()

end


------[[ Static Methods ]]------


function MC.Mode:IsInstance( obj )

	return getmetatable( obj ) == self

end


function MC.Mode:Cast( obj )

	if nil == obj or "table" ~= type( obj ) then return end
	setmetatable( obj, self )
	local mt = getmetatable( obj )
	mt.__index = self

end


function MC.Mode:CastList( list )

	if nil == list or "table" ~= type( list ) then return end

	for index, obj in pairs( list ) do
		if not MC.Mode:IsInstance( list[index] ) then
			MC.Mode:Cast( list[index] )
		end
	end

end


local function CompareModes( m1, m2 )

	if m1:GetSortOrder() < m2:GetSortOrder() then
		return true
	elseif m1:GetSortOrder() > m2:GetSortOrder() then
		return false
	else
		return string.lower( m1:GetName() ) < string.lower( m2:GetName() )
	end

end


do

	local allModes

	function MC.Mode:GetAllModes()

		if not allModes then
			allModes = { }

			for _, Mode in pairs( Modes ) do
				table.insert( allModes, Mode )
			end

			table.sort( allModes, CompareModes )

			table.insert( allModes, 1, MC.Mode:New( {
				Name = "Any Available Mode",
				Description = "Uses any Flight-capable mode for which the required items are available.\nPrefers the mode with items placed nearest to you.",
				SortOrder = 1,
				Quality = ITEM_QUALITY_NORMAL,
				Attributes = { MC.Mode.ATTRIBUTE.ANY_AVAILABLE, MC.Mode.ATTRIBUTE.KID_TESTED, },
			} ) )
		end

		return allModes

	end

	function MC.Mode:GetModesByAttribute( attr )

		local allModes = self:GetAllModes()
		local modes = { }

		for _, mode in ipairs( allModes ) do
			if mode:HasAttribute( attr ) then
				table.insert( modes, mode )
			end
		end

		return modes

	end

end


function MC.Mode:GetByName( name )

	return Modes[ string.lower( name ) ]

end


function MC.Mode:Exists( name )

	return nil ~= MC.Modes:GetByName( name )

end


function MC.Mode:GetDefaultMode()

	local modes = MC.Mode:GetAllModes()
	return modes[1]

end


------[[ Instance Methods ]]------


function MC.Mode:GetName()

	return self.Name

end


function MC.Mode:GetColorizedName()

	return self:GetNameColor():Colorize( self.Name )

end


function MC.Mode:GetSortOrder()

	return self.SortOrder

end


function MC.Mode:GetCameraPreferences()

	local distance, offset = self.CameraDistance, self.CameraVerticalOffset

	if distance == USE_DEFAULT then
		distance = nil
	elseif nil == distance then
		distance = 2
	end

	if offset == USE_DEFAULT then
		offset = nil
	elseif nil == offset then
		offset = 0.5
	end

	return distance, offset

end


function MC.Mode:GetAuthor()

	return self.Author

end


function MC.Mode:GetDescription()

	return self.Description

end


function MC.Mode:GetModel()

	return self.Model

end


function MC.Mode:GetQuality()

	return self.Quality or 0

end


function MC.Mode:GetNameColor()

	local color = ZO_ColorDef.FromInterfaceColor( INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, self.Quality or ITEM_QUALITY_LEGENDARY )
	local r, g, b = color:UnpackRGB()
	return ZO_ColorDef:New( math.min( 1, 1.2 * r ), math.min( 1, 1.2 * g ), math.min( 1, 1.2 * b ) )

end


function MC.Mode:GetColorizedQualityString()

	local quality

	if self.Quality == ITEM_QUALITY_MAGIC then
		quality = "Fine"
	elseif self.Quality == ITEM_QUALITY_ARCANE then
		quality = "Superior"
	elseif self.Quality == ITEM_QUALITY_ARTIFACT then
		quality = "Epic"
	elseif self.Quality == ITEM_QUALITY_LEGENDARY then
		quality = "Legendary"
	elseif self.Quality == ITEM_QUALITY_NORMAL then
		quality = "Normal"
	else
		quality = "Legendary"
	end

	return self:GetQualityColor():Colorize( quality )

end


function MC.Mode:GetQualityColor()

 	local color = ZO_ColorDef.FromInterfaceColor( INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, self.Quality or ITEM_QUALITY_LEGENDARY )
	return color

end


function MC.Mode:GetAttributes()

	return self.Attributes

end


function MC.Mode:GetAttributeString()

	if nil == self.Attributes or 0 >= #self.Attributes then
		return ""
	else
		return table.concat( self.Attributes, ",  " )
	end

end


function MC.Mode:HasAttribute( attribute )

	if self.Attributes then
		for _, attr in pairs( self.Attributes ) do
			if attr == attribute then return true end
		end
	end
	return false

end


function MC.Mode:GetComponents()

	return self.Components

end


function MC.Mode:GetSetupFunction()

	return self.SetupFunction

end


function MC.Mode:GetUpdateFunction()

	return self.UpdateFunction

end


function MC.Mode:SetName( name )

	local key = string.lower( name )
	if Modes[ key ] then
		error( string.format( "Duplicate mode defined: %s", key ) )
		return
	end

	Modes[ key ] = self
	self.Name = name

end


function MC.Mode:IsActive()

	return self.Active

end


function MC.Mode:SetActive( active )

	self.Active = active

end


function MC.Mode:SetSortOrder( order )

	if nil == order then
		self.SortOrder = 10000
	else
		self.SortOrder = order
	end

end


function MC.Mode:SetAuthor( author )

	self.Author = author

end


function MC.Mode:SetDescription( description )

	self.Description = description

end


function MC.Mode:SetModel( model )

	self.Model = model

end


function MC.Mode:SetQuality( quality )

	self.Quality = quality

end


function MC.Mode:SetAttributes( attributes )

	self.Attributes = attributes

end


function MC.Mode:SetComponents( components )

	self.Components = components

end


function MC.Mode:SetSetupFunction( setupFunction )

	self.SetupFunction = setupFunction

end


function MC.Mode:SetUpdateFunction( updateFunction )

	self.UpdateFunction = updateFunction

end


function MC.Mode:CreateTrophy()

	local name, quality = self:GetName(), self:GetQuality()
	local points = 10

	if quality == ITEM_QUALITY_MAGIC then
		points = 20
	elseif quality == ITEM_QUALITY_ARCANE or quality == 0 then
		points = 50
	elseif quality == ITEM_QUALITY_ARTIFACT then
		points = 75
	elseif quality == ITEM_QUALITY_LEGENDARY then
		points = 150
	end

	MC.Trophy:New( {
		Name = name,
		Category = MC.Trophy.CATEGORY.MODES,
		Points = points,
		Description = string.format( "Successfully assembled the Magic Carpet mode \"%s\".", name )
	} )

end


function MC.Mode:CompareTo( obj )

	if nil == obj or not MC.Mode:IsInstance( obj ) then return false end
	return self:GetName() == obj:GetName()

end


function MC.Mode:GetPreviousMode()

	local modes = MC.Mode:GetAllModes()
	local numModes = #modes

	for index = 1, numModes do
		if self:CompareTo( modes[index] ) then
			if 1 == index then
				return modes[numModes]
			else
				return modes[index - 1]
			end
		end
	end

end


function MC.Mode:GetNextMode()

	local modes = MC.Mode:GetAllModes()
	local numModes = #modes

	for index = 1, numModes do
		if self:CompareTo( modes[index] ) then
			if index == numModes then
				return modes[1]
			else
				return modes[index + 1]
			end
		end
	end

end
