------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.ProcessUI then MC.ProcessUI = ZO_Object.New( ZO_Object:Subclass() ) end


------[[ Locals ]]------


local WM = WINDOW_MANAGER
local NS = "MC_ProcessUI"

local ANIM_HANDLE = NS .. "_Anim"
local ANIM_INTERVAL = 30

local SPIN_INTERVAL = 6000
local GLOW_INTERVAL = 3000


------[[ Methods ]]------


function MC.ProcessUI:UpdateAnimations()

	local ft = GetFrameTimeMilliseconds()

	local iconAngle = ( ( ft % SPIN_INTERVAL ) / SPIN_INTERVAL ) * 2 * math.pi
	self.MCIcon:SetTextureRotation( -iconAngle )

	local x = math.sin( ( ( ft % GLOW_INTERVAL ) / GLOW_INTERVAL ) * math.pi )
	self.MCIcon:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0.25 + 0.5 * x )

end


function MC.ProcessUI:SetStatus( message )

	self.Status:SetText( message )

end


function MC.ProcessUI:Show()

	self.Window:SetHidden( false )
	EVENT_MANAGER:RegisterForUpdate( ANIM_HANDLE, ANIM_INTERVAL, function() self:UpdateAnimations() end )
	return true

end


function MC.ProcessUI:Hide()

	EVENT_MANAGER:UnregisterForUpdate( ANIM_HANDLE )
	self.Window:SetHidden( true )
	self.Status:SetText( "" )

end


function MC.ProcessUI:IsHidden()

	return not self.Window or self.Window:IsHidden()

end


------[[ Constructors ]]------


do

	local self = MC.ProcessUI
	local c, cg, w

	-- Top-level Window

	w = WM:CreateTopLevelWindow( NS )
	self.Window = w
	w:SetHidden( true )
	w:SetDimensionConstraints( 210, 160, 210, 160 )
	w:SetMovable( true )
	w:SetMouseEnabled( true )
	w:SetClampedToScreen( true )
	w:SetAlpha( 1.0 )
	w:SetAnchor( CENTER, GuiRoot, CENTER, 0, 100 )

	-- Outer Container

	cg = WM:CreateControl( NS .. "Container", w, CT_CONTROL )
	self.Container = cg
	cg:SetDimensions( 210, 210 )
	cg:SetAnchor( CENTER, w, CENTER, 0, 0 )
	cg:SetMouseEnabled( false )

	-- Icon

	c = WM:CreateControl( NS .. "MCIcon", cg, CT_TEXTURE )
	self.MCIcon = c
	c:SetAnchor( CENTER, cg, CENTER, 0, 0 )
	c:SetDimensions( 210, 210 )
	c:SetTexture( "esoui/art/emotes/emotes_indexicon_perpetual_over.dds" )
	c:SetVertexColors( 4 + 8, 0, 1, 0.9, 1 )
	c:SetVertexColors( 1 + 2, 0.2, 0.4, 1, 1 )
	c:SetBlendMode( TEX_BLEND_MODE_ADD )
	c:SetMouseEnabled( false )

	-- Title

	c = WM:CreateControl( NS .. "Title", cg, CT_LABEL )
	self.Title = c
	c:SetAnchor( CENTER, cg, CENTER, 0, -100 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_TOP )
	c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_40)|thick-outline" )
	c:SetText( "Please wait ..." )
	c:SetColor( 1, 1, 0.65, 1 )
	c:SetMouseEnabled( false )

	-- Status

	c = WM:CreateControl( NS .. "Status", cg, CT_LABEL )
	self.Status = c
	c:SetAnchor( CENTER, cg, CENTER, 0, 80 )
	c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	c:SetVerticalAlignment( TEXT_ALIGN_TOP )
	c:SetFont( "$(GAMEPAD_MEDIUM_FONT)|$(KB_30)|thick-outline" )
	c:SetText( "" )
	c:SetColor( 1, 1, 0.75, 1 )
	c:SetMouseEnabled( false )

end
