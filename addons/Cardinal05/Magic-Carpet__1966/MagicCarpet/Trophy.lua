------[[ Namespaces ]]------

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Trophy then MC.Trophy = ZO_Object:Subclass() end

------[[ Static Variables ]]------

MC.Trophy.QUALITY = { }
MC.Trophy.QUALITY.LOW = 1
MC.Trophy.QUALITY.MEDIUM = 2
MC.Trophy.QUALITY.HIGH = 3

MC.Trophy.CATEGORY = { }
MC.Trophy.CATEGORY.MODES = 1
MC.Trophy.CATEGORY.COMBAT = 2
MC.Trophy.CATEGORY.TRICKS = 3

local Trophies = { }

------[[ Constructors ]]------

function MC.Trophy:New( data )
    local obj = ZO_Object.New( self )

	if "table" == type( data ) then
		obj:SetName( data.Name )
		obj:SetCategory( data.Category )
		obj:SetDescription( data.Description )
		obj:SetPoints( data.Points )
	end

    return obj
end

------[[ Static Methods ]]------

function MC.Trophy:IsInstance( obj )
	return getmetatable( obj ) == self
end

function MC.Trophy:Cast( obj )
	if nil == obj or "table" ~= type( obj ) then return end
	setmetatable( obj, self )
	local mt = getmetatable( obj )
	mt.__index = self
end

function MC.Trophy:CastList( list )
	if nil == list or "table" ~= type( list ) then return end

	for index, obj in pairs( list ) do
		if not MC.Trophy:IsInstance( list[index] ) then
			MC.Trophy:Cast( list[index] )
		end
	end
end

function MC.Trophy:GetTrophies()
	return Trophies
end

function MC.Trophy:GetEarnedTrophies()
	local earned = MC.Vars.EarnedTrophies
	if nil == earned then
		earned = { }
		MC.Vars.EarnedTrophies = earned
	end
	return earned
end

function MC.Trophy:GetByName( name )
	local trophies = self:GetTrophies()
	return trophies[ string.lower( name ) ]
end

function MC.Trophy:HasEarned( name )
	local trophy = self:GetByName( name )
	if nil == trophy then return false end

	local dateEarned = trophy:GetDateEarned()
	return nil ~= dateEarned, dateEarned
end

function MC.Trophy:SetEarned( name )
	local trophy = self:GetByName( name )
	if nil == trophy then return false end

	if nil == trophy:GetDateEarned() then
		trophy:SetDateEarned( GetTimeStamp() )
	end
	return trophy:GetDateEarned()
end

------[[ Instance Methods ]]------

function MC.Trophy:GetName()
	return self.Name
end

function MC.Trophy:GetCategory()
	return self.Category
end

function MC.Trophy:GetDescription()
	return self.Description
end

function MC.Trophy:GetPoints()
	return self.Points
end

function MC.Trophy:GetDateEarned()
	local earned = MC.Trophy:GetEarnedTrophies()
	return earned[ self:GetName() ]
end

function MC.Trophy:GetDateEarnedString()
	local dateEarned = self:GetDateEarned()
	if nil ~= dateEarned then return GetDateStringFromTimestamp( dateEarned ) end
	return ""
end

function MC.Trophy:GetQuality()
	local points = self:GetPoints() or 0
	if 100 <= points then
		return MC.Trophy.QUALITY.HIGH
	elseif 50 <= points then
		return MC.Trophy.QUALITY.MEDIUM
	else
		return MC.Trophy.QUALITY.LOW
	end
end

function MC.Trophy:GetColor()
	local quality = self:GetQuality()
	local dateEarned = self:GetDateEarned()

	if dateEarned then
		if quality == MC.Trophy.QUALITY.HIGH then
			return 1, 0.8, 0.4, 1
		elseif quality == MC.Trophy.QUALITY.MEDIUM then
			return 1, 1, 1, 1
		else
			return 1, 1, 1, 1
		end
	else
		return 0.5, 0.5, 0.5, 1
	end
end

function MC.Trophy:GetDesaturation()
	return nil == self:GetDateEarned() and 1 or 0
end

local TROPHY_ICONS = { }
TROPHY_ICONS[MC.Trophy.QUALITY.HIGH] = "/MagicCarpet/media/trophy_3.dds"
TROPHY_ICONS[MC.Trophy.QUALITY.MEDIUM] = "/MagicCarpet/media/trophy_2.dds"
TROPHY_ICONS[MC.Trophy.QUALITY.LOW] = "/MagicCarpet/media/trophy_1.dds"

function MC.Trophy:GetIcon()
	local category = self:GetCategory() or 0
	local quality = self:GetQuality()
	local icon = TROPHY_ICONS[quality]
	if not icon then icon = TROPHY_ICONS[MC.Trophy.QUALITY.LOW] end
	return icon
end

function MC.Trophy:SetName( name )
	local key = string.lower( name )
	local trophies = self:GetTrophies()

	if trophies[ key ] and self ~= trophies[ key ] then
		error( string.format( "Duplicate trophy defined: %s", key ) )
		return
	end

	Trophies[ key ] = self
	self.Name = name
end

function MC.Trophy:SetCategory( category )
	self.Category = category
end

function MC.Trophy:SetDescription( description )
	self.Description = description
end

function MC.Trophy:SetPoints( points )
	self.Points = points
end

function MC.Trophy:SetDateEarned( dateEarned )
	local earned = MC.Trophy:GetEarnedTrophies()
	local name = self:GetName()

	if nil ~= earned[ name ] then return end
	earned[ name ] = dateEarned

	zo_callLater(
		function()
			MC.NotificationUI:QueueMessage( string.format( "You have earned the %s trophy!", self:GetName() or "" ), self:GetIcon() )
		end,
		1000 )
end
