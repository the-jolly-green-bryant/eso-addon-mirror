local DsRBeam = DsRGuildBeam

local BASE_TILT_PITCH = math.rad(-0.05)
local MAX_TILT_PITCH = math.rad(-0.05)
local MAX_BEAM_HEIGHT_CM = 50000

local RAD45, RAD90, RAD180, RAD270, RAD360 = 0.25 * math.pi, 0.5 * math.pi, math.pi, 1.5 * math.pi, 2 * math.pi
local RADGL_LOW, RADGL_HIGH = math.rad( 89.8 ), math.rad( 90.2 )
local function round( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end

DsRBeam.GlobalAlpha = 1
DsRBeam.GlobalIteration = 1
DsRBeam.GlobalOffsetY = 20000
DsRBeam.GlobalOffsetZ = 0
DsRBeam.GlobalInterval = 20000
DsRBeam.GlobalInterval1 = DsRBeam.GlobalInterval * 0.4
DsRBeam.GlobalInterval2 = DsRBeam.GlobalInterval * 0.27
DsRBeam.GlobalIntervals = { }
DsRBeam.GlobalAlphas = { }

---[ Class Declarations ]---

DsRBeam.Effect = ZO_Object:Subclass()
DsRBeam.EffectType = ZO_Object:Subclass()
DsRBeam.EffectUI = { }
DsRBeam.Particle = ZO_Object:Subclass()
DsRBeam.ParticleEmitter = ZO_Object:Subclass()
DsRBeam.World = ZO_Object:Subclass()

---[ Private Constants ]---

local MAX_EFFECTS = 2000
local EVENT_PREFIX = "DsRBeamEffect"
local EFFECT_PREFIX = "DsRBeamEffect"
local PARTICLE_PREFIX = "DsRBeamParticle"
local NIL_TEXTURE = "nil"
local DRAW_LEVEL_EFFECTS = 10
local MAX_PARTICLE_DRAW_LEVEL = 200000
local DRAW_LEVEL_OVERLAY_EFFECT = MAX_PARTICLE_DRAW_LEVEL * 1.2
local MAX_PARTICLE_INIT_TIME = 2000
local PLAYER_CAMERA_UPDATE_INTERVAL = 40
local MAX_LOCALIZED_DISTANCE = 2000

local TEXTURES = {
	BLESSING = "circle_soft",
	LIGHT 	 = "square",
	DEAD 	 = "dead",
}

DsRBeam.Textures = TEXTURES

do
	local function GetTextureFilename( filename )
		return string.format( "/DsRGuildHall/misc/3DObjects/%s.dds", filename )
	end

	for key, value in pairs( TEXTURES ) do
		if not string.find( value, ".dds" ) then
			TEXTURES[key] = GetTextureFilename( value )
		end
	end
end

---[ Private Variables ]---

local EffectList = { }
local EffectTypeList = { }
local ParticleList = { }
local InactiveParticleList = { }
local NumParticles = 0

local CameraWindow
local ParticleWindow

local PlayerX, PlayerY, PlayerZ, PlayerHeading, PlayerVelocity = 0, 0, 0, 0, 0
local CameraX, CameraY, CameraZ, CameraHeading = 0, 0, 0, 0
local OldCameraX, OldCameraY, OldCameraZ, OldCameraHeading = 0, 0, 0, 0
local UpdateEffectsInterval = 1

DsRBeam.Effect.Enabled = true

---[ World Functions ]---

function DsRBeam.World:GetCameraForward()
	if not CameraWindow then return 0, 0, 0 end
	return CameraWindow.CameraControl:Get3DRenderSpaceForward()
end

function DsRBeam.World:GetCameraRight()
	if not CameraWindow then return 0, 0, 0 end
	return CameraWindow.CameraControl:Get3DRenderSpaceRight()
end

function DsRBeam.World:GetCameraUp()
	if not CameraWindow then return 0, 0, 0 end
	return CameraWindow.CameraControl:Get3DRenderSpaceUp()
end

local function DotProduct( v1, v2, v3, w1, w2, w3 )
	return v1 * w1 + v2 * w2 + v3 * w3
end

local function VectorLength( v1, v2, v3 )
	return math.sqrt( DotProduct( v1, v2, v3, v1, v2, v3 ) )
end

local function NormalVector( v1, v2, v3 )
	local c = 1 / math.sqrt( DotProduct( v1, v2, v3, v1, v2, v3 ) )
	return v1 * c, v2 * c, v3 * c
end

local function GetMinPointLineDistance( x, y, z, x1, y1, z1, x2, y2, z2 )
	local v1, v2, v3 = x2 - x1, y2 - y1, z2 - z1
	local w1, w2, w3 = x - x1, y - y1, z - z1

	local c1 = v1 * w1 + v2 * w2 + v3 * w3
	local c2 = v1 * v1 + v2 * v2 + v3 * v3

	local b = c1 / c2
	local lp1, lp2, lp3 = x1 + b * v1, y1 + b * v2, z1 + b * v3

	return zo_distance3D( x, y, z, lp1, lp2, lp3 )
end

local function GetMinReticleDistance( x, y, z )
	return GetMinPointLineDistance( x, y, z, CameraX, CameraY, CameraZ, ReticleVectorX, ReticleVectorY, ReticleVectorZ )
end

local function GetPointPlaneDistance( x, y, z, px1, py1, pz1, px2, py2, pz2, px3, py3, pz3 )
	local pnX = ( py2 - py1 ) * ( pz3 - pz1 ) - ( py3 - py1 ) * ( pz2 - pz1 )
	local pnY = ( pz2 - pz1 ) * ( px3 - px1 ) - ( pz3 - pz1 ) * ( px2 - px1 )
	local pnZ = ( px2 - px1 ) * ( py3 - py1 ) - ( px3 - px1 ) * ( py2 - py1 )
	pnX, pnY, pnZ = NormalVector( pnX, pnY, pnZ )

    local sn = -DotProduct( pnX, pnY, pnZ, px1 - x, py1 - y, pz1 - z )
    local sd = DotProduct( pnX, pnY, pnZ, pnX, pnY, pnZ )
    local sb = sn / sd

	local qx, qy, qz = x + sb * pnX, y + sb * pnY, z + sb * pnZ

    return zo_distance3D( x, y, z, qx, qy, qz ), qx, qy, qz
end

function DsRBeam.World.GetPointPlaneDistance( ... )
	return GetPointPlaneDistance( ... )
end

function DsRBeam.World:Get3DPosition( x, y, z )
	return WorldPositionToGuiRender3DPosition( x, y, z )
end

function DsRBeam.World:GetWorldPosition( x, y, z )
	return GuiRender3DPositionToWorldPosition( x, y, z )
end

function DsRBeam.World.RotateAxisX( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return x	,	y * c - z * s	,	y * s + z * c
end

function DsRBeam.World.RotateAxisY( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return z * s + x * c	,	y	,	z * c - x * s
end

function DsRBeam.World.RotateAxisZ( x, y, z, radians )
	local c, s = math.cos( radians ), math.sin( radians )
	return x * c - y * s	,	x * s + y * c	,	z
end

function DsRBeam.World.Rotate( x, y, z, radX, radY, radZ )
	x, y, z = DsRBeam.World.RotateAxisZ( x, y, z, radZ )
	x, y, z = DsRBeam.World.RotateAxisX( x, y, z, radX )
	x, y, z = DsRBeam.World.RotateAxisY( x, y, z, radY )
	return x, y, z
end

local function GetLinearInterval( cycleMS, offsetMS )
	local frameTime = GetFrameTimeMilliseconds()
	return ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS )
end

local function GetLoopInterval( cycleMS, offsetMS )
	return math.abs( -1 + 2 * GetLinearInterval( cycleMS, offsetMS ) )
end

local function GetEasedInterval( cycleMS, offsetMS )
	local frameTime = GetFrameTimeMilliseconds()
	return math.sin( 2 * math.pi * ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS ) )
end

local function GetEaseInOutInterval( cycleMS, offsetMS )
	local frameTime = GetFrameTimeMilliseconds()
	return math.sin( math.pi * ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS ) )
end

local function GetEaseOutInterval( cycleMS, offsetMS )
	local frameTime = GetFrameTimeMilliseconds()
	return math.sin( 0.5 * math.pi + 0.5 * math.pi * ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS ) )
end

local function GetEaseInInterval( cycleMS, offsetMS )
	local frameTime = GetFrameTimeMilliseconds()
	return math.sin( 0.5 * math.pi * ( ( ( frameTime + ( offsetMS or 0 ) ) % cycleMS ) / cycleMS ) )
end

local function GetIntervalColor( baseR, rangeR, baseG, rangeG, baseB, rangeB, baseA, rangeA, interval, intervalOffset )
	local r, g, b, a, int
	int = GetEasedInterval( interval, intervalOffset )
	r, g, b, a = baseR + rangeR * int, baseG + rangeG * int, baseB + rangeB * int, baseA + rangeA * int
	return r, g, b, a
end

function DsRBeam.World:GetLinearInterval( duration, offset )
	return GetLinearInterval( duration, offset )
end

function DsRBeam.World:GetEasedInterval( duration, offset )
	return GetEasedInterval( duration, offset )
end

---[ Event Handlers ]---

function DsRBeam.World.OnWorldChange()
	EVENT_MANAGER:UnregisterForUpdate( "DsRBeamOnWorldChange" )

	-- Reset 3D Render Spaces

	local win, cc

	win = ParticleWindow
	if nil ~= win then
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()
	end

	win = EffectEditButtonsWindow
	if nil ~= win then
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()
	end

	win = CameraWindow
	if nil == win then
		win = WINDOW_MANAGER:CreateTopLevelWindow( "DsRBeamCameraWin" )
		CameraWindow = win
		win:SetHidden( false )

		cc = WINDOW_MANAGER:CreateControl( "DsRBeamCameraControl", win, CT_TEXTURE )
		cc:SetHidden( true )
		win.CameraControl = cc
	else
		cc = win.CameraControl
	end

	win:Destroy3DRenderSpace()
	win:Create3DRenderSpace()

	cc:Destroy3DRenderSpace()
	cc:Create3DRenderSpace()
	cc:Set3DLocalDimensions( 0.01, 0.01 )

	DsRBeam.ResetAllLights()

	local particles = DsRBeam.Particle:GetAll()
	if particles then
		for _, p in pairs( particles ) do
			p:ResetRenderSpace()
		end
	end

	EVENT_MANAGER:RegisterForUpdate( DsRBeam.Const.AddonName .. "RefreshLights", 1000, DsRBeam.OnRefreshLights )
end

do
	local prevX, prevY, prevZ, prevUpdate

	function DsRBeam.World.OnUpdatePlayerCamera()
		PlayerHeading = GetPlayerCameraHeading()
		CameraHeading = PlayerHeading

		if CameraWindow then
			Set3DRenderSpaceToCurrentCamera( "DsRBeamCameraControl" )
			CameraX, CameraY, CameraZ = DsRBeam.World:GetWorldPosition( CameraWindow.CameraControl:Get3DRenderSpaceOrigin() )
			PlayerX, PlayerY, PlayerZ = CameraX, CameraY, CameraZ
		end
	end
end

do
	local ga = DsRBeam.GlobalAlpha
	local gi1, gi2 = DsRBeam.GlobalInterval1, DsRBeam.GlobalInterval2

	function DsRBeam.World.OnUpdateEffects()
		if 0 >= DsRBeam.GlobalAlpha then
			return
		end

		DsRBeam.World.OnUpdatePlayerCamera()

		local TWO_PI = 2 * math.pi
		local ALPHA_INTERVAL, ALPHA_OFFSET = 4000, 1000
		local ft = GetFrameTimeMilliseconds()

		for index = 1, 4 do
			local gi = GetLinearInterval( gi1 + gi2 * index, 0 )
			DsRBeam.GlobalIntervals[index] = gi

			local ai = ( ( ( ft + ( index * ALPHA_OFFSET ) ) % ALPHA_INTERVAL ) / ALPHA_INTERVAL )
			DsRBeam.GlobalAlphas[index] = math.sin( ai * TWO_PI )
		end

		DsRBeam.EffectAlpha = ga * ( 0.25 + 0.75 * ( DsRBeam.GetSetting( "LightAlpha" ) or 1 ) )

		local effect
		for index = 1, #EffectList do
			effect = EffectList[index]

			if effect and effect.Active and effect.EffectType.Update then
				effect.EffectType.Update( effect )
			end
		end
		
		DsRBeam.GlobalIteration = 1 + ( ( DsRBeam.GlobalIteration + 1 ) % 4 )

		DsRBeam.World.OnReorderParticles()
	end
end

do
	local pX, pY, pZ, pUpX, pUpY, pUpZ, pFwdX, pFwdY, pFwdZ, pRightX, pRightY, pRightZ

	local function ParticleOrderComparer(left, right)
		return left[2] > right[2]
	end

	function DsRBeam.World.OnReorderParticles()
		local cX, cY, cZ = CameraX, CameraY, CameraZ
		local cUpX, cUpY, cUpZ = DsRBeam.World:GetCameraUp()
		local cFwdX, cFwdY, cFwdZ = DsRBeam.World:GetCameraForward()
		local cRightX, cRightY, cRightZ = DsRBeam.World:GetCameraRight()
		local cameraChanged = cX ~= pX or cY ~= pY or cZ ~= pZ or cUpX ~= pUpX or cUpY ~= pUpY or cUpZ ~= pUpZ or cFwdX ~= pFwdX or cFwdY ~= pFwdY or cFwdZ ~= pFwdZ or cRightX ~= pRightX or cRightY ~= pRightY or cRightZ ~= pRightZ
		local p

		pX, pY, pZ = cX, cY, cZ
		pUpX, pUpY, pUpZ = cUpX, cUpY, cUpZ
		pFwdX, pFwdY, pFwdZ = cFwdX, cFwdY, cFwdZ
		pRightX, pRightY, pRightZ = cRightX, cRightY, cRightZ

		local effects = DsRBeam.Effect:GetAll()
		local po = {}

		for index = 1, #effects do
			local e = effects[index]
			if e.Active then
				e.MaxDrawLevel = nil
				local ps = e.Particles
				for index = 1, #ps do
					local p = ps[index]
					local dx, dy, dz = cX - p.X, cY - p.Y, cZ - p.Z
					table.insert(po, {p, math.floor(dx * dx + dy * dy + dz * dz)})
				end
			end
		end
		
		table.sort(po, ParticleOrderComparer)

		local numP = #po
		for index = 1, numP do
			local p = po[index]
			p[1].Texture:SetDrawLevel(index)
		end
	end
end

---[ Particles ]---

local function GetParticleWindow()
	local win = ParticleWindow
	if nil == win then
		win = WINDOW_MANAGER:CreateTopLevelWindow( PARTICLE_PREFIX )
		ParticleWindow = win
		win:SetHidden( false )
		win:SetDimensions( 1, 1 )
		win:SetMovable( true )
		win:SetMouseEnabled( false )
		win:SetClampedToScreen( false )
		win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, -10, -10 )
		win:Create3DRenderSpace()
		win:SetDrawLayer( DL_BACKGROUND )
		win:SetDrawTier( DT_LOW )
	end

	return win
end

function DsRBeam.Particle:GetAll()
	return ParticleList
end

function DsRBeam.Particle:GetInactive()
	return InactiveParticleList
end

function DsRBeam.Particle:GetWindow()
	return ParticleWindow
end

function DsRBeam.Particle:New( ... )
	return self:Initialize( ... )
end

function DsRBeam.Particle:ResetRenderSpace()
	local win = GetParticleWindow()
	local tex = self.Texture

	if not tex then
		tex = WINDOW_MANAGER:CreateControl( nil, win, CT_TEXTURE )
		self.Texture = tex
		tex:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
	end

	local x, y, z = self.X, self.Y, self.Z
	local pitch, yaw, roll = tex:Get3DRenderSpaceOrientation()
	local sizeX, sizeY = tex:Get3DLocalDimensions()
	local usesDepthBuffer = tex:Does3DRenderSpaceUseDepthBuffer()

	tex:Destroy3DRenderSpace()
	tex:Create3DRenderSpace()

	tex:Set3DRenderSpaceOrigin( DsRBeam.World:Get3DPosition( x, y, z ) )
	tex:Set3DRenderSpaceOrientation( pitch or 0, yaw or 0, roll or 0 )
	tex:Set3DLocalDimensions( sizeX or 1, sizeY or 1 )
	tex:Set3DRenderSpaceUsesDepthBuffer( false ~= usesDepthBuffer )
end

function DsRBeam.Particle:Initialize( effect, textureFile )
	local particleIndex
	local inactiveParticle = table.remove( InactiveParticleList, 1 )

	if inactiveParticle then
		self = inactiveParticle
		table.insert( ParticleList, self )
		NumParticles = #ParticleList
		particleIndex = NumParticles

		-- Clear previous particle values.
		for key, value in pairs( self ) do
			if "function" ~= type( value ) and "Texture" ~= key then
				self[key] = nil
			end
		end
	end

	if not particleIndex then
		self = ZO_Object.New( self )
		table.insert( ParticleList, self )
		NumParticles = #ParticleList
		particleIndex = NumParticles
	end

	self.Index, self.EffIndex, self.Active, self.Effect = particleIndex, 1, true, effect
	self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll = 0, 0, 0, 0, 0, 0
	self.SizeX, self.SizeY = 100, 100
	self.OffsetX, self.OffsetY, self.OffsetZ = 0, 0, 0
	self.OffsetPitch, self.OffsetYaw, self.OffsetRoll = 0, 0, 0
	self.OffsetR, self.OffsetG, self.OffsetB, self.OffsetA = 1, 1, 1, 1
	self.OffsetSizeX, self.OffsetSizeY, self.OffsetSizeZ = 1, 1, 1
	self.TCLeft, self.TCRight, self.TCTop, self.TCBottom = 0, 1, 0, 1
	self.TileX1, self.TileX2, self.TileY1, self.TileY2 = nil, nil, nil, nil
	self.SampleRGB, self.SampleAlpha = 1, 0
	self.Alpha, self.Desaturation = 1, 0
	self.AutoDrawLevelEnabled, self.DrawLevelOffset = nil, 0
	self.AutoColorEnabled, self.AutoSizeEnabled = true, true

	local win = GetParticleWindow()
	local tex = self.Texture

	if nil == tex then
		tex = WINDOW_MANAGER:CreateControl( nil, win, CT_TEXTURE )
		self.Texture = tex
		tex:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
	end

	tex:SetHidden( true )
	tex:SetTexture( NIL_TEXTURE )
	tex:SetAnchor( CENTER, win, CENTER, 0, 0 )
	tex:SetAddressMode( TEX_MODE_CLAMP )
	tex:SetBlendMode( TEX_BLEND_MODE_ALPHA )
	tex:SetColor( 1, 1, 1, 1 )
	tex:SetDesaturation( 0 )
	self:SetDrawLevel( 0 )
	self:SetOrientation( 0, 0, 0 )
	self:SetTextureCoords( 0, 1, 0, 1 )
	self:SetSampleProcessing( 1, 0 )
	if not tex:Has3DRenderSpace() then tex:Create3DRenderSpace() end
	tex:Set3DLocalDimensions( 1, 1 )
	tex:SetTexture( textureFile )
	self:SetUseDepthBuffer( true )

	return self
end

function DsRBeam.Particle:Delete()
	if self.Texture then
		if self.Texture:Has3DRenderSpace() then
			self.Texture:Destroy3DRenderSpace()
		end

		self.Texture:SetHidden( true )
		self.Texture:SetTexture( nil )
	end

	for index = 1, #ParticleList do
		if self == ParticleList[index] then
			table.remove( ParticleList, index )
			table.insert( InactiveParticleList, self )
			NumParticles = NumParticles - 1

			break
		end
	end

	self.Active = false
end

function DsRBeam.Particle:GetHidden()
	return self.Texture:IsHidden()
end

function DsRBeam.Particle:SetHidden( isHidden )
	self.Texture:SetHidden( isHidden )
end

function DsRBeam.Particle:GetTextureFile()
	return self.Texture:GetTextureFileName()
end

function DsRBeam.Particle:SetTextureFile( textureFile )
	self.Texture:SetTexture( textureFile )
end

function DsRBeam.Particle:IsTextureLoaded()
	return self.Texture:IsTextureLoaded()
end

function DsRBeam.Particle:GetSampleProcessing()
	return self.SampleRGB, self.SampleAlpha
end

function DsRBeam.Particle:SetSampleProcessing( rgb, alpha )
	self.SampleRGB, self.SampleAlpha = rgb or self.SampleRGB, alpha or self.SampleAlpha
	self.Texture:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, self.SampleRGB )
	self.Texture:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, self.SampleAlpha )
end

function DsRBeam.Particle:SetAutoColorEnabled( enabled )
	self.AutoColorEnabled = enabled
end

function DsRBeam.Particle:GetAutoColorEnabled()
	return self.AutoColorEnabled
end

function DsRBeam.Particle:GetDrawLevel()
	return self.DrawLevelOffset or 0
end

function DsRBeam.Particle:SetDrawLevel( offset )
	self.DrawLevelOffset = offset or 0
	self.Texture:SetDrawLevel( DRAW_LEVEL_EFFECTS + self.DrawLevelOffset )
end

function DsRBeam.Particle:SetAutoDrawLevelEnabled( enabled )
	self.AutoDrawLevelEnabled = enabled
end

do
	local rotate = DsRBeam.World.Rotate

	function DsRBeam.Particle:AutoUpdateDrawLevel( cameraChanged )
		if self.Effect and false ~= self.AutoDrawLevelEnabled and self.Effect:GetAutoDrawLevelEnabled() then
			if not cameraChanged then cameraChanged = self.Dirty end
			self.Dirty = false
			if not cameraChanged then return false end

			local x, y, z = self:GetPosition()
			local pitch, yaw, roll = self:GetOrientation()
			local sizeX, sizeY = self:GetSize()
			local distance, minDistance, viewX, viewY
			local x1, x2, x3, x4, y1, y2, y3, y4, z1, z2, z3, z4

			sizeX, sizeY = 0.5 * sizeX, 0.5 * sizeY
			x1, y1, z1 = -sizeX, -sizeY, 0
			x2, y2, z2 = sizeX, -sizeY, 0
			x3, y3, z3 = -sizeX, sizeY, 0
			x4, y4, z4 = sizeX, sizeY, 0

			x1, y1, z1 = rotate( x1, y1, z1, pitch, yaw, roll )
			x2, y2, z2 = rotate( x2, y2, z2, pitch, yaw, roll )
			x3, y3, z3 = rotate( x3, y3, z3, pitch, yaw, roll )
			x4, y4, z4 = rotate( x4, y4, z4, pitch, yaw, roll )

			x1, y1, z1 = x + x1, y + y1, z + z1
			x2, y2, z2 = x + x2, y + y2, z + z2
			x3, y3, z3 = x + x3, y + y3, z + z3
			x4, y4, z4 = x + x4, y + y4, z + z4

			local minDistance, qx, qy, qz = GetPointPlaneDistance( CameraX, CameraY, CameraZ, x1, y1, z1, x2, y2, z2, x3, y3, z3 )
			distance = zo_clamp( MAX_PARTICLE_DRAW_LEVEL - minDistance + ( self.EffIndex or 0 ), 1, MAX_PARTICLE_DRAW_LEVEL )

			if 1 < self.EffIndex and self.Effect.EffectType.OrderDrawLevelByIndex then
				local pred = self.Effect.Particles[self.EffIndex - 1]
				if pred then
					local predLevel = pred:GetDrawLevel()
					if predLevel and predLevel >= distance then
						distance = predLevel + ( self.Effect.EffectType.ReverseOrderDrawLevel and -1 or 1 )
					end
				end
			end

			self:SetDrawLevel( distance )
			return true
		end

		return nil
	end
end

function DsRBeam.Particle:GetAutoSizeEnabled()
	return self.AutoSizeEnabled
end

function DsRBeam.Particle:SetAutoSizeEnabled( enabled )
	self.AutoSizeEnabled = enabled
end

function DsRBeam.Particle:GetSize()
	local x, y = self.Texture:Get3DLocalDimensions()
	self.SizeX, self.SizeY = self.SizeX or x, self.SizeY or y

	return self.SizeX, self.SizeY
end

function DsRBeam.Particle:SetSize( x, y )
	self.SizeX, self.SizeY = x or self.SizeX, y or self.SizeY
	self.Texture:Set3DLocalDimensions( ( self.SizeX / 100 ), ( self.SizeY / 100 ) )
	self.Dirty = true
end

function DsRBeam.Particle:GetColor()
	local r, g, b, a = self.Texture:GetColor()
	return r, g, b, self.Alpha or a
end

function DsRBeam.Particle:GetAlpha()
	return self.Alpha or self.Texture:GetAlpha()
end

function DsRBeam.Particle:SetAlpha( a )
	self.Alpha = a or self.Alpha
	self.Texture:SetAlpha( self.Alpha )
end

function DsRBeam.Particle:SetColor( r, g, b, a, mix )
	self.Alpha = a or self.Alpha

	if mix then
		local eR, eG, eB, eA = self.Effect:GetColor()
		self.Texture:SetColor( r * eR, g * eG, b * eB, self.Alpha * eA )
	else
		self.Texture:SetColor( r, g, b, self.Alpha )
	end
end

function DsRBeam.Particle:GetAdditive()
	return self.Texture:GetBlendMode() == TEX_BLEND_MODE_ADD
end

function DsRBeam.Particle:SetAdditive( enabled )
	self.Texture:SetBlendMode( enabled and TEX_BLEND_MODE_ADD or TEX_BLEND_MODE_ALPHA )
end

function DsRBeam.Particle:GetDodge()
	return self.Texture:GetBlendMode() == TEX_BLEND_MODE_COLOR_DODGE
end

function DsRBeam.Particle:SetDodge( enabled )
	self.Texture:SetBlendMode( enabled and TEX_BLEND_MODE_COLOR_DODGE or TEX_BLEND_MODE_ALPHA )
end

function DsRBeam.Particle:GetTextureWrapping()
	return self.Texture:GetAddressMode() == TEX_MODE_WRAP
end

function DsRBeam.Particle:SetTextureWrapping( enabled )
	self.Texture:SetAddressMode( enabled and TEX_MODE_WRAP or TEX_MODE_CLAMP )
end

function DsRBeam.Particle:GetUseDepthBuffer()
	self.Texture:Does3DRenderSpaceUseDepthBuffer()
end

function DsRBeam.Particle:SetUseDepthBuffer( buffered )
	self.Texture:Set3DRenderSpaceUsesDepthBuffer( buffered )
end

function DsRBeam.Particle:GetTextureCoords()
	return self.TCLeft or 0, self.TCRight or 1, self.TCTop or 0, self.TCBottom or 1
end

function DsRBeam.Particle:SetTextureCoords( left, right, top, bottom )
	self.TCLeft, self.TCRight, self.TCTop, self.TCBottom = left or self.TCLeft, right or self.TCRight, top or self.TCTop, bottom or self.TCBottom

	if self.Texture:IsTextureLoaded() then
		self.Texture:SetTextureCoords( self.TCLeft, self.TCRight, self.TCTop, self.TCBottom )
	else
		zo_callLater( function() self:SetTextureCoords() end, 600 )
	end
end

function DsRBeam.Particle:GetDesaturation()
	return self.Desaturation
end

function DsRBeam.Particle:SetDesaturation( value )
	self.Desaturation = value or self.Desaturation
	self.Texture:SetDesaturation( self.Desaturation )
end

function DsRBeam.Particle:GetOrientation()
	return self.Texture:Get3DRenderSpaceOrientation()
end

function DsRBeam.Particle:SetOrientation( pitch, yaw, roll )
	self.Pitch, self.Yaw, self.Roll = pitch or self.Pitch, yaw or self.Yaw, roll or self.Roll
	self.Texture:Set3DRenderSpaceOrientation( self.Pitch, self.Yaw, self.Roll )
	self.Dirty = true
end

function DsRBeam.Particle:GetPosition()
	return self.X, self.Y, self.Z
end

function DsRBeam.Particle:SetPosition( x, y, z )
	local baseX, baseY, baseZ = ParticleWindow:Get3DRenderSpaceOrigin()

	self.X, self.Y, self.Z = x or self.X, y or self.Y, z or self.Z
	x, y, z = DsRBeam.World:Get3DPosition( self.X, self.Y, self.Z )
	x, y, z = x - ( baseX or 0 ), y - ( baseY or 0 ), z - ( baseZ or 0 )

	self.Texture:Set3DRenderSpaceOrigin( x, y, z )
	self.Dirty = true
end

function DsRBeam.Particle:GetPositionAndOrientation()
	return self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll
end

function DsRBeam.Particle:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	self:SetOrientation( pitch, yaw, roll )
	self:SetPosition( x, y, z )
end

function DsRBeam.Particle:GetPositionOffsetValues()
	local oX, oY, oZ = self.OffsetX or 0, self.OffsetY or 0, self.OffsetZ or 0
	local sX, sY, sZ = self.Effect.SizeX, self.Effect.SizeY, self.Effect.SizeZ

	if 0 ~= oX and -1 <= oX and 1 >= oX then oX = oX * sX end
	if 0 ~= oY and -1 <= oY and 1 >= oY then oY = oY * sY end
	if 0 ~= oZ and -1 <= oZ and 1 >= oZ then oZ = oZ * sZ end

	return oX, oY, oZ
end

function DsRBeam.Particle:GetOrientationOffsets()
	return self.OffsetPitch, self.OffsetYaw, self.OffsetRoll
end

function DsRBeam.Particle:GetColorOffsets()
	return self.OffsetR, self.OffsetG, self.OffsetB, self.OffsetA
end

function DsRBeam.Particle:GetSizeOffsets()
	return self.OffsetSizeX, self.OffsetSizeY
end

function DsRBeam.Particle:SetOffsets( x, y, z, pitch, yaw, roll, r, g, b, a, sizeX, sizeY )
	self.OffsetX, self.OffsetY, self.OffsetZ = x or self.OffsetX, y or self.OffsetY, z or self.OffsetZ
	self.OffsetPitch, self.OffsetYaw, self.OffsetRoll = pitch or self.OffsetPitch, yaw or self.OffsetYaw, roll or self.OffsetRoll
	self.OffsetR, self.OffsetG, self.OffsetB, self.OffsetA = r or self.OffsetR, g or self.OffsetG, b or self.OffsetB, a or self.OffsetA
	self.OffsetSizeX, self.OffsetSizeY = sizeX or self.OffsetSizeX, sizeY or self.OffsetSizeY
end

function DsRBeam.Particle:SetPositionOffsets( x, y, z )
	self.OffsetX, self.OffsetY, self.OffsetZ = x or self.OffsetX, y or self.OffsetY, z or self.OffsetZ
end

function DsRBeam.Particle:SetOrientationOffsets( pitch, yaw, roll )
	self.OffsetPitch, self.OffsetYaw, self.OffsetRoll = pitch or self.OffsetPitch, yaw or self.OffsetYaw, roll or self.OffsetRoll
end

function DsRBeam.Particle:SetColorOffsets( r, g, b, a )
	self.OffsetR, self.OffsetG, self.OffsetB, self.OffsetA = r or self.OffsetR, g or self.OffsetG, b or self.OffsetB, a or self.OffsetA
end

function DsRBeam.Particle:SetSizeOffsets( sizeX, sizeY )
	self.OffsetSizeX, self.OffsetSizeY = sizeX or self.OffsetSizeX, sizeY or self.OffsetSizeY
end

---[ Effects ]---

function DsRBeam.Effect:ToggleAll()
	self.Enabled = not self.Enabled
	ParticleWindow:SetHidden( not self.Enabled )

	return self.Enabled
end

function DsRBeam.Effect:GetAll()
	return EffectList
end

function DsRBeam.Effect:GetByIndex( index )
	return EffectList[ index ]
end

function DsRBeam.Effect:RegisterOnUpdate()
	EVENT_MANAGER:UnregisterForUpdate( DsRBeam.Const.AddonName .. "UnregisterOnUpdate" )
	EVENT_MANAGER:RegisterForUpdate( EVENT_PREFIX .. "OnUpdate", UpdateEffectsInterval, DsRBeam.World.OnUpdateEffects )
end

function DsRBeam.Effect:UnregisterOnUpdate()
	EVENT_MANAGER:UnregisterForUpdate( EVENT_PREFIX .. "OnUpdate" )
end

function DsRBeam.Effect:New( effectType, index )
	if not DsRBeam.Vars.WarningVideoSettings and tostring( SUB_SAMPLING_MODE_NORMAL ) ~= GetSetting( SETTING_TYPE_GRAPHICS, GRAPHICS_SETTING_SUB_SAMPLING ) then
		DsRBeam.Vars.WarningVideoSettings = true
		DsRBeam.UI.ShowAlertDialog( GetString(DsRGuildBeam_LightShowAlertDialog) )
	end

    local obj = ZO_Object.New( self )
    return obj:Initialize( effectType, index )
end

function DsRBeam.Effect:Initialize( effectType, index )
	if "number" == type( effectType ) then
		local effectTypeId = effectType
		effectType = DsRBeam.EffectType:GetByIndex( effectTypeId )
		if nil == effectType or not effectType.Active then return end
	elseif "string" == type( effectType ) then
		local name = effectType
		effectType = DsRBeam.EffectType:GetByName( name )
		if nil == effectType or not effectType.Active then return end
	end

	if nil == effectType or not effectType.Active then return end

	self.Active, self.Deleted = false, false
	self.EffectType = effectType
	self.AutoColorEnabled, self.AutoDrawLevelEnabled, self.AutoSizeEnabled, self.AutoPositionEnabled, self.AutoOrientationEnabled = true, true, true, true, true
	self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll = 0, 0, 0, 0, 0, 0
	self.ColorR, self.ColorG, self.ColorB, self.ColorA = 1, 1, 1, 1
	self.SizeX, self.SizeY, self.SizeZ = 100, 100, 100
	self.TileX, self.TileY = 0, 0
	self.IsRadiant = false
	self.Particles = { }

	if index and index <= #EffectList then
		self.Index = index
		EffectList[ self.Index ]:Delete( true )
		EffectList[ self.Index ] = self
	elseif not self.Index then
		self.Index = #EffectList + 1
		table.insert( EffectList, self.Index, self )
	end

	if self.EffectType.Init then self.EffectType.Init( self ) end
	zo_callLater( function() self:DeferredInitialization() end, 100 )

	return self
end

function DsRBeam.Effect:DeferredInitialization( timeoutMS )
	if nil == timeoutMS or ( not self:AreParticlesReady() and timeoutMS > GetFrameTimeMilliseconds() ) then
		zo_callLater( function() self:DeferredInitialization( timeoutMS or ( GetFrameTimeMilliseconds() + MAX_PARTICLE_INIT_TIME ) ) end, 200 )
		return
	end

	self.Active = true
	if self.EffectType.OrderDrawLevelByIndex then self.OrderDrawLevelByIndex = true end
	if self.EffectType.Reset then self.EffectType.Reset( self ) end

	zo_callLater( function()
		DsRBeam.Effect:RegisterOnUpdate()
	end, 200 )
end

function DsRBeam.Effect:Delete( quickDelete )
	for index = #self.Particles, 1, -1 do
		self.Particles[ index ]:Delete()
	end

	self.Active = false

	if self.EffectType.Destroy then
		self.EffectType.Destroy( self )
	end

	if not quickDelete then
		for index = 1, #EffectList do
			if EffectList[index] == self then
				table.remove( EffectList, index )
				break
			end
		end
	end

	return true
end

function DsRBeam.Effect:DeleteAll()
	local deleteQueue = { }

	for index, effect in pairs( EffectList ) do
		deleteQueue[ effect ] = true
		effect.Deleted = true
		effect:SetColor( nil, nil, nil, 0.01 )
	end

	zo_callLater( function()
		for effect in pairs( deleteQueue ) do
			effect:Delete( true )
		end

		for index = #EffectList, 1, -1 do
			if deleteQueue[ EffectList[ index ] ] then
				table.remove( EffectList, index )
			end
		end
	end, 2100 )
end

function DsRBeam.Effect:DeleteParticles()
	for index = #self.Particles, 1, -1 do
		self.Particles[ index ]:Delete()
	end

	self.Particles = { }
end

function DsRBeam.Effect:AddParticle( textureFile, offsetX, offsetY, offsetZ, offsetPitch, offsetYaw, offsetRoll, offsetR, offsetG, offsetB, offsetA, offsetSizeX, offsetSizeY, useDepthBuffer, isAdditive, wrapTexture )
	if nil == useDepthBuffer then useDepthBuffer = DsRBeam.GetSetting( "LightAlwaysIgnoresDepthBuffer", false ) end
	if nil == isAdditive then isAdditive = false end

	local p = DsRBeam.Particle:New( self, textureFile )
	local index = #self.Particles + 1
	table.insert( self.Particles, p )

	p.EffIndex = index
	p:SetOffsets( offsetX, offsetY, offsetZ, offsetPitch, offsetYaw, offsetRoll, offsetR, offsetG, offsetB, offsetA, offsetSizeX, offsetSizeY )
	p:SetUseDepthBuffer( useDepthBuffer )
	p:SetAdditive( isAdditive )
	p:SetPositionAndOrientation( self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll )
	if nil ~= wrapTexture then p:SetTextureWrapping( wrapTexture ) end

	return p
end

function DsRBeam.Effect:AreParticlesReady()
	for index = 1, #self.Particles do
		local p = self.Particles[index]
		if p and not p:IsTextureLoaded() then return false end
	end

	return true
end

do
	local resettingEffect

	function DsRBeam.Effect:Reset( ... )
		if self == resettingEffect then return end
		resettingEffect = self

		if self.EffectType.Reset then
			self.EffectType.Reset( self, ... )
		else
			self:Update()
		end

		resettingEffect = nil
	end
end

do
	local isUpdatingEffect = false

	function DsRBeam.Effect:Update()
		if isUpdatingEffect then return end
		isUpdatingEffect = true

		local x, y, z, pitch, yaw, roll = self:GetPositionAndOrientation()
		local offsetYaw = 0 ~= yaw

		self:SetSize()

		if self.AutoPositionEnabled then
			for index = 1, #self.Particles do
				local p = self.Particles[index]
				local offsetX, offsetY, offsetZ = p:GetPositionOffsetValues()
				local offsetPitch, offsetYaw, offsetRoll = p:GetOrientationOffsets()

				if offsetYaw then
					offsetX, offsetZ = offsetZ * math.sin( yaw ) + offsetX * math.cos( yaw ), offsetZ * math.cos( yaw ) - offsetX * math.sin( yaw )
				end

				if self.AutoOrientationEnabled then
					p:SetPositionAndOrientation( x + offsetX, y + offsetY, z + offsetZ, pitch + offsetPitch, yaw + offsetYaw, roll + offsetRoll )
				else
					p:SetPosition( x + offsetX, y + offsetY, z + offsetZ )
				end
			end
		elseif self.AutoOrientationEnabled then
			for index = 1, #self.Particles do
				local p = self.Particles[index]
				local offsetPitch, offsetYaw, offsetRoll = p:GetOrientationOffsets()
				p:SetOrientation( pitch + offsetPitch, yaw + offsetYaw, roll + offsetRoll )
			end
		end

		isUpdatingEffect = false
	end
end

function DsRBeam.Effect:GetEffectType()
	return self.EffectType
end

function DsRBeam.Effect:GetName()
	return self.EffectType.Name
end

function DsRBeam.Effect:GetEffectTypeIndex()
	return self.EffectType.Index
end

function DsRBeam.Effect:GetAutoDrawLevelEnabled()
	return false ~= self.AutoDrawLevelEnabled
end

function DsRBeam.Effect:SetAutoDrawLevelEnabled( enabled )
	if nil == enabled then enabled = true end
	self.AutoDrawLevelEnabled = enabled
end

function DsRBeam.Effect:GetAutoSizeEnabled()
	return self.AutoSizeEnabled
end

function DsRBeam.Effect:SetAutoSizeEnabled( enabled )
	self.AutoSizeEnabled = enabled
end

function DsRBeam.Effect:GetAutoOrientationEnabled()
	return self.AutoOrientationEnabled
end

function DsRBeam.Effect:SetAutoOrientationEnabled( enabled )
	self.AutoOrientationEnabled = enabled
end

function DsRBeam.Effect:GetAutoPositionEnabled()
	return self.AutoPositionEnabled
end

function DsRBeam.Effect:SetAutoPositionEnabled( enabled )
	self.AutoPositionEnabled = enabled
end

function DsRBeam.Effect:GetSize()
	return self.SizeX, self.SizeY, self.SizeZ
end

function DsRBeam.Effect:SetSize( x, y, z )
	if nil ~= x or nil ~= y or nil ~= z then self.LastChanged = GetFrameTimeMilliseconds() end

	local pSizeX, pSizeY, pSizeZ = self.SizeX, self.SizeY, self.SizeZ
	self.SizeX, self.SizeY, self.SizeZ = x or self.SizeX, y or self.SizeY, z or self.SizeZ

	if self:GetAutoSizeEnabled() then
		local offsetX, offsetZ
		for index = 1, #self.Particles do
			p = self.Particles[index]
			if false ~= p:GetAutoSizeEnabled() then
				offsetX, offsetZ = p:GetSizeOffsets()
				p:SetSize( offsetX * self.SizeX, offsetZ * self.SizeZ )
			end
		end
	end

	if self.EffectType.ResetOnScale then
		if pSizeX ~= self.SizeX or pSizeY ~= self.SizeY or pSizeZ ~= self.SizeZ then
			self:Reset()
		end
	end
end

function DsRBeam.Effect:GetColor()
	return self.ColorR, self.ColorG, self.ColorB, self.ColorA
end

function DsRBeam.Effect:GetAutoColorEnabled()
	return self.AutoColorEnabled
end

function DsRBeam.Effect:SetAutoColorEnabled( enabled )
	self.AutoColorEnabled = enabled
end

function DsRBeam.Effect:SetColor( r, g, b, a )
	r, g, b, a = r or self.ColorR or 0, g or self.ColorG or 0, b or self.ColorB or 0, a or self.ColorA or 0

	if r ~= self.ColorR or g ~= self.ColorG or b ~= self.ColorB or a ~= self.ColorA then
		local ft = GetFrameTimeMilliseconds()
		self.LastChanged = ft
		self.LastChangedColor = ft
		self.LastColorR, self.LastColorG, self.LastColorB, self.LastColorA = self.ColorR or 0, self.ColorG or 0, self.ColorB or 0, self.ColorA or 0
		self.ColorR, self.ColorG, self.ColorB, self.ColorA = r, g, b, a
	end

	local offsetR, offsetG, offsetB, offsetA

	if self:GetAutoColorEnabled() then
		for index = 1, #self.Particles do
			p = self.Particles[index]

			if p:GetAutoColorEnabled() then
				offsetR, offsetG, offsetB, offsetA = p:GetColorOffsets()
				p:SetColor( offsetR * self.ColorR, offsetG * self.ColorG, offsetB * self.ColorB, offsetA * self.ColorA )
			end
		end
	end

	if self.EffectType.ResetOnColor then self:Reset() end

	return true
end

function DsRBeam.Effect:SetTextureCoords( left, right, top, bottom )
	local p

	for index = 1, #self.Particles do
		p = self.Particles[index]
		p:SetTextureCoords( left, right, top, bottom )
	end
end

function DsRBeam.Effect:GetOrientation()
	return self.Pitch, self.Yaw, self.Roll
end

local function AdjustEffectOrientation( self, pitch, yaw, roll )
	local pPitch, pYaw, pRoll = self.Pitch, self.Yaw, self.Roll

	if pitch or yaw or roll then self.LastChanged = GetFrameTimeMilliseconds() end

	if pitch then self.Pitch = math.rad( round( math.deg( pitch % RAD360 ), 1 ) ) end
	if yaw then self.Yaw = math.rad( round( math.deg( yaw % RAD360 ), 1 ) ) end
	if roll then self.Roll = math.rad( round( math.deg( roll % RAD360 ), 1 ) ) end

	if 0 ~= self.Pitch and 0 == self.Pitch % RAD90 then self.Pitch = self.Pitch + math.rad( 0.01 ) end
	if 0 ~= self.Roll and 0 == self.Roll % RAD90 then self.Roll = self.Roll + math.rad( 0.01 ) end

	if pPitch ~= self.Pitch or pYaw ~= self.Yaw or pRoll ~= self.Roll then
		self:Update()
		if DsRBeam.PositionItemId == self:GetRecordId() then DsRBeam.UI.RefreshPositionDialog() end
	end
end

local function AdjustEffectPosition( self, x, y, z )
	if x or y or z then self.LastChanged = GetFrameTimeMilliseconds() end

	if x then self.X = round( x ) end
	if y then self.Y = round( y ) end
	if z then self.Z = round( z ) end
end

function DsRBeam.Effect:SetOrientation( pitch, yaw, roll )
	local pPitch, pYaw, pRoll = self.Pitch, self.Yaw, self.Roll

	AdjustEffectOrientation( self, pitch, yaw, roll )
	self:Update()

	if self.EffectType.ResetOnOrient and ( pPitch ~= self.Pitch or pYaw ~= self.Yaw or pRoll ~= self.Roll ) then
		self:Reset()
	end
end

function DsRBeam.Effect:GetPosition()
	return self.X, self.Y, self.Z
end

function DsRBeam.Effect:SetPosition( x, y, z )
	local pX, pY, pZ = self.X, self.Y, self.Z

	AdjustEffectPosition( self, x, y, z )
	self:Update()

	if self.EffectType.ResetOnPosition and ( self.X ~= pX or self.Y ~= pY or self.Z ~= pZ ) then
		self:Reset()
	end
end

function DsRBeam.Effect:GetPositionAndOrientation()
	return self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll
end

function DsRBeam.Effect:SetPositionAndOrientation( x, y, z, pitch, yaw, roll )
	local pX, pY, pZ, pPitch, pYaw, pRoll = self.X, self.Y, self.Z, self.Pitch, self.Yaw, self.Roll

	AdjustEffectPosition( self, x, y, z )
	AdjustEffectOrientation( self, pitch, yaw, roll )
	self:Update()

	if ( self.EffectType.ResetOnPosition and ( pX ~= self.X or pY ~= self.Y or pZ ~= self.Z ) ) or
	   ( self.EffectType.ResetOnOrient and ( pPitch ~= self.Pitch or pYaw ~= self.Yaw or pRoll ~= self.Roll ) ) then
		self:Reset()
	end
end

---[ Effects : User Interface ]---

do
	local showing = true

	function DsRBeam.EffectUI.AreEffectsHidden()
		return not showing
	end

	local function TransitionEffects()
		local w = DsRBeam.Particle:GetWindow()
		local alpha = DsRBeam.GlobalAlpha

		if showing then
			alpha = math.min( 1, alpha + 0.05 )
		else
			alpha = math.max( 0, alpha - 0.05 )
		end

		DsRBeam.GlobalAlpha = alpha

		if showing and 1 <= alpha then
			EVENT_MANAGER:UnregisterForUpdate( "DsRBeam.TransitionEffects" )
		elseif not showing and 0 >= alpha then
			w:SetHidden( true )
			EVENT_MANAGER:UnregisterForUpdate( "DsRBeam.TransitionEffects" )
		end
	end

	function DsRBeam.EffectUI.ShowHideEffects()
		local w = DsRBeam.Particle:GetWindow()
		showing = not showing

		if w then
			if showing then
				DsRBeam.GlobalAlpha = 0
			else
				DsRBeam.GlobalAlpha = 1
			end

			w:SetHidden( false )
			EVENT_MANAGER:RegisterForUpdate( "DsRBeam.TransitionEffects", 30, TransitionEffects )
		end

		DsRBeam.UI.DisplayNotification( string.format( "Light of Togetherness is now %s.", showing and "ON" or "OFF" ) )

		return not showing
	end

	do
		local isUpdating, isToggling = false, false

		function DsRBeam.EffectUI.UpdateObstaclePenetration( enabled )
			if isUpdating then
				return
			end

			isUpdating = true

			if nil == enabled then
				enabled = DsRBeam.GetSetting( "LightAlwaysIgnoresDepthBuffer", false )

				local setting = WINDOW_MANAGER:GetControlByName( "DsRLightAlwaysIgnoresDepthBuffer" )

				if setting and setting.value ~= enabled then
					setting:UpdateValue( false, enabled )
				end
			end

			for index, p in pairs( DsRBeam.Particle:GetAll() ) do
				p:SetUseDepthBuffer( not enabled )
			end

			for index, p in pairs( DsRBeam.Particle:GetInactive() ) do
				p:SetUseDepthBuffer( not enabled )
			end

			isUpdating = false
		end

		function DsRBeam.EffectUI.ToggleObstaclePenetration()
			if isToggling then
				return
			end

			isToggling = true

			local enabled = not DsRBeam.GetSetting( "LightAlwaysIgnoresDepthBuffer", false )

			DsRBeam.SetSetting( "LightAlwaysIgnoresDepthBuffer", enabled )
			DsRBeam.EffectUI.UpdateObstaclePenetration()
			DsRBeam.UI.DisplayNotification( string.format( "Light of Togetherness %s penetrate obstacles.", enabled and "begins to" or "ceases to" ) )

			isToggling = false
		end
	end
end

---[ Effect Type ]---

function DsRBeam.EffectType:GetAll()
	return EffectTypeList
end

function DsRBeam.EffectType:GetByIndex( index )
	return EffectTypeList[index]
end

function DsRBeam.EffectType:GetByName( name )
	local effectType
	name = string.lower( name )

	for index, effectType in pairs( EffectTypeList ) do
		if name == string.lower( effectType.Name ) then
			return effectType
		end
	end

	return nil
end

function DsRBeam.EffectType:New( ... )
	local obj = ZO_Object.New( self )
	obj:Initialize( ... )

	return obj
end

local function EffectTypeFailure( name, msg )
	return string.format( "Effect Type \"%s\" failed to initialize: %s", name or "(nil)", msg or "" )
end

function DsRBeam.EffectType:Initialize( index, name, ... )
	self.Index = index
	self.Name = name

	for key, value in pairs( ... ) do
		self[ key ] = value
	end

	if nil == self.Active then self.Active = true end
	if nil == self.ResetOnPosition then self.ResetOnPosition = false end
	if nil == self.ResetOnOrient then self.ResetOnOrient = false end
	if nil == self.ResetOnScale then self.ResetOnScale = false end
	if nil == self.ResetOnColor then self.ResetOnColor = false end

	EffectTypeList[ index ] = self
end

do
	local globalOffsetY = DsRBeam.GlobalOffsetY

	function DsRBeam.Effect:MoveToPlayer( unitTag )
		if unitTag and "" ~= unitTag then
			local x, y, z = DsRBeam.GetUnitPosition( unitTag )
			self:SetPosition( x, y + globalOffsetY, z )
		end
	end
end

DsRBeam.EffectType:New( 1, "Light of Togetherness", {
	Init = function( self )
		local depthBuffer = not DsRBeam.GetSetting( "LightAlwaysIgnoresDepthBuffer", false )
		local scale = DsRBeam.GetSetting( "LightScale" ) or 1

		self:SetAutoColorEnabled(false)
		self:SetColor( 1, 1, 1, 0 )
		self:SetSize( scale * 250, scale * 250, MAX_BEAM_HEIGHT_CM )
		self:SetOrientation( 0, 0, 0 )

		self:AddParticle( TEXTURES.LIGHT,	0, 0, 30,	0, 0, 0,	1.0, 1.0, 0.7, 0,		1, 1,		depthBuffer, false, true )
		self:AddParticle( TEXTURES.LIGHT,	0, 0, 10,	0, 0, 0,	1.0, 0.7, 1.0, 0,		1, 1,		depthBuffer, false, true )
		self:AddParticle( TEXTURES.LIGHT,	0, 0, -10,	0, 0, 0,	0.7, 1.0, 1.0, 0,		1, 1,		depthBuffer, false, true )
		self:AddParticle( TEXTURES.LIGHT,	0, 0, -30,	0, 0, 0,	0.9, 0.9, 0.9, 0,		1, 1,		depthBuffer, false, true )
		
		for index = 1, 4 do
			self.Particles[index].PositionLerp = zo_lerp(0.05, 0.4, (index - 1) / 3)
		end
	end,

	Update = function( self )
		local ga, ps, np = DsRBeam.EffectAlpha, self.Particles, #self.Particles
		local R, G, B, A = self:GetColor()
		local ft = GetFrameTimeMilliseconds()

		if 0 == A then
			for index = 1, np do
				ps[index]:SetHidden( true )
			end
		else
			if self.LastChangedColor then
				local elapsed = ft - self.LastChangedColor
				local progress = elapsed / 1400

				if 1 < progress then
					progress = 1
					self.LastChangedColor = nil
				end

				R, G, B, A =
					round( zo_lerp( self.LastColorR or 0, R, progress ), 4 ),
					round( zo_lerp( self.LastColorG or 0, G, progress ), 4 ),
					round( zo_lerp( self.LastColorB or 0, B, progress ), 4 ),
					round( zo_lerp( self.LastColorA or 0, A, progress ), 4 )
			end

			local ints = DsRBeam.GlobalIntervals
			local radiance = 1 * ( self.IsRadiant and 3 or 1.5 )
			local TC = 0.1

			for index = 1, np do
				local p = ps[index]
				local i = ints[index]
				local ai = DsRBeam.GlobalAlphas[index]
				local tco = TC * ai

				if 1 == index then
					p:SetTextureCoords( -TC + tco, 1 + tco, 0.2 + i, 8.2 + i )
				elseif 2 == index then
					p:SetTextureCoords( 1 + tco, -TC + tco, 5 + i, i )
				elseif 3 == index then
					p:SetTextureCoords( 0.05 - tco, .95 + TC - tco, 0.5 + i, 7.5 + i )
				else
					p:SetTextureCoords( 0.9 + TC + tco, 0.05 - TC + tco, 4.8 + i, 0.8 + i )
				end

				local r, g, b, a = p.OffsetR * R, p.OffsetG * G, p.OffsetB * B, (1 + 0.5 * ai) * ga * A
				--p.Texture:SetVertexColors( 1 + 2, r, g, b, ( 0 == ( index % 2 ) ) and a or ( A - a ) )
				p.Texture:SetVertexColors( 1 + 2, r, g, b, a )
				p.Texture:SetVertexColors( 4 + 8, r, g, b, 0 )
				p:SetSampleProcessing( 0.5 + radiance, 0 ) -- ( 0.5 + radiance * math.sin( i * math.pi ) ), 0 )

				p.OffsetZ = -30 + (index - 1) * 20
				p:SetHidden( false )
			end
			
			local _, forwardY, _ = DsRBeam.World:GetCameraForward()
			self.Pitch = BASE_TILT_PITCH + math.abs(forwardY) * MAX_TILT_PITCH
			self.Yaw = PlayerHeading

			self:MoveToPlayer( self.UnitTag )
		end
	end,
} )
