------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.NotificationUI then MC.NotificationUI = ZO_Object.New( ZO_Object:Subclass() ) end


------[[ Locals ]]------


local WM = WINDOW_MANAGER
local NS = "MC_NotificationUI"

local ANIM_HANDLE = NS .. "_Anim"
local ANIM_INTERVAL = 30
local FADE_INTERVAL = 750
local DEFAULT_DURATION = 2500

local Queue = { }


------[[ Methods ]]------


local function GetLinearInterval( cycleMS, offsetMS )

	local frameTime = GetFrameTimeMilliseconds()
	return ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS )

end


local function GetSurface( index, surfacesX, surfacesY )

	index = index % ( surfacesX * surfacesY )
	local unitsX, unitsY = 1 / surfacesX, 1 / surfacesY
	local left, right, top, bottom = ( index * unitsX ) % 1, ( ( index + 1 ) * unitsX ) % 1, math.floor( index * unitsX ) * unitsY, ( math.floor( index * unitsX ) + 1 ) * unitsY
	if right < left then right = right + 1 end
	if bottom < top then bottom = bottom + 1 end
	return left, right, top, bottom

end


local function GetIntervalSurface( surfacesX, surfacesY, cycleMS, offsetMS )

	local totalSurfaces = surfacesX * surfacesY
	local interval = GetLinearInterval( cycleMS, offsetMS )
	interval = zo_clamp( math.floor( ( interval * totalSurfaces ) + 1 ), 1, totalSurfaces )
	return GetSurface( interval, surfacesX, surfacesY )

end


function MC.NotificationUI:UpdateAnimations()

	local item = Queue[ 1 ]

	if nil == item then
		self.Window:SetHidden( true )
		EVENT_MANAGER:UnregisterForUpdate( ANIM_HANDLE )
		return
	end

	local ft = GetGameTimeMilliseconds()

	if 0 == item.StartTime then
		self.Window:SetAlpha( 0 )

		if item.Icon then
			self.Icon:SetTexture( item.Icon )
			self.Icon:SetHidden( false )
			self.IconFlare:SetTextureCoords( 0, 0, 0, 0 )
			self.IconFlare:SetAlpha( 0 )
			self.IconFlare:SetHidden( false )
		else
			self.Icon:SetHidden( true )
			self.IconFlare:SetHidden( true )
		end

		self.Message:SetText( item.Message )
		self.Window:SetHidden( false )

		item.StartTime = ft
		item.StartFlareTime = 0

		PlaySound( SOUNDS.OBJECTIVE_DISCOVERED )
	end

	local td = ft - item.StartTime

	if td <= FADE_INTERVAL then
		self.Window:SetAlpha( ZO_EaseOutQuadratic(td / FADE_INTERVAL) )
	elseif td > FADE_INTERVAL + item.Duration then
		self.IconFlare:SetAlpha( 0 )
		td = td - (FADE_INTERVAL + item.Duration)
		if td > FADE_INTERVAL then
			table.remove(Queue, 1)
		else
			self.Window:SetAlpha(ZO_EaseOutQuadratic(1 - (td / FADE_INTERVAL)))
		end
	else
		if 0 == item.StartFlareTime then item.StartFlareTime = ft end
		self.IconFlare:SetAlpha(1)
		self.IconFlare:SetTextureCoords(GetIntervalSurface(8, 8, DEFAULT_DURATION, item.StartFlareTime))
	end

end


function MC.NotificationUI:QueueMessage( message, icon, duration )

	if nil == message or "" == message then return end
	if nil == duration then
		duration = 250 + 260 * math.ceil(#message / 7)
	end

	table.insert( Queue, { Icon = icon, Message = message, Duration = duration, StartTime = 0 } )
	EVENT_MANAGER:RegisterForUpdate( ANIM_HANDLE, ANIM_INTERVAL, function() self:UpdateAnimations() end )

end


------[[ Constructors ]]------


do

	local self = MC.NotificationUI
	local c, cg, w

	-- Top-level Window

	w = WM:CreateTopLevelWindow( NS )
	self.Window = w
	w:SetHidden( true )
	w:SetDimensionConstraints( 800, 300, 800, 300 )
	w:SetMovable( false )
	w:SetMouseEnabled( false )
	w:SetClampedToScreen( true )
	w:SetAnchor( TOP, GuiRoot, TOP, 0, 180 )

	-- Outer Container

	cg = WM:CreateControl( NS .. "Container", w, CT_CONTROL )
	self.Container = cg
	cg:SetAnchor( TOPLEFT, w, TOPLEFT, 0, 0 )
	cg:SetAnchor( BOTTOMRIGHT, w, BOTTOMRIGHT, 0, 0 )
	cg:SetResizeToFitDescendents( true )
	cg:SetMouseEnabled( false )

	-- Message

	c = WM:CreateControl( NS .. "Message", cg, CT_LABEL )
	self.Message = c
	c:SetAnchor( TOPLEFT, cg, TOPLEFT, 0, 0 )
	c:SetAnchor( BOTTOMRIGHT, cg, BOTTOMRIGHT, 0, 0 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	c:SetFont( "$(BOLD_FONT)|$(KB_40)|soft-shadow-thick" )
	c:SetText( "" )
	c:SetColor( 1, 1, 0.65, 1 )
	c:SetMouseEnabled( false )

	-- Icon

	c = WM:CreateControl( NS .. "IconFlare", cg, CT_TEXTURE )
	self.IconFlare = c
	c:SetAnchor( RIGHT, self.Message, LEFT, -10, 0 )
	c:SetDimensions( 164, 164 )
	c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	c:SetColor( 1, 1, 0, 0.6 )
	c:SetTexture( "esoui/art/champion/champion_star_unlockedconfirm.dds" )
	c:SetMouseEnabled( false )

	c = WM:CreateControl( NS .. "Icon", cg, CT_TEXTURE )
	self.Icon = c
	c:SetAnchor( CENTER, self.IconFlare, CENTER, 0, 0 )
	c:SetDimensions( 128, 128 )
	c:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	c:SetMouseEnabled( false )

end
