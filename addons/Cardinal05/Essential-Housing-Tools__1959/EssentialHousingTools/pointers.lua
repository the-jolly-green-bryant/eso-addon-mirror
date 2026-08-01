if not EHT then EHT = { } end
if not EHT.Pointers then EHT.Pointers = { } end

local RAD45, RAD90 = math.rad( 45 ), math.rad( 90 )

------[[ "Constants" & Variables ]]------

EHT.CONST.POINTER = { }
EHT.CONST.POINTER.SELECTED = 1
EHT.CONST.POINTER.SELECTED_2 = 2
EHT.CONST.POINTER.SELECT = 3
EHT.CONST.POINTER.SELECT_RADIUS = 4
EHT.CONST.POINTER.SELECT_RADIUS_2 = 5
EHT.CONST.POINTER.BUILD = 6

EHT.CONST.MAX_GROUPED = 700
EHT.CONST.MAX_LOCKED = 700

local GLOW_MIN = 0.1
local GLOW_MAX = 0.3

local MILLISECONDS_PER_COLOR_CYCLE = 9000
local MILLISECONDS_PER_GLOW_CYCLE = 3000
local MILLISECONDS_PER_ROTATION = 4500
local MILLISECONDS_PER_SCALE_CYCLE = 800

local POINTER_UPDATE = EHT.ADDON_NAME .. "PointerUpdate"
local POINTER_UPDATE_TIMER = 10
local POINTER_SCALE = 40

local GROUPED_UPDATE = EHT.ADDON_NAME .. "GroupedUpdate"
local GROUPED_UPDATE_TIMER = 50
local GROUPED_SCALE = 40

local LOCKED_UPDATE = EHT.ADDON_NAME .. "LockedUpdate"
local LOCKED_UPDATE_TIMER = 50
local LOCKED_SCALE = 40

local INDICATOR_UPDATE = EHT.ADDON_NAME .. "IndicatorUpdate"
local INDICATOR_UPDATE_TIMER = 50

local GROUP_OUTLINE_UPDATE = EHT.ADDON_NAME .. "GroupOutlineUpdate"
local GROUP_OUTLINE_UPDATE_TIMER = 50

local GUIDELINES_UPDATE = EHT.ADDON_NAME .. "GuidelinesUpdate"
local GUIDELINES_UPDATE_TIMER = 50
local GUIDELINES_RADIUS_MAX = 40
local GUIDELINES_DIM_X = 64
local GUIDELINES_DIM_Z = 2
local GUIDELINES_LOCAL_WIDTH = 1
local GUIDELINES_LOCAL_HEIGHT = 0.05
local GUIDELINES_PLAYER_OFFSET_Y = 5
local GUIDELINES_HIGHLIGHT_HEIGHT = 100
local GUIDELINES_HIGHLIGHT_MIN_ALPHA = 0.1
local GUIDELINES_HIGHLIGHT_MAX_ALPHA = 1.0

GuidelinesState = {
	CurrentX = 0,
	CurrentY = 0,
	CurrentZ = 0,

	LockedX = 0,
	LockedY = 0,
	LockedZ = 0,
}

---[ Operations : Utility ]---

local function GetIntervals()
	local ft = GetFrameTimeMilliseconds()
	local colorInterval = math.sin( 2 * math.pi * ( ( ft % MILLISECONDS_PER_COLOR_CYCLE ) / MILLISECONDS_PER_COLOR_CYCLE ) )
	local rotationInterval = 2 * math.pi * ( ( ft % MILLISECONDS_PER_ROTATION ) / MILLISECONDS_PER_ROTATION )
	local easedInterval = math.sin( math.pi * ( ( ft % MILLISECONDS_PER_COLOR_CYCLE ) / MILLISECONDS_PER_COLOR_CYCLE ) )
	local glowInterval = GLOW_MIN + ( GLOW_MAX - GLOW_MIN ) * math.sin( math.pi * ( ( ft % MILLISECONDS_PER_GLOW_CYCLE ) / MILLISECONDS_PER_GLOW_CYCLE ) )

	return colorInterval, rotationInterval, easedInterval, glowInterval
end

function EHT.Pointers.InterpolatePlanarPoint( pointX, pointY, pointZ, originX, originY, originZ, units, angle )
	local tX, tY, tZ = pointX - originX, pointY - originY, pointZ - originZ
	local mX, mY, mZ = tX % units, tY % units, tZ % units
	local x, y, z = pointX - mX, pointY, pointZ - mZ

	return x, pointY, z
end

---[ Operations : Event Handlers ]---

function EHT.Pointers.OnWorldChange()
	if 0 ~= GetCurrentZoneHouseId() then
		EHT.Pointers.CreateGroupOutline( true )
		EHT.Pointers.CreateGrouped( true )
		EHT.Pointers.InitLocked( true )
		EHT.Pointers.InitIndicators( true )
		EHT.Pointers.CreatePointers( true )
		EHT.Pointers.CreateGuidelines( true )
	else
		EHT.Pointers.ClearGroupOutline()
		EHT.Pointers.RetainGroupedSet()
		EHT.Pointers.ClearLocked()
		EHT.Pointers.ClearIndicators()
		EHT.Pointers.ClearPointers()
		EHT.Pointers.ClearGuidelines()
	end
end

---[ Operations : Functional Pointers ]---

function EHT.Pointers.CreatePointer( pIndex, pName, textureFile, rotates, glows, rotation, scaleWidth, scaleHeight, pitch, roll )
	local ui = EHT.UI.Pointers
	if nil == ui then return end

	rotation, scaleWidth, scaleHeight = rotation or 0, scaleWidth or 1, scaleHeight or 1
	pitch, roll = pitch or 0, roll or 0

	local win = ui.Window
	local p = WINDOW_MANAGER:CreateControl( pName, win, CT_TEXTURE )
	ui.Pointers[ pIndex ] = p
	p.Rotates = rotates
	p.Glows = glows

	p:SetAnchor( CENTER, win, CENTER, 0, 0 )
	p:SetTexture( textureFile )
	p:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
	p:SetTextureCoordsRotation( rotation )
	p:SetBlendMode( TEX_BLEND_MODE_ADD )
	p:SetHidden( false )

	local width, height = p:GetTextureFileDimensions()
	if math.rad( 90 ) == rotation or math.rad( 270 ) == rotation then width, height = height, width end
	p.LocalWidth, p.LocalHeight = width / width, height / width
	p.ScaleWidth, p.ScaleHeight, p.Pitch, p.Roll = scaleWidth, scaleHeight, pitch, roll
	p:SetDimensions( width, height )

	return p
end

function EHT.Pointers.CreatePointers( worldChanged )
	local ui = EHT.UI.Pointers
	if not ui then
		ui = { }
		EHT.UI.Pointers = ui
		ui.Pointers = { }
		local prefix = "EHTPointers"

		-- Top-Level Window

		local win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetHidden( false )
		win:SetAnchor( TOPLEFT, GuiRoot, CENTER, 0, 0 )

		-- Controls

		do
			EHT.Pointers.CreatePointer(
				EHT.CONST.POINTER.SELECTED,
				prefix .. "PointerSelected",
				EHT.Textures.ICON_PIN,
				true, true,
				0, 0.5, 0.5, 0, 0 )

			EHT.Pointers.CreatePointer(
				EHT.CONST.POINTER.SELECTED_2,
				prefix .. "PointerSelected2",
				EHT.Textures.ICON_PIN,
				true, true,
				0, 0.5, 0.5, 0, 0 )

			EHT.Pointers.CreatePointer(
				EHT.CONST.POINTER.SELECT,
				prefix .. "PointerSelecting",
				EHT.Textures.ICON_PIN,
				true, true,
				0, 1, 1, 0, 0 )

			EHT.Pointers.CreatePointer(
				EHT.CONST.POINTER.SELECT_RADIUS,
				prefix .. "PointerSelectRadius",
				EHT.Textures.CIRCLE_SOFT,
				false, false,
				0, 1, 1, math.rad( 90 ), 0 )

			EHT.Pointers.CreatePointer(
				EHT.CONST.POINTER.SELECT_RADIUS_2,
				prefix .. "PointerSelectRadius2",
				EHT.Textures.CIRCLE_SOFT,
				false, false,
				0, 1, 1, math.rad( 90 ), 0 )

			do
				local p = EHT.Pointers.CreatePointer(
					EHT.CONST.POINTER.BUILD,
					prefix .. "PointerBuild",
					EHT.Textures.ICON_BUILD,
					true, true,
					0, 0.5, 0.5, 0, 0 )
				p:SetColor( 0, 1, 1, 0.5 )
			end
		end

		ui.Sphere = { }
		for index = 1, 3 do
			local p = WINDOW_MANAGER:CreateControl( string.format( "%s%s%d", prefix, "PointerSphere", index ), win, CT_TEXTURE )
			ui.Sphere[ index ] = p
			p:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			p:SetAnchor( CENTER, win, CENTER, 0, 0 )
			p:SetTexture( EHT.Textures.CIRCLE_AXIS )
			p:SetHidden( false )
			p:SetDimensions( 1, 1 )
			p:SetTextureCoordsRotation( 0 )
			p:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		end

		ui.Sphere[1]:SetTextureCoords( 0, 0.5, 0, 0.5 )
		ui.Sphere[2]:SetTextureCoords( 0.501, 1, 0, 0.5 )
		ui.Sphere[3]:SetTextureCoords( 0, 0.5, 0.501, 1 )
	end

	if worldChanged then
		-- Initialize 3D Render Spaces
		local win = ui.Window
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()

		for _, pIndex in pairs( EHT.CONST.POINTER ) do
			local p = ui.Pointers[ pIndex ]
			if p then
				p:Destroy3DRenderSpace()
				p:Create3DRenderSpace()
				p:Set3DLocalDimensions( p.LocalWidth, p.LocalHeight )
				p:SetHidden( true )
			end
		end

		for index, p in ipairs( ui.Sphere ) do
			p:Destroy3DRenderSpace()
			p:Create3DRenderSpace()
			p:Set3DLocalDimensions( 1, 1 )
			p:SetHidden( true )
			p:Set3DRenderSpaceUsesDepthBuffer( true )
			p:SetDrawLevel( 10003 - index )
		end

		ui.Sphere[1]:Set3DRenderSpaceOrientation( 0, 0, 0 )
		ui.Sphere[2]:Set3DRenderSpaceOrientation( 0, 0.5 * math.pi, 0 )
		ui.Sphere[3]:Set3DRenderSpaceOrientation( 0.5 * math.pi, 0, 0 )
	end

	return ui.Pointers
end

function EHT.Pointers.InitLocked( worldChanged )
	local ui = EHT.UI.Locked
	if not ui then
		ui = { }
		EHT.UI.Locked = ui
		ui.Indicators = {}
		ui.IndicatorIndex = 0

		-- Top-Level Window
		local win = WINDOW_MANAGER:CreateTopLevelWindow( "EHTLocked" )
		ui.Window = win
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetHidden( false )
		win:SetAnchor( TOPLEFT, GuiRoot, CENTER, 0, 0 )
	end

	if worldChanged then
		-- Initialize 3D Render Spaces
		local win = ui.Window
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()

		for index = 1, #ui.Indicators do
			local indicator = ui.Indicators[ index ]
			if indicator then
				indicator:Destroy3DRenderSpace()
				indicator:Create3DRenderSpace()
				indicator:SetHidden( true )
			end
		end

		ui.IndicatorIndex = 0
	end

	return ui.Indicators, ui
end

function EHT.Pointers.AcquireLockedIndicator()
	local ui = EHT.UI.Locked
	if not ui then
		return
	end

	local index = ui.IndicatorIndex + 1
	ui.IndicatorIndex = index

	local indicator = ui.Indicators[ index ]
	if not indicator then
		indicator = WINDOW_MANAGER:CreateControl( "EHTLocked" .. tostring( index ), ui.Window, CT_TEXTURE )
		ui.Indicators[ index ] = indicator
		indicator:SetHidden( true )
		indicator:SetAnchor( CENTER, ui.Window, CENTER, 0, 0 )
		indicator:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		indicator:SetColor( 1, 1, 1, 1 )
		indicator:SetTexture( EHT.Textures.ICON_LOCK )
		indicator:SetTextureCoordsRotation( 0 )

		local width, height = indicator:GetTextureFileDimensions()
		indicator:SetDimensions( width, height )
		indicator.LocalWidth, indicator.LocalHeight = 1, height / width

		indicator:Create3DRenderSpace()
		indicator:Set3DLocalDimensions( indicator.LocalWidth, indicator.LocalHeight )
	end

	return indicator, ui
end

function EHT.Pointers.InitIndicators( worldChanged )
	local ui = EHT.UI.Indicators
	if not ui then
		ui = { }
		EHT.UI.Indicators = ui
		ui.IndicatorIndex = 0

		-- Top-Level Window
		local win = WINDOW_MANAGER:CreateTopLevelWindow( "EHTIndicators" )
		ui.Window = win
		win:SetHidden( false )
		win:SetMovable( false )
		win:SetMouseEnabled( false )
		win:SetClampedToScreen( false )
		win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, 0, 0 )
		win:SetDimensions( 0, 0 )
	end

	if worldChanged then
		-- Initialize 3D Render Spaces
		local win = ui.Window
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()

		for index, indicator in ipairs( ui ) do
			indicator:Destroy3DRenderSpace()
			indicator:Create3DRenderSpace()
			indicator:SetHidden( true )
		end

		ui.IndicatorIndex = 0
	end

	return ui
end

function EHT.Pointers.AcquireIndicator()
	local ui = EHT.UI.Indicators
	if not ui then
		return
	end

	local index = ui.IndicatorIndex + 1
	ui.IndicatorIndex = index

	local indicator = ui[ index ]
	if not indicator then
		indicator = WINDOW_MANAGER:CreateControl( "EHTIndicators" .. tostring( index ), ui.Window, CT_TEXTURE )
		ui[ index ] = indicator
		indicator:SetTexture( EHT.Textures.ICON_BUILD_GLOW )
		indicator:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
		indicator:SetDrawLevel( 205000 )

		if 0 == index % 3 then
			indicator:SetColor( 1, 1, 0, 1 )
		elseif 1 == index % 3 then
			indicator:SetColor( 0, 1, 1, 1 )
		else
			indicator:SetColor( 1, 0, 1, 1 )
		end

		local width, height = indicator:GetTextureFileDimensions()
		indicator.LocalWidth, indicator.LocalHeight = 1, height / width
		indicator:Create3DRenderSpace()
		indicator:Set3DLocalDimensions( indicator.LocalWidth, indicator.LocalHeight )
	end

	return indicator, ui
end

function EHT.Pointers.ClearPointer( pIndex )
	local ui = EHT.UI.Pointers
	if not ui then return true end

	local pointers = ui.Pointers
	if not pointers then return false end

	if nil == pIndex then pIndex = EHT.CONST.POINTER.SELECT end
	local p = pointers[ pIndex ]
	if not p then return false end

	p:SetHidden( true )
	return true
end

function EHT.Pointers.ClearSphere()
	local ui = EHT.UI.Pointers
	if not ui or not ui.Sphere then return true end

	for index, p in ipairs( ui.Sphere ) do
		p:SetHidden( true )
	end
end

function EHT.Pointers.ClearSelected() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.SELECTED ) end
function EHT.Pointers.ClearSelected2() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.SELECTED_2 ) end
function EHT.Pointers.ClearSelect() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.SELECT ) end
function EHT.Pointers.ClearSelectRadius() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.SELECT_RADIUS ) end
function EHT.Pointers.ClearSelectRadius2() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.SELECT_RADIUS_2 ) end
function EHT.Pointers.ClearBuild() return EHT.Pointers.ClearPointer( EHT.CONST.POINTER.BUILD ) end

function EHT.Pointers.ClearPointers()
	if nil == EHT.UI.Pointers then return true end

	local pointers = EHT.Pointers.CreatePointers()
	if nil == pointers then return false end

	for _, p in pairs( pointers ) do
		p:SetHidden( true )
	end

	EHT.Pointers.ClearSphere()

	return true
end

function EHT.Pointers.ClearLocked()
	local ui = EHT.UI.Locked
	if not ui then return end

	local indicators = ui.Indicators
	if not indicators then return end

	for index = 1, ui.IndicatorIndex do
		indicators[ index ]:SetHidden( true )
	end

	ui.IndicatorIndex = 0
end

function EHT.Pointers.ClearIndicators()
	local ui = EHT.UI.Indicators
	if not ui then return end

	local indicatorIndex = ui.IndicatorIndex
	for index = 1, indicatorIndex do
		ui[ index ]:SetHidden( true )
	end

	ui.IndicatorIndex = 0
end

function EHT.Pointers.SetPointer( pIndex, x, y, z, scale, colorR, colorG, colorB, colorA, pitch, yaw, roll )
	local pointers = EHT.Pointers.CreatePointers()

	if nil == pIndex then pIndex = EHT.CONST.POINTER.SELECT end
	local p = pointers[ pIndex ]

	-- Invalid pointer argument.
	if nil == p then return false end

	if nil == x or nil == y or nil == z then x, y, z = GetPlayerWorldPositionInHouse() end
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )

	pitch, yaw, roll = pitch or 0, yaw or 0, roll or 0

	if pIndex == EHT.CONST.POINTER.SELECT_RADIUS or pIndex == EHT.CONST.POINTER.SELECT_RADIUS_2 then
		pitch, roll = math.rad( 90 ), 0
		p:Set3DLocalDimensions( scale + 0.2, scale + 0.2 )
	end

	p.Scale = scale or 1
	p.ColorR, p.ColorG, p.ColorB = colorR, colorG, colorB
	p:SetColor( p.ColorR or 1, p.ColorG or 1, p.ColorB or 1, 0.8 )
	p:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	p:Set3DRenderSpaceOrientation( pitch, yaw, roll )
	p:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( POINTER_UPDATE, POINTER_UPDATE_TIMER, EHT.Pointers.OnPointerUpdate )
	return true
end

function EHT.Pointers.SetSphere( radius,		x, y, z,		r, g, b, a )
	local pointers = EHT.Pointers.CreatePointers()
	local sphere = EHT.UI.Pointers.Sphere
	if not sphere then return false end

	x, y, z = EHT.World:Get3DPosition( x, y, z )

	for index, p in ipairs( sphere ) do
		p:SetColor( r, g, b, a )
		p:Set3DLocalDimensions( 2 * radius, 2 * radius )
		p:Set3DRenderSpaceOrigin( x, y, z )
		p:SetHidden( false )
	end

	EVENT_MANAGER:RegisterForUpdate( POINTER_UPDATE, POINTER_UPDATE_TIMER, EHT.Pointers.OnPointerUpdate )
	return true
end

function EHT.Pointers.SetSelected( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.SELECTED, ... ) end
function EHT.Pointers.SetSelected2( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.SELECTED_2, ... ) end
function EHT.Pointers.SetSelectRadius( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.SELECT_RADIUS, ... ) end
function EHT.Pointers.SetSelectRadius2( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.SELECT_RADIUS_2, ... ) end
function EHT.Pointers.SetSelect( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.SELECT, ... ) end
function EHT.Pointers.SetBuild( ... ) return EHT.Pointers.SetPointer( EHT.CONST.POINTER.BUILD, ... ) end

function EHT.Pointers.SetLockedHidden( hidden )
	local ui = EHT.UI.Locked
	if not ui then return end

	local indicators = ui.Indicators
	if not indicators then return end

	local indicatorIndex = ui.IndicatorIndex
	for i = 1, indicatorIndex do
		indicators[ i ]:SetHidden( hidden )
	end

	if hidden then
		EVENT_MANAGER:UnregisterForUpdate( LOCKED_UPDATE, EHT.Pointers.OnLockedUpdate )
	else
		EVENT_MANAGER:RegisterForUpdate( LOCKED_UPDATE, LOCKED_UPDATE_TIMER, EHT.Pointers.OnLockedUpdate )
	end
end

function EHT.Pointers.SetLocked( x, y, z, dimX, dimY, dimZ )
	if nil == x or nil == y or nil == z then return false end

	local indicator, ui = EHT.Pointers.AcquireLockedIndicator()
	if not indicator then return false end

	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( 0, 0 )

	local editorMode = GetHousingEditorMode()
	if editorMode == HOUSING_EDITOR_MODE_SELECTION or editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
		indicator:SetHidden( false )
	end

	EVENT_MANAGER:RegisterForUpdate( LOCKED_UPDATE, LOCKED_UPDATE_TIMER, EHT.Pointers.OnLockedUpdate )
	return true
end

function EHT.Pointers.SetIndicatorsHidden( hidden )
	local ui = EHT.UI.Indicators
	if not ui then return end

	local indicatorIndex = ui.IndicatorIndex
	for i = 1, indicatorIndex do
		ui[ i ]:SetHidden( hidden )
	end

	if hidden then
		EVENT_MANAGER:UnregisterForUpdate( INDICATOR_UPDATE )
	else
		EVENT_MANAGER:RegisterForUpdate( INDICATOR_UPDATE, INDICATOR_UPDATE_TIMER, EHT.Pointers.OnIndicatorsUpdate )
	end
end

function EHT.Pointers.SetIndicator( x, y, z )
	if not x then return false end

	local indicator = EHT.Pointers.AcquireIndicator()
	if not indicator then return false end

	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:SetHidden( false )

	EVENT_MANAGER:RegisterForUpdate( INDICATOR_UPDATE, INDICATOR_UPDATE_TIMER, EHT.Pointers.OnIndicatorsUpdate )
	return true
end

function EHT.Pointers.OnPointerUpdate()
	local unregister = true
	local pointers = EHT.UI.Pointers

	if nil ~= pointers then
		local globalColor, globalYaw, _, glow = GetIntervals()
		globalYaw = ( globalYaw + math.rad( 90 ) ) % math.rad( 360 )
		local pitch, yaw, roll = 0, 0, 0
		local sp = pointers.Sphere

		if not sp[1]:IsHidden() then
			unregister = false

			local pX, pY, pZ = GetPlayerWorldPositionInHouse()
			local sX, sY, sZ = EHT.World:GetWorldPosition( sp[1]:Get3DRenderSpaceOrigin() )
			local camDirection = 0
			if math.abs( pX - sX ) > math.abs( pZ - sZ ) then camDirection = 100 end

			sp[1]:SetDrawLevel( 210100 + camDirection )
			sp[2]:SetDrawLevel( 210100 + ( 100 - camDirection ) )
			sp[3]:SetDrawLevel( 210000 )

			if pX >= sX then
				sp[2]:SetTextureCoords( 0.5, 1, 0, 0.5 )
			else
				sp[2]:SetTextureCoords( 1, 0.5, 0, 0.5 )
			end
		end

		for index = 1, #pointers.Pointers do
			local p = pointers.Pointers[ index ]

			if not p:IsHidden() then
				unregister = false

				if index ~= EHT.CONST.POINTER.SELECT_RADIUS and index ~= EHT.CONST.POINTER.SELECT_RADIUS_2 then
					local x, y, z = EHT.World:GetWorldPosition( p:Get3DRenderSpaceOrigin() )
					p:Set3DRenderSpaceOrientation( EHT.World:GetCameraFacingOrientation() )
					p:Set3DLocalDimensions( EHT.World:GetUIIndicatorDimensions( x, y, z, p.Scale ) )
				end

				if p.Glows then
					if p.ColorR and p.ColorG and p.ColorB then
						p:SetColor( p.ColorR * math.abs( globalColor ), p.ColorG * math.abs( globalColor ), p.ColorB * math.abs( globalColor ), 0.8 ) -- 1 == index and 0.9 or globalAlpha )
					else
						p:SetColor( 0, 0.25 + ( globalColor * 0.5 ), 1, 0.8 ) -- globalAlpha )
					end

					p:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, glow )
				end
			end
		end
	end

	if unregister then
		EVENT_MANAGER:UnregisterForUpdate( POINTER_UPDATE, EHT.Pointers.OnPointerUpdate )
		return
	end
end

function EHT.Pointers.OnLockedUpdate()
	local ui = EHT.UI.Locked
	if nil == ui then return end

	local indicators = ui.Indicators
	if nil == indicators then return end

	local indicator, indicatorIndex = nil, ui.IndicatorIndex or 0
	if 0 < indicatorIndex then
		local globalColor, globalYaw, _, _, scale = GetIntervals()
		local globalAlpha = EHT.SavedVars.SelectionIndicatorAlpha
		globalColor = globalColor * 0.5
		globalYaw = globalYaw or 0
		scale = scale or 1

		for i = 1, indicatorIndex do
			indicator = indicators[ i ]
			if nil ~= indicator and not indicator:IsHidden() then
				local x, y, z = EHT.World:GetWorldPosition( indicator:Get3DRenderSpaceOrigin() )
				indicator:Set3DRenderSpaceOrientation( EHT.World:GetCameraFacingOrientation() )
				indicator:Set3DLocalDimensions( EHT.World:GetUIIndicatorDimensions( x, y, z ) )
				indicator:SetColor( 1, globalColor, 0, globalAlpha )
				indicator:SetDrawLevel( 205000 )
			end
		end
	end

	if 0 >= indicatorIndex then
		EVENT_MANAGER:UnregisterForUpdate( LOCKED_UPDATE, EHT.Pointers.OnLockedUpdate )
	end
end

function EHT.Pointers.OnIndicatorsUpdate()
	local ui = EHT.UI.Indicators
	if not ui then
		EVENT_MANAGER:UnregisterForUpdate( INDICATOR_UPDATE )
		return
	end

	local indicatorIndex = ui.IndicatorIndex
	if 0 < indicatorIndex then
		local globalAlpha = EHT.SavedVars.SelectionIndicatorAlpha
		local sampling = 1 + 2 * math.abs( -1 + ( ( GetFrameTimeMilliseconds() % 2500 ) / 1250 ) )
		for i = 1, indicatorIndex do
			local indicator = ui[ i ]
			if indicator then
				indicator:Set3DLocalDimensions( EHT.World:GetUIIndicatorDimensions( EHT.World:GetWorldPosition( indicator:Get3DRenderSpaceOrigin() ) ) )
				indicator:Set3DRenderSpaceOrientation( EHT.World:GetCameraFacingOrientation() )
				indicator:SetAlpha( globalAlpha )
				indicator:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, sampling )
			end
		end
	else
		EVENT_MANAGER:UnregisterForUpdate( INDICATOR_UPDATE )
	end
end

---[ Operations : Selection Indicators ]---

do
	local groupedHidden = false

	local function CreateControl( control )
		control:SetAnchor( CENTER, win, CENTER, 0, 0 )
		control:SetTexture( groupedTexture )
		control:SetColor( 1, 1, 1, 1 )
		control:SetBlendMode( TEX_BLEND_MODE_ALPHA )
		control:Destroy3DRenderSpace()
		control:Create3DRenderSpace()
		control:Set3DLocalDimensions( 0, 0 )
	end

	local function ResetControl( control )
		control:SetTexture( groupedTexture )
		control:Destroy3DRenderSpace()
		control:Create3DRenderSpace()
		control:Set3DLocalDimensions( 0, 0 )
		control.TexFile, control.X, control.Y, control.Z = nil, nil, nil, nil
	end

	local function DestroyControl( pool, control, id )
		control:SetHidden( true )
		control:Destroy3DRenderSpace()
		control:SetTexture( "" )
		pool:ReleaseObject( id )
	end

	function EHT.Pointers.CreateGrouped( worldChanged )
		local ui = EHT.UI.Grouped
		if nil == ui then
			ui = { }
			EHT.UI.Grouped = ui

			local prefix = "EHTGrouped"
			local p, win

			win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
			ui.Window = win
			win:SetMovable( true )
			win:SetMouseEnabled( true )
			win:SetClampedToScreen( true )
			win:SetHidden( false )
			win:SetAnchor( TOPLEFT, GuiRoot, CENTER, 0, 0 )
			win:Destroy3DRenderSpace()
			win:Create3DRenderSpace()

			ui.Indicators = EHT.ControlPool:New( CT_TEXTURE, win, CreateControl, ResetControl )
		end

		if worldChanged then
			ui.Window:Destroy3DRenderSpace()
			ui.Window:Create3DRenderSpace()
		end

		return ui.Indicators, ui
	end

	function EHT.Pointers.SetGroupedHidden( hidden )
		local ui = EHT.UI.Grouped
		if nil == ui then return end

		local indicators = ui.Indicators
		if nil == indicators then return end
		indicators = indicators:GetActiveObjects()

		if not hidden and not EHT.Biz.AreSelectionIndicatorsEnabled() then hidden = true end

		if hidden then
			for _, indicator in pairs( indicators ) do
				indicator:SetHidden( true )
			end

			EVENT_MANAGER:UnregisterForUpdate( GROUPED_UPDATE, EHT.Pointers.OnGroupedUpdate )
		else
			EHT.UI.QueueRefreshGroupedIndicators()

			EVENT_MANAGER:RegisterForUpdate( GROUPED_UPDATE, GROUPED_UPDATE_TIMER, EHT.Pointers.OnGroupedUpdate )
		end
	end

	local function GetGroupedTexture( isSelected, isBuilding, isAnimating )
		if isSelected then
			if isBuilding then
				return EHT.Textures.ICON_MULTISELECT_BUILD
			elseif isAnimating then
				return EHT.Textures.ICON_MULTISELECT_CAMERA
			else
				return EHT.Textures.ICON_MULTISELECT
			end
		else
			if isBuilding then
				return EHT.Textures.ICON_BUILD
			elseif isAnimating then
				return EHT.Textures.ICON_CAMERA
			else
				-- If we're grouping an item, it must at least be selected if it is not in use for any other operation.
				return EHT.Textures.ICON_MULTISELECT
			end
		end
	end

	function EHT.Pointers.SetGrouped( id, x, y, z, isSelected, isBuilding, isAnimating )
		if not x or not y or not z or not EHT.Biz.AreSelectionIndicatorsEnabled() then return false end

		local indicators, ui = EHT.Pointers.CreateGrouped()
		local indicator = indicators:AcquireObject( id )
		if nil == indicator then return false end

		local texFile = GetGroupedTexture( isSelected, isBuilding, isAnimating )
		if indicator.TexFile ~= texFile or indicator.X ~= x or indicator.Y ~= y or indicator.Z ~= z then
			indicator.TexFile, indicator.X, indicator.Y, indicator.Z = texFile, x, y, z
			indicator:SetTexture( texFile )
			indicator:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			indicator:Set3DRenderSpaceOrigin( EHT.World:Get3DPosition( x, y, z ) )
		end

		EVENT_MANAGER:RegisterForUpdate( GROUPED_UPDATE, GROUPED_UPDATE_TIMER, EHT.Pointers.OnGroupedUpdate )
		return true
	end

	function EHT.Pointers.RetainGroupedSet( retainedIds )
		local ui = EHT.UI.Grouped
		if nil == ui then return end

		local pool = ui.Indicators
		local indicators = pool:GetActiveObjects()

		if nil == retainedIds then
			for id, indicator in pairs( indicators ) do
				DestroyControl( pool, indicator, id )
			end
		else
			for id, indicator in pairs( indicators ) do
				if not retainedIds[ id ] then
					DestroyControl( pool, indicator, id )
				end
			end
		end
	end

	function EHT.Pointers.OnGroupedUpdate()
		local unregister = true
		local ui = EHT.UI.Grouped

		if nil ~= ui then
			local indicators = ui.Indicators:GetActiveObjects()
			local globalColor, globalYaw, _, glow, scale = GetIntervals()
			local globalAlpha = 0.2 + 0.5 * ( EHT.SavedVars.SelectionIndicatorAlpha or 0.5 )
			local r, g, b = globalColor > 0 and globalColor or 0, 1 - math.abs( globalColor ), globalColor < 0 and -1 * globalColor or 0
			r, g, b = 0.5 + r, 0.5 + g, 0.5 + b

			for _, indicator in pairs( indicators ) do
				unregister = false
				local x, y, z = EHT.World:GetWorldPosition( indicator:Get3DRenderSpaceOrigin() )
				indicator:Set3DRenderSpaceOrientation( EHT.World:GetCameraFacingOrientation() )
				indicator:Set3DLocalDimensions( EHT.World:GetUIIndicatorDimensions( x, y, z ) )
				indicator:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, glow )
				indicator:SetColor( r, g, b, globalAlpha )
				indicator:SetHidden( false )
			end
		end

		if unregister then EVENT_MANAGER:UnregisterForUpdate( GROUPED_UPDATE ) end
	end
end

---[ Operations : Selection Box ]---

function EHT.Pointers.CreateGroupOutline( worldChanged )
	local ui = EHT.UI.GroupOutline
	if nil == ui then
		ui = { }
		EHT.UI.GroupOutline = ui

		local indicators = { }
		ui.Indicators = indicators

		local prefix = "EHTGroupOutline"
		local p, win

		-- Top-Level Window

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetHidden( false )
		win:SetAnchor( TOPLEFT, GuiRoot, CENTER, 0, 0 )

		-- Controls

		local width, height = 0, 0

		-- Horizontal bars

		for index = 1, 12, 2 do
			local indicator = WINDOW_MANAGER:CreateControl( prefix .. tostring( index ), win, CT_TEXTURE )
			indicators[ index ] = indicator

			indicator:SetAnchor( CENTER, win, CENTER, 0, 0 )
			indicator:SetTexture( EHT.Textures.SOLID )
			indicator:SetHidden( true )
			indicator:SetAddressMode( TEX_MODE_WRAP )
			indicator:SetBlendMode( TEX_BLEND_MODE_ALPHA )
--[[
			indicator:SetShaderEffectType(SHADER_EFFECT_TYPE_WAVE)
			indicator:SetWaveBounds(0.3, 0.3, 0.3, 0.3)
			indicator:SetWave(0, 200, 40, 1)
]]
			indicator = WINDOW_MANAGER:CreateControl( prefix .. tostring( index + 1 ), win, CT_TEXTURE )
			indicators[ index + 1 ] = indicator

			indicator:SetAnchor( CENTER, win, CENTER, 0, 0 )
			indicator:SetTexture( EHT.Textures.WATER_2 ) -- NOISE_1 )
			indicator:SetHidden( true )
			indicator:SetAddressMode( TEX_MODE_WRAP )
			indicator:SetBlendMode( TEX_BLEND_MODE_ADD ) -- TEX_BLEND_MODE_COLOR_DODGE )
		end

		indicators[1].Normal = { 0, 1, 0 }
		indicators[2].Normal = { 0, 1, 0 }
		indicators[3].Normal = { 0, -1, 0 }
		indicators[4].Normal = { 0, -1, 0 }
		indicators[5].Normal = { 1, 0, 0 }
		indicators[6].Normal = { 1, 0, 0 }
		indicators[7].Normal = { -1, 0, 0 }
		indicators[8].Normal = { -1, 0, 0 }
		indicators[9].Normal = { 0, 0, 1 }
		indicators[10].Normal = { 0, 0, 1 }
		indicators[11].Normal = { 0, 0, -1 }
		indicators[12].Normal = { 0, 0, -1 }
	end

	if worldChanged then
		-- Initialize 3D Render Spaces
		local win

		win = ui.Window
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()

		for index = 1, #ui.Indicators do
			local indicator = ui.Indicators[ index ]
			if nil ~= indicator then
				indicator:SetHidden( true )
				indicator:Destroy3DRenderSpace()
				indicator:Create3DRenderSpace()
				indicator:Set3DLocalDimensions( 1, 1 )
				indicator:SetColor( 1, 1, 1, 0.5 )
			end
		end
	end

	return ui.Indicators, ui
end

function EHT.Pointers.ClearGroupOutline()
	local ui = EHT.UI.GroupOutline
	if nil == ui then return end

	local indicators = ui.Indicators
	if nil == indicators then return end

	for index = 1, #indicators do
		indicators[ index ]:SetHidden( true )
	end

	EVENT_MANAGER:UnregisterForUpdate( GROUP_OUTLINE_UPDATE, EHT.Pointers.OnGroupOutlineUpdate )
end

function EHT.Pointers.SetGroupOutlineHidden( hidden )
	local ui = EHT.UI.GroupOutline
	if nil == ui then return end

	local indicators = ui.Indicators
	if nil == indicators then return end

	if not EHT.SavedVars.ShowSelectionBoxIndicator then hidden = true end

	for i = 1, #indicators do
		indicators[ i ]:SetHidden( hidden )
	end

	if hidden then
		EVENT_MANAGER:UnregisterForUpdate( GROUP_OUTLINE_UPDATE, EHT.Pointers.OnGroupOutlineUpdate )
	else
		EHT.UI.QueueRefreshGroupOutlineIndicators()
		EVENT_MANAGER:RegisterForUpdate( GROUP_OUTLINE_UPDATE, GROUP_OUTLINE_UPDATE_TIMER, EHT.Pointers.OnGroupOutlineUpdate )
	end
end

function EHT.Pointers.SetGroupOutline( minX, minY, minZ, maxX, maxY, maxZ )
	if nil == minX or nil == minY or nil == minZ or nil == maxX or nil == maxY or nil == maxZ then return false end

	local indicators, ui = EHT.Pointers.CreateGroupOutline()
	local x = 0.5 * ( maxX + minX )
	local y = 0.5 * ( maxY + minY )
	local z = 0.5 * ( maxZ + minZ )
	local width = math.max( 1, ( maxX - minX - 4 ) / 100 )
	local height = math.max( 1, ( maxY - minY - 4 ) / 100 )
	local depth = math.max( 1, ( maxZ - minZ - 4 ) / 100 )
	local indicator


	indicator = indicators[1]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, minY, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, depth )
	indicator:Set3DRenderSpaceOrientation( RAD90, 0, 0 )

	indicator = indicators[2]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, depth )
	indicator:Set3DRenderSpaceOrientation( RAD90, 0, 0 )


	indicator = indicators[3]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, maxY, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, depth )
	indicator:Set3DRenderSpaceOrientation( RAD90, 0, 0 )

	indicator = indicators[4]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, depth )
	indicator:Set3DRenderSpaceOrientation( RAD90, 0, 0 )


	indicator = indicators[5]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( minX, y, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( depth, height )
	indicator:Set3DRenderSpaceOrientation( 0, RAD90, 0 )

	indicator = indicators[6]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( depth, height )
	indicator:Set3DRenderSpaceOrientation( 0, RAD90, 0 )


	indicator = indicators[7]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( maxX, y, z )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( depth, height )
	indicator:Set3DRenderSpaceOrientation( 0, RAD90, 0 )

	indicator = indicators[8]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( depth, height )
	indicator:Set3DRenderSpaceOrientation( 0, RAD90, 0 )


	indicator = indicators[9]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, minZ )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, height )
	indicator:Set3DRenderSpaceOrientation( 0, 0, 0 )

	indicator = indicators[10]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, height )
	indicator:Set3DRenderSpaceOrientation( 0, 0, 0 )


	indicator = indicators[11]
	local worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, maxZ )
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, height )
	indicator:Set3DRenderSpaceOrientation( 0, 0, 0 )

	indicator = indicators[12]
	indicator:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
	indicator:Set3DLocalDimensions( width, height )
	indicator:Set3DRenderSpaceOrientation( 0, 0, 0 )


	local enabled = EHT.SavedVars.ShowSelectionBoxIndicator

	for index = 1, #indicators do
		indicators[ index ]:SetHidden( not enabled )
	end

	if enabled then
		EVENT_MANAGER:RegisterForUpdate( GROUP_OUTLINE_UPDATE, GROUP_OUTLINE_UPDATE_TIMER, EHT.Pointers.OnGroupOutlineUpdate )
	end

	return true
end

function EHT.Pointers.OnGroupOutlineUpdate()
	local unregister = true
	local ui = EHT.UI.GroupOutline

	if ui then
		local indicators = ui.Indicators
		local numIndicators = #indicators
		local numIndicators0 = numIndicators - 1
		local globalAlpha = zo_lerp( 0.01, 0.2, EHT.SavedVars.SelectionBoxAlpha or 1 )
		local fx, fy, fz = EHT.World:GetCameraForward()
		local ft = GetFrameTimeMilliseconds()
		local coords1 = EHT.World:GetEasedInterval( 15000 )
		local coords2 = EHT.World:GetEasedInterval( 9000 )
		local cl = EHT.World:GetLoopInterval( 4000 )
		--local ca1 = globalAlpha * math.min( 1, ( -0.5 + 2 * cl ) )
		--local ca2 = globalAlpha - ca1
		local ca1 = globalAlpha * cl
		local ca2 = globalAlpha - ca1
		local r1, g1, b1 = zo_lerp( 1, 0, cl ), 0.5, zo_lerp( 0, 1, cl )
		local r2, g2, b2 = zo_lerp( 1, 0, cl ), 0.5, zo_lerp( 0, 1, cl )

		for index = 1, numIndicators do
			local indicator = indicators[index]
			if indicator and not indicator:IsHidden() then
				--local n = indicator.Normal
				local l = (index - 1) / numIndicators0
				local ac = (index % 2 == 0) and 0.5 or 1
				local fr, fg, fb = zo_lerp( r1, r2, l ), zo_lerp( g1, g2, l ), zo_lerp( b1, b2, l )
				local ccx, ccy = indicator:Get3DLocalDimensions()
				ccx, ccy = math.ceil( 0.05 * ccx ), math.ceil( 0.05 * ccy )

				if 2 >= index then
					indicator:SetColor( fr, fg, fb, ca2 * ac )
				elseif 4 >= index then
					indicator:SetColor( fr, fg, fb, ca1 * ac )
				else
					indicator:SetVertexColors( 3, fr, fg, fb, ca1 * ac )
					indicator:SetVertexColors( 12, fr, fg, fb, ca2 * ac )
				end
-- /script it = EHT.UI.GroupOutline.Indicators for i,c in ipairs(it) do if i%2==1 then c:SetWave( 0, 200, 2, 0 ) end end
--[[
				if 1 == ( index % 2 ) then
					indicator:SetTextureCoords( coords1, ccx + coords1, coords1, ccy + coords1 )
				else
					indicator:SetTextureCoords( coords2, ccx + coords2, coords2, ccy + coords2 )
				end
]]
				unregister = false
			end
		end
	end

	if unregister then
		EVENT_MANAGER:UnregisterForUpdate( GROUP_OUTLINE_UPDATE, EHT.Pointers.OnGroupOutlineUpdate )
		return
	end
end

---[ Operations : Guidelines ]---

function EHT.Pointers.CreateGuidelines( worldChanged )
	local ui = EHT.UI.Guidelines
	if not ui then
		ui = { }
		EHT.UI.Guidelines = ui

		local indicators = { }
		ui.Indicators = indicators

		local highlights = { }
		ui.Highlights = highlights

		local arrows = { }
		ui.Arrows = arrows

		local prefix = "EHTGuidelines"
		local i, win

		-- Top-Level Window

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetMovable( true )
		win:SetMouseEnabled( true )
		win:SetClampedToScreen( true )
		win:SetHidden( false )
		win:SetAnchor( TOPLEFT, GuiRoot, CENTER, 0, 0 )

		-- Controls

		for index = 1, 8 + 16 * GUIDELINES_RADIUS_MAX do
			i = WINDOW_MANAGER:CreateControl( prefix .. "Line" .. tostring( index ), win, CT_TEXTURE )
			indicators[ index ] = i
			i:SetAnchor( CENTER, win, CENTER, 0, 0 )
			i:SetHidden( true )
			i:SetTexture( EHT.Textures.GUIDELINE )
			i:SetAddressMode( TEX_MODE_WRAP )
			i:SetTextureReleaseOption( RELEASE_TEXTURE_AT_ZERO_REFERENCES )
			i:SetTextureCoords( 0.5, 0.5, 0.5, 0.5 )
			i:SetColor( 0, 1, 1, 0.5 )
		end

		for index = 1, 12 do
			i = WINDOW_MANAGER:CreateControl( prefix .. "Highlight" .. tostring( index ), win, CT_TEXTURE )
			highlights[ index ] = i
			i:SetAnchor( CENTER, win, CENTER, 0, 0 )
			i:SetHidden( true )
			i:SetTexture( "art/fx/texture/box_softinside.dds" )
			i:SetTextureCoords( 0.2, 0.8, 0.2, 0.8 )
			i:SetColor( 0, 1, 1, 1 )
		end

		for index = 1, 6 do
			i = WINDOW_MANAGER:CreateControl( prefix .. "Arrow" .. tostring( index ), win, CT_TEXTURE )
			arrows[ index ] = i
			i:SetAnchor( CENTER, win, CENTER, 0, 0 )
			i:SetHidden( true )
			i:SetTexture( "esoui/art/crowncrates/gamepad/gp_gemification_arrow.dds" )
			i:SetDimensions( 128, 64 )

			if 2 >= index then
				i:SetColor( 1, 1, 0.25, 0.6 )
			elseif 4 >= index then
				i:SetColor( 0.75, 1, 0.5, 0.6 )
			else
				i:SetColor( 0.5, 1, 0.5, 0.6 )
			end
		end

		for index = 7, 8 do
			i = WINDOW_MANAGER:CreateControl( prefix .. "Arrow" .. tostring( index ), win, CT_TEXTURE )
			arrows[ index ] = i
			i:SetAnchor( CENTER, win, CENTER, 0, 0 )
			i:SetHidden( true )
			i:SetTexture( "esoui/art/housing/gamepad/gp_toolicon_rotate_z.dds" )
			i:SetDimensions( 64, 64 )
			i:SetColor( 0.25, 1, 1, 0.6 )
			if 7 == index then
				i:SetTextureCoordsRotation( 0.5 * math.pi )
			else
				i:SetTextureCoordsRotation( 1.5 * math.pi )
			end
		end
	end

	if true == worldChanged then
		-- Initialize 3D Render Spaces
		local win, i

		win = ui.Window
		win:Destroy3DRenderSpace()
		win:Create3DRenderSpace()

		for index = 1, #ui.Indicators do
			i = ui.Indicators[ index ]
			i:SetHidden( true )
			i:Destroy3DRenderSpace()
			i:Create3DRenderSpace()
			i:Set3DLocalDimensions( GUIDELINES_LOCAL_WIDTH, GUIDELINES_LOCAL_HEIGHT )
			i:SetBlendMode( TEX_BLEND_MODE_ADD )
			i:Set3DRenderSpaceUsesDepthBuffer( true )
		end

		for index = 1, #ui.Highlights do
			i = ui.Highlights[ index ]
			i:SetHidden( true )
			i:Destroy3DRenderSpace()
			i:Create3DRenderSpace()
			i:Set3DLocalDimensions( GUIDELINES_LOCAL_WIDTH, GUIDELINES_LOCAL_HEIGHT )
			i:SetBlendMode( TEX_BLEND_MODE_ADD )
			i:Set3DRenderSpaceUsesDepthBuffer( true )
		end

		for index = 1, #ui.Arrows do
			i = ui.Arrows[ index ]
			i:SetHidden( true )
			i:Destroy3DRenderSpace()
			i:Create3DRenderSpace()
			if 6 >= index then
				i:Set3DLocalDimensions( 1, 0.5 )
			else
				i:Set3DLocalDimensions( 1, 1 )
			end
			i:SetBlendMode( TEX_BLEND_MODE_ALPHA )
			i:Set3DRenderSpaceUsesDepthBuffer( false )
			i:SetMouseEnabled( true )
			i:SetHandler(
				"OnMouseDown",
				function()
					EHT.Biz.SnapToGuidelinesArrowOnClick( index )
				end )
		end
	end

	return ui.Indicators, ui.Highlights, ui
end

local guidelinesDisplayCallbackId = 0

function EHT.Pointers.ClearGuidelines()
	guidelinesDisplayCallbackId = 0

	EVENT_MANAGER:UnregisterForUpdate( GUIDELINES_UPDATE, EHT.Pointers.OnGuidelinesUpdate )

	local indicators, highlights, ui = EHT.Pointers.CreateGuidelines()
	if nil == indicators or nil == highlights then return end

	for index = 1, #indicators do
		indicators[ index ]:SetHidden( true )
	end

	for index = 1, #highlights do
		highlights[ index ]:SetHidden( true )
	end
end

function EHT.Pointers.ShowGuidelinesArrows( shown )
	if not shown and EHT.SnapToGridState then EHT.SnapToGridState.Id = nil end
	if not EHT.UI.Guidelines then return end
	if shown and ( not EHT.SnapToGridState or not EHT.SnapToGridState.Id ) then shown = false end

	local arrows = EHT.UI.Guidelines.Arrows
	local horizontal, vertical = EHT.Biz.AreGuidelinesSnapped()

	arrows[1]:SetHidden( not horizontal or not shown )
	arrows[2]:SetHidden( not horizontal or not shown )
	arrows[3]:SetHidden( not horizontal or not shown )
	arrows[4]:SetHidden( not horizontal or not shown )

	arrows[5]:SetHidden( not vertical or not shown )
	arrows[6]:SetHidden( not vertical or not shown )

	arrows[7]:SetHidden( ( not horizontal and not vertical ) or not shown )
	arrows[8]:SetHidden( ( not horizontal and not vertical ) or not shown )
end

function EHT.Pointers.AreGuidelinesHidden()
	local indicators, highlights = EHT.Pointers.CreateGuidelines()
	if nil == indicators then return true end

	for i = 1, #indicators do
		if not indicators[i]:IsHidden() then return false end
	end

	return true
end

function EHT.Pointers.SetGuidelinesHidden( hidden )
	guidelinesDisplayCallbackId = 0

	if hidden or not EHT.Biz.AreGuidelinesEnabled() then
		EVENT_MANAGER:UnregisterForUpdate( GUIDELINES_UPDATE, EHT.Pointers.OnGuidelinesUpdate )

		local indicators, highlights, ui = EHT.Pointers.CreateGuidelines()
		if nil == indicators or nil == highlights then return end

		for i = 1, #indicators do
			indicators[ i ]:SetHidden( true )
		end

		for i = 1, #highlights do
			highlights[ i ]:SetHidden( true )
		end

		local gs = GuidelinesState
		gs.originX, gs.originY, gs.originZ = nil, nil, nil
		gs.xCoeffX, gs.zCoeffX, gs.xCoeffZ, gs.zCoeffZ = nil, nil, nil, nil
	else
		EHT.Pointers.SetGuidelines()
	end
end

function EHT.Pointers.FlashGuidelinesCallback( callbackId )
	if callbackId ~= guidelinesDisplayCallbackId then return end

	guidelinesDisplayCallbackId = 0
	EHT.Pointers.SetGuidelinesHidden( true )
end

function EHT.Pointers.FlashGuidelines( duration )
	guidelinesDisplayCallbackId = 0

	if not EHT.SavedVars.ShowGuidelines then
		EHT.Pointers.ClearGuidelines()
		return
	end

	if "number" ~= type( duration ) then duration = 5000 end
	if 0 == guidelinesDisplayCallbackId and not EHT.Pointers.AreGuidelinesHidden() then return end

	EHT.Pointers.SetGuidelinesHidden( false )
	guidelinesDisplayCallbackId = zo_callLater( EHT.Pointers.FlashGuidelinesCallback, duration )
end

function EHT.Pointers.AreGuidelinesLocked()
	return nil ~= GuidelinesState.LockedX and 0 ~= GuidelinesState.LockedX
end

function EHT.Pointers.LockGuidelines( locked )
	if false == locked then
		GuidelinesState.LockedX, GuidelinesState.LockedY, GuidelinesState.LockedZ = 0, 0, 0
		GuidelinesState.XAxis, GuidelinesState.AxisPolarity = nil, 0
	else
		GuidelinesState.LockedX, GuidelinesState.LockedY, GuidelinesState.LockedZ = GetPlayerWorldPositionInHouse()
		GuidelinesState.LockedY = GuidelinesState.LockedY

		local _, _, _, _, angle = EHT.Biz.GetGuidelinesSettings()
		local cameraAngle = ( EHT.Biz.GetEditorHeading() - angle ) % math.rad( 360 )
		if cameraAngle < math.rad( 45 ) or cameraAngle > math.rad( 315 ) or ( cameraAngle > math.rad( 135 ) and cameraAngle < math.rad( 225 ) ) then
			GuidelinesState.XAxis = true
			GuidelinesState.AxisPolarity = ( cameraAngle > math.rad( 135 ) and cameraAngle < math.rad( 225 ) ) and 1 or -1
		else
			GuidelinesState.XAxis = false
			GuidelinesState.AxisPolarity = ( cameraAngle >= math.rad( 225 ) and cameraAngle <= math.rad( 315 ) ) and 1 or -1
		end
	end
end

local oIndexX, oIndexZ = 0, 0

function EHT.Pointers.SetGuidelines()
	local mode = GetHousingEditorMode()
	if mode ~= HOUSING_EDITOR_MODE_SELECTION and mode ~= HOUSING_EDITOR_MODE_PLACEMENT then
		EHT.Pointers.ClearGuidelines()
		return
	end

	guidelinesDisplayCallbackId = 0

	if not EHT.Biz.AreGuidelinesEnabled() then
		EHT.Pointers.ClearGuidelines()
		return
	end

	local indicators, highlights, ui = EHT.Pointers.CreateGuidelines()
	if nil == indicators or nil == highlights then return end

	local enabled, originX, originY, originZ, angle, units, radius, maxDistance, alpha = EHT.Biz.GetGuidelinesSettings()
	local enableHighlights = EHT.Biz.AreGuidelineBoundaryHighlightsEnabled()
	local ft = GetFrameTimeMilliseconds()

	local state = GuidelinesState
	local oX, oY, oZ = originX, originY, originZ
	local playerX, playerY, playerZ, pYaw = GetPlayerWorldPositionInHouse()
	local pX, pY, pZ = playerX, playerY, playerZ

	oY = math.max( oY, pY )
	angle = ( angle or 0 )
	if RAD45 < angle then angle = -RAD45 + ( angle % RAD45 )
	elseif -RAD45 > angle then angle = RAD45 - ( angle % RAD45 )
	end

	local isHighlighted, indicatorIndex, indicator, hIndex, h = false, 1, nil, 1, nil
	local worldX, worldY, worldZ, x, y, z
	local localX, localY = GUIDELINES_LOCAL_WIDTH * ( units / 100 ) * ( 1 + radius ) * 2, GUIDELINES_LOCAL_HEIGHT
	local hLocalX, hLocalY = ( units / 100 ), ( units / 100 )
	local hAlpha, hX, hY, hZ, hDimX, hDimY, hDimZ, hGridX, hGridY, hGridZ, hMinX, hMinY, hMinZ, hMaxX, hMaxY, hMaxZ, hGridMinX, hGridMinY, hGridMinZ, hGridMaxX, hGridMaxY, hGridMaxZ
	local itemX, itemY, itemZ, itemPitch, itemYaw, itemRoll = 0, 0, 0, 0, 0, 0
	local id = HousingEditorGetSelectedFurnitureId()

	if nil ~= id then
		itemX, itemY, itemZ = EHT.Housing.GetFurniturePosition( id )
		itemPitch, itemYaw, itemRoll = EHT.Housing.GetFurnitureOrientation( id )
		if itemPitch < 0 then itemPitch = ( 2 * math.pi ) + itemPitch end
		if itemYaw < 0 then itemYaw = ( 2 * math.pi ) + itemYaw end
		if itemRoll < 0 then itemRoll = ( 2 * math.pi ) + itemRoll end
		oX, oY, oZ = EHT.Pointers.InterpolatePlanarPoint( itemX, oY, itemZ, oX, oY, oZ, units, angle )

		hMinX, hMinY, hMinZ, hMaxX, hMaxY, hMaxZ = EHT.Housing.GetFurnitureWorldBounds( id )
		hDimX, hDimY, hDimZ = hMaxX - hMinX, hMaxY - hMinY, hMaxZ - hMinZ
		hX, hY, hZ = 0.5 * ( hMinX + hMaxX ), 0.5 * ( hMinY + hMaxY ), 0.5 * ( hMinZ + hMaxZ )

		hGridX, hGridY, hGridZ = EHT.Pointers.InterpolatePlanarPoint( hX, hY, hZ, oX, oY, oZ, units, angle )
		hGridMinX, hGridMinY, hGridMinZ = EHT.Pointers.InterpolatePlanarPoint( hMinX, hMinY, hMinZ, oX, oY, oZ, units, angle )
		hGridMaxX, hGridMaxY, hGridMaxZ = EHT.Pointers.InterpolatePlanarPoint( hMaxX, hMaxY, hMaxZ, oX, oY, oZ, units, angle )

		isHighlighted = true
	else
		oX, oY, oZ = EHT.Pointers.InterpolatePlanarPoint( pX, pY, pZ, oX, oY, oZ, units, angle )
	end

	if state.LastUpdate and 500 > ( ft - state.LastUpdate ) and oX == state.CurrentX and oY == state.CurrentY and oZ == state.CurrentZ and isHighlighted == state.CurrentHighlight then
		return
	end

	state.CurrentX, state.CurrentY, state.CurrentZ, state.CurrentHighlight, state.LastUpdate = oX, oY, oZ, isHighlighted, ft

	if isHighlighted then
		hAlpha = zo_clamp( alpha, GUIDELINES_HIGHLIGHT_MIN_ALPHA, GUIDELINES_HIGHLIGHT_MAX_ALPHA )
		--local yaw = math.atan2( playerX - itemX, playerZ - itemZ ) % math.rad( 360 )

		if enableHighlights then
			local laserAlpha = EHT.SavedVars.GuidelinesLaserAlpha or 0.55

			-- Y-Axis

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0, 0, 0.5 * math.pi )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0.5 * math.pi, 0, 0.5 * math.pi )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			-- X- and Z-Axis

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0, angle, 0 )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0.5 * math.pi, angle, 0 )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0, angle + 0.5 * math.pi, 0 )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0.5 * math.pi, angle + 0.5 * math.pi, 0 )
			h:SetColor( 0, 1, 1, laserAlpha )
			h:SetHidden( false )

			-- Item Yaw

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0, itemYaw, 0 )
			h:SetColor( 1, 0, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0.5 * math.pi, itemYaw, 0 )
			h:SetColor( 1, 0, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0, itemYaw + 0.5 * math.pi, 0 )
			h:SetColor( 1, 0, 1, laserAlpha )
			h:SetHidden( false )

			h = highlights[ hIndex ]	hIndex = hIndex + 1
			x, y, z = hX, hY, hZ
			worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
			h:Set3DLocalDimensions( GUIDELINES_HIGHLIGHT_HEIGHT, 0.1 )
			h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
			h:Set3DRenderSpaceOrientation( 0.5 * math.pi, itemYaw + 0.5 * math.pi, 0 )
			h:SetColor( 1, 0, 1, laserAlpha )
			h:SetHidden( false )
		end

		h = highlights[ hIndex ]	hIndex = hIndex + 1
		x, y, z = hX, oY, hZ
		worldX, worldY, worldZ = EHT.World:Get3DPosition( x, y, z )
		h:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
		h:Set3DLocalDimensions( hDimX / 100, hDimZ / 100 )
		h:Set3DRenderSpaceOrientation( 0.5 * math.pi, angle, 0 )
		h:SetColor( 0.8, 0, 0.8, laserAlpha )
		h:SetHidden( false )
	end

	for index = hIndex, #highlights do
		highlights[ index ]:SetHidden( true )
	end

	local indicatorIndex = 1
	local ind, x, y, z, xIndex, zIndex

	local dxX, _, dxZ = EHT.Housing.RotateAroundOrigin( units, 0, 0, 0, angle, 0 )
	local dzX, _, dzZ = EHT.Housing.RotateAroundOrigin( 0, 0, units, 0, angle, 0 )
	local centerX, centerY, centerZ = playerX, playerY, playerZ
	local intervalX, intervalZ = 0, 0

	if nil ~= GuidelinesState.LockedX and 0 ~= GuidelinesState.LockedX then
		centerX, centerY, centerZ = GuidelinesState.LockedX, GuidelinesState.LockedY, GuidelinesState.LockedZ
	elseif hX and hZ then
		centerX, centerZ = hX, hZ
	end

	for adjustmentIndex = 1, 3000 do
		oX, oZ = dxX * oIndexX + dzX * oIndexZ, dxZ * oIndexX + dzZ * oIndexZ

		if oX < ( centerX - ( 2 * units ) ) then
			oIndexX = oIndexX + 1
		elseif oX > ( centerX + ( 2 * units ) ) then
			oIndexX = oIndexX - 1
		end

		if oZ < ( centerZ - ( 2 * units ) ) then
			oIndexZ = oIndexZ + 1
		elseif oZ > ( centerZ + ( 2 * units ) ) then
			oIndexZ = oIndexZ - 1
		end

		if 0 == adjustmentIndex % 10 then
			if 5 * units > math.abs( oX - intervalX ) and 5 * units > math.abs( oZ - intervalZ ) then
				break
			end

			intervalX, intervalZ = oX, oZ
		end
	end

	local scaledWidth = ( 2 * radius * units ) / 100
	local gRadius = radius - 1
	local distanceFactor = math.floor( zo_distance3D( originX + oX, centerY, originZ + oZ, playerX, playerY, playerZ ) / 100 )
	local thickness = 0.03 + 0.0012 * distanceFactor
	local alpha = EHT.SavedVars.GuidelinesAlpha
	local yOrigin = math.floor( centerY / units ) * units

	local gs = GuidelinesState
	gs.originX, gs.originY, gs.originZ, gs.centerY = originX + oX, yOrigin, originZ + oZ, centerY
	gs.xCoeffX, gs.zCoeffX, gs.xCoeffZ, gs.zCoeffZ = dxX, dzX, dxZ, dzZ

	-- Horizontal Grid

	zIndex = 0

	for xIndex = -gRadius, gRadius do
		x, y, z = dxX * xIndex + dzX * zIndex, centerY, dxZ * xIndex + dzZ * zIndex
		worldX, worldY, worldZ = EHT.World:Get3DPosition( originX + oX + x, y + GUIDELINES_PLAYER_OFFSET_Y, originZ + oZ + z )

		ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
		ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
		ind:Set3DRenderSpaceOrientation( math.rad( 90 ), angle + math.rad( 90 ), 0 )
		ind:Set3DLocalDimensions( scaledWidth, thickness )
		ind:SetHidden( false )
		ind.Alpha = alpha
		ind.Vertical = false

		ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
		ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
		ind:Set3DRenderSpaceOrientation( 0, angle + math.rad( 90 ), 0 )
		ind:Set3DLocalDimensions( scaledWidth, thickness )
		ind:SetHidden( false )
		ind.Alpha = alpha
		ind.Vertical = false
	end

	xIndex = 0

	for zIndex = -gRadius, gRadius do
		x, y, z = dxX * xIndex + dzX * zIndex, centerY, dxZ * xIndex + dzZ * zIndex
		worldX, worldY, worldZ = EHT.World:Get3DPosition( originX + oX + x, y + GUIDELINES_PLAYER_OFFSET_Y, originZ + oZ + z )

		ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
		ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
		ind:Set3DRenderSpaceOrientation( math.rad( 90 ), angle, 0 )
		ind:Set3DLocalDimensions( scaledWidth, thickness )
		ind:SetHidden( false )
		ind.Alpha = alpha
		ind.Vertical = false

		ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
		ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
		ind:Set3DRenderSpaceOrientation( 0, angle, 0 )
		ind:Set3DLocalDimensions( scaledWidth, thickness )
		ind:SetHidden( false )
		ind.Alpha = alpha
		ind.Vertical = false
	end

	-- Vertical Grid

	if EHT.SavedVars.ShowGuidelinesVertical then
		local cameraAngle = ( EHT.Biz.GetEditorHeading() - angle ) % math.rad( 360 )

		local xAxis, axisPolarity = false, 1
		if cameraAngle < math.rad( 45 ) or cameraAngle > math.rad( 315 ) or ( cameraAngle > math.rad( 135 ) and cameraAngle < math.rad( 225 ) ) then
			xAxis = true
			axisPolarity = ( cameraAngle > math.rad( 135 ) and cameraAngle < math.rad( 225 ) ) and 1 or -1
		else
			axisPolarity = ( cameraAngle >= math.rad( 225 ) and cameraAngle <= math.rad( 315 ) ) and 1 or -1
		end

		if nil ~= GuidelinesState.XAxis and 0 ~= GuidelinesState.AxisPolarity then
			xAxis, axisPolarity = GuidelinesState.XAxis, GuidelinesState.AxisPolarity
		end

		xIndex, zIndex = 0, 0

		if not id or ( nil ~= GuidelinesState.XAxis and 0 ~= GuidelinesState.AxisPolarity ) then
			if not xAxis then
				xIndex = axisPolarity * math.ceil( 0.5 * radius )
			else
				zIndex = axisPolarity * math.ceil( 0.5 * radius )
			end
		end

		local lineAngle = angle
		if xAxis then lineAngle = angle else lineAngle = angle + math.rad( 90 ) end

		for yIndex = -gRadius, gRadius do
			x, y, z = dxX * xIndex + dzX * zIndex, yOrigin + yIndex * units, dxZ * xIndex + dzZ * zIndex
			worldX, worldY, worldZ = EHT.World:Get3DPosition( originX + oX + x, y + GUIDELINES_PLAYER_OFFSET_Y, originZ + oZ + z )

			if xAxis then
				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( math.rad( 90 ), lineAngle, 0 )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( 0, lineAngle, 0 )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true
			else
				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( math.rad( 90 ), lineAngle, 0 )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( 0, lineAngle, 0 )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true
			end
		end

		if xAxis then
			if not id or nil ~= GuidelinesState.XAxis then
				zIndex = axisPolarity * math.ceil( 0.5 * radius )
			else
				zIndex = 0
			end

			for xIndex = -gRadius, gRadius do
				x, y, z = dxX * xIndex + dzX * zIndex, yOrigin, dxZ * xIndex + dzZ * zIndex
				worldX, worldY, worldZ = EHT.World:Get3DPosition( originX + oX + x, y + GUIDELINES_PLAYER_OFFSET_Y, originZ + oZ + z )

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( 0, 0, math.rad( 90 ) )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( math.rad( 90 ), 0, math.rad( 90 ) )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true
			end
		else
			if not id or nil ~= GuidelinesState.XAxis then
				xIndex = axisPolarity * math.ceil( 0.5 * radius )
			else
				xIndex = 0
			end

			for zIndex = -gRadius, gRadius do
				x, y, z = dxX * xIndex + dzX * zIndex, yOrigin, dxZ * xIndex + dzZ * zIndex
				worldX, worldY, worldZ = EHT.World:Get3DPosition( originX + oX + x, y + GUIDELINES_PLAYER_OFFSET_Y, originZ + oZ + z )

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( 0, 0, math.rad( 90 ) )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true

				ind = indicators[ indicatorIndex ] indicatorIndex = indicatorIndex + 1
				ind:Set3DRenderSpaceOrigin( worldX, worldY, worldZ )
				ind:Set3DRenderSpaceOrientation( math.rad( 90 ), 0, math.rad( 90 ) )
				ind:Set3DLocalDimensions( scaledWidth, thickness )
				ind:SetHidden( false )
				ind.Alpha = alpha
				ind.Vertical = true
			end
		end
	end

	-- Hide unused Grid lines.

	for index = indicatorIndex, #indicators do
		indicators[ index ]:SetHidden( true )
	end

	EVENT_MANAGER:RegisterForUpdate( GUIDELINES_UPDATE, GUIDELINES_UPDATE_TIMER, EHT.Pointers.OnGuidelinesUpdate )
	return true
end

function EHT.Pointers.OnGuidelinesUpdate()
	local mode = GetHousingEditorMode()
	if mode ~= HOUSING_EDITOR_MODE_SELECTION and mode ~= HOUSING_EDITOR_MODE_PLACEMENT then
		EHT.Pointers.ClearGuidelines()
		return
	end

	local enabled, oX, oY, oZ, angle, units, radius, maxDistance, alpha = EHT.Biz.GetGuidelinesSettings()
	if not enabled then
		EVENT_MANAGER:UnregisterForUpdate( GUIDELINES_UPDATE )
		return
	end

	EHT.Pointers.SetGuidelines()

	if EHT.Biz.HaveGuidelinesSettingsChanged( true ) then
		return
	end

	local indicators, highlights, ui = EHT.Pointers.CreateGuidelines()
	if nil == indicators then
		return
	end

	local globalColor, globalRotation, easedInterval = GetIntervals()
	local cAlpha = mode == HOUSING_EDITOR_MODE_SELECTION and 0.5 or 1
	local animInterval = EHT.World:GetLinearInterval( 1400 )
	local hR, hG, hB, vR, vG, vB
	local c = 0.7 + 0.3 * easedInterval
	local _, camFwd = EHT.World:GetCameraForward()

	alpha = ( 0.4 + 0.5 * alpha ) * cAlpha
	local hAlpha = zo_clamp( alpha * ( 0.5 + 0.5 * math.abs( camFwd ) ), 0.4, 1 )
	local vAlpha = zo_clamp( alpha * ( 0.5 + 0.5 * ( 1 - math.abs( camFwd ) ) ), 0.4, 1 )

	local unregister = true
	for index = 1, #indicators do
		local indicator = indicators[index]
		if not indicator:IsHidden() then
			unregister = false
			local sample

			if indicator.Vertical then
				indicator:SetColor( 0, c, c, indicator.Alpha * vAlpha )
				sample = 0.5 + vAlpha
			else
				indicator:SetColor( c, c, c, indicator.Alpha * hAlpha )
				sample = 0.5 + hAlpha
			end

			local y1, y2
			if 0 == index % 2 then y1, y2 = 0, 1 else y1, y2 = 1, 0 end
			indicator:SetTextureSampleProcessingWeight( TEX_SAMPLE_PROCESSING_RGB, sample )
		end
	end

	if unregister then
		EVENT_MANAGER:UnregisterForUpdate( GUIDELINES_UPDATE )
		return
	end
end

function EHT.Pointers.ResetGuidelines()
	EHT.Biz.SetGuidelinesSettings( nil, 0, 0, 0, 0 )
end

function EHT.Pointers.AdjustGuidelines( offsetX, offsetY, offsetZ, offsetYaw, offsetUnits )
	local enabled, oX, oY, oZ, oYaw, units, radius, maxDistance, alpha = EHT.Biz.GetGuidelinesSettings()

	if "number" == type( offsetX ) then oX = oX + offsetX end
	if "number" == type( offsetY ) then oY = oY + offsetY end
	if "number" == type( offsetZ ) then oZ = oZ + offsetZ end
	if "number" == type( offsetYaw ) then oYaw = oYaw + offsetYaw end
	if "number" == type( offsetUnits ) then units = units + offsetUnits end
	if units < 10 then units = 1000 elseif units > 1000 then units = 10 end
	if oX < 0 then oX = units elseif oX > units then oX = 0 end
	if oY < 0 then oY = units elseif oY > units then oY = 0 end
	if oZ < 0 then oZ = units elseif oZ > units then oZ = 0 end

	EHT.Biz.SetGuidelinesSettings( true, oX, oY, oZ, oYaw, units, radius, alpha )
end

function EHT.Pointers.GetLocalGridOrigin()
	local gs = GuidelinesState
	return gs.originX, gs.originY, gs.originZ, gs.centerY
end

function EHT.Pointers.GetLocalGridCoefficients()
	local gs = GuidelinesState
	return gs.xCoeffX or 0, gs.zCoeffX or 0, gs.xCoeffZ or 0, gs.zCoeffZ or 0
end
-- /script d( EHT.Pointers.FindLocalGridVertex(25047, 26625, 22132, 0, 0, 0))
function EHT.Pointers.FindLocalGridVertex( x, y, z, unitOffsetX, unitOffsetY, unitOffsetZ )
	local radius = EHT.SavedVars.GuidelinesRadius or 10
	local units = EHT.SavedVars.GuidelinesUnits or 1
	local dist, distMin, gX, gY, gZ, tX, tY, tZ, miX, miY, miZ
	local gs = GuidelinesState

	if nil == gs.originX or nil == gs.originY or nil == gs.originZ or nil == gs.xCoeffX or nil == gs.zCoeffX or nil == gs.xCoeffZ or nil == gs.zCoeffZ then return nil end
--	local oX, oY, oZ = gs.originX + gs.xCoeffX + gs.zCoeffX, gs.originY + units, gs.originZ + gs.xCoeffZ + gs.zCoeffZ
	for iX = -radius, radius do
		for iY = -radius, radius do
			for iZ = -radius, radius do
				gX, gY, gZ = gs.originX + gs.xCoeffX * iX + gs.zCoeffX * iZ, gs.originY + units * iY, gs.originZ + gs.xCoeffZ * iX + gs.zCoeffZ * iZ
				dist = zo_distance3D( gX, gY, gZ, x, y, z )

				if nil == distMin or dist < distMin then
					miX, miY, miZ = iX, iY, iZ
					distMin = dist
				end
			end
		end
	end

	if 2 * units < math.abs( distMin ) then return nil end

	local iX, iY, iZ = miX + unitOffsetX, miY + unitOffsetY, miZ + unitOffsetZ
	tX, tY, tZ = gs.originX + gs.xCoeffX * iX + gs.zCoeffX * iZ, gs.originY + units * iY, gs.originZ + gs.xCoeffZ * iX + gs.zCoeffZ * iZ

	return tX, tY, tZ
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Pointers = true