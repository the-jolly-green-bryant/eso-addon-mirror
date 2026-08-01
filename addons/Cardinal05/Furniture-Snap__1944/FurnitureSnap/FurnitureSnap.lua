FurnSnap = { }
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")


------[[ "Constants" ]]------


FurnSnap.ADDON_NAME = "FurnitureSnap"
FurnSnap.ADDON_VERSION = "1.3"

FurnSnap.SAVED_VARS_NAME = "FurnitureSnapSavedVars"
FurnSnap.SAVED_VARS_VERSION = 1
FurnSnap.SAVED_VARS_DEFAULTS = { Enabled = true, GridSize = 15, GridAngle = 0, GridOffsets = { 0, 0, 0 }, GridAxes = { X = true, Y = false, Z = true }, OrientationIncrement = 15, OrientationAxes = { Pitch = true, Yaw = true, Roll = true }, SnapInSurfaceDragMode = true }

FurnSnap.UPDATE_INTERVAL = 100

FurnSnap.GRID_SIZE_OPTIONS = { 5, 10, 15, 20, 25, 50, 75, 100 }
FurnSnap.ORIENTATION_INCREMENTS = { 1, 2, 5, 10, 15, 30, 45, 90 }


------[[ Variables ]]------


FurnSnap.Vars = { }

FurnSnap.Suspended = false
FurnSnap.PreviousEditorMode = nil
FurnSnap.OriginFurnitureId = nil
FurnSnap.SnapFurnitureId = nil
FurnSnap.CalibrationWorkflow = nil


------[[ API ]]------


function FurnSnap.SuspendSnapping() FurnSnap.Suspended = true end

function FurnSnap.ResumeSnapping() FurnSnap.Suspended = false end


------[[ Utilities : Core ]]------


function FurnSnap.CloneTable( obj ) if type( obj ) ~= 'table' then return obj end local res = {} for k, v in pairs( obj ) do res[ FurnSnap.CloneTable( k ) ] = FurnSnap.CloneTable( v ) end	return res end


------[[ Utilities : Math ]]------


function FurnSnap.Round( n, decimals ) if "number" == type( n ) and 0 ~= n and "number" == type( decimals ) and 0 <= decimals then return math.floor( n * math.pow( 10, decimals ) ) / math.pow( 10, decimals ) else return 0 end end


------[[ Utilities : Geometry ]]------


function FurnSnap.Distance3d( x1, y1, z1, x2, y2, z2 ) return math.sqrt( ( ( x1 - x2 ) ^ 2 ) + ( ( y1 - y2 ) ^ 2 ) + ( ( z1 - z2 ) ^ 2 ) ) end


function FurnSnap.TranslatePoint( x, y, z, tX, tY, tZ )	return x + tX, y + tY, z + tZ end


function FurnSnap.RotatePointOnAxisX( x, y, z, radians )

	local newY, newZ
	newY = y * math.cos( radians ) - z * math.sin( radians )
	newZ = y * math.sin( radians ) + z * math.cos( radians )
	return x, newY, newZ

end


function FurnSnap.RotatePointOnAxisY( x, y, z, radians )

	local newX, newZ
	newX = z * math.sin( radians ) + x * math.cos( radians )
	newZ = z * math.cos( radians ) - x * math.sin( radians )
	return newX, y, newZ

end


function FurnSnap.RotatePointOnAxisZ( x, y, z, radians )

	local newX, newY
	newX = x * math.cos( radians ) - y * math.sin( radians )
	newY = x * math.sin( radians ) + y * math.cos( radians )
	return newX, newY, z

end


function FurnSnap.FindRelativeAngle( x1, z1, x2, z2 )

	local a, b = x1 - x2, z1 - z2
	if 0 == FurnSnap.Round( b, 4 ) then return 0 else return math.atan( a / b ) end

end


------[[ Utilities : Housing ]]------


function FurnSnap.IsInHouse()

	return 0 ~= GetCurrentZoneHouseId()

end


------[[ Methods : Add-On ]]------


function FurnSnap.Initialize()

	ZO_CreateStringId( "SI_BINDING_NAME_FURNITURE_SNAP_TOGGLE_STATE", "Toggle Furniture Snapping On/Off" )
	ZO_CreateStringId( "SI_BINDING_NAME_FURNITURE_SNAP_TOGGLE_GRID_SIZE", "Toggle Grid Size" )
	ZO_CreateStringId( "SI_BINDING_NAME_FURNITURE_SNAP_CALIBRATE_GRID", "Calibrate Grid" )

	FurnSnap.Vars = ZO_SavedVars:NewAccountWide( FurnSnap.SAVED_VARS_NAME, FurnSnap.SAVED_VARS_VERSION, nil, FurnSnap.SAVED_VARS_DEFAULTS )
	FurnSnap.CleanVars()
	FurnSnap.SetupSettingsMenu()

	SLASH_COMMANDS[ "/fs" ], SLASH_COMMANDS[ "/snap" ] = FurnSnap.ToggleState, FurnSnap.ToggleState
	SLASH_COMMANDS[ "/fsc" ], SLASH_COMMANDS[ "/fscali" ], SLASH_COMMANDS[ "/fscalibrate" ] = FurnSnap.CalibrateGrid, FurnSnap.CalibrateGrid, FurnSnap.CalibrateGrid

end


function FurnSnap.CleanVars()

	local vars = FurnSnap.Vars

	for k, v in pairs( FurnSnap.SAVED_VARS_DEFAULTS ) do
		if nil == vars[ k ] then
			if "table" == type( v ) then
				vars[ k ] = FurnSnap.CloneTable( v )
			else
				vars[ k ] = v
			end
		end
	end

end


------[[ Methods : User Interface ]]------


function FurnSnap.SetupSettingsMenu()

	local panelData = {
		type = "panel",
		name = "Furniture Snap",
		displayName = FurnSnap.ADDON_NAME .. " Settings",
		author = "Jesus Take The Heal",
		version = FurnSnap.ADDON_VERSION,
		slashCommand = "/fsset",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() for k, v in pairs( FurnSnap.SAVED_VARS_DEFAULTS ) do FurnSnap.Vars[ k ] = v end end
	}

	LAM:RegisterAddonPanel( "FurnitureSnapSettings", panelData )

	local gridSizes = { }
	for i, size in ipairs( FurnSnap.GRID_SIZE_OPTIONS ) do
		gridSizes[ i ] = tostring( size )
	end

	local orientationIncrements = { }
	for i, size in ipairs( FurnSnap.ORIENTATION_INCREMENTS ) do
		orientationIncrements[ i ] = tostring( size )
	end

	local optionsTable = {
		[1] = {
			type = "checkbox",
			name = "Enable Snapping",
			tooltip = "If unchecked, furniture will not be snapped.",
			getFunc = function() return FurnSnap.Vars.Enabled end,
			setFunc = function(value) FurnSnap.Vars.Enabled = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.Enabled,
			disabled = function() return false end,
		},
		[2] = {
			type = "checkbox",
			name = "Enable Snapping in Surface Drag Mode",
			tooltip = "If unchecked, furniture will not be snapped when the Housing Editor's Surface Drag Mode is toggled ON.",
			getFunc = function() return FurnSnap.Vars.SnapInSurfaceDragMode end,
			setFunc = function(value) FurnSnap.Vars.SnapInSurfaceDragMode = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.SnapInSurfaceDragMode,
			disabled = function() return not FurnSnap.Vars.Enabled end,
		},
		[3] = {
			type = "dropdown",
			name = "Grid Size (cm)",
			tooltip = "Size of the grid to which furniture is snapped. Measured in centimeters.",
			choices = gridSizes,
			getFunc = function() return tostring( FurnSnap.Vars.GridSize ) end,
			setFunc = function(value) FurnSnap.Vars.GridSize = tonumber( value ) end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.GridSize,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[4] = {
			type = "dropdown",
			name = "Orientation Increments (degrees)",
			tooltip = "The whole increments to which furniture orientation (Pitch, Yaw and Roll) is snapped. Measured in degrees.",
			choices = orientationIncrements,
			getFunc = function() return tostring( FurnSnap.Vars.OrientationIncrement ) end,
			setFunc = function(value) FurnSnap.Vars.OrientationIncrement = tonumber( value ) end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.OrientationIncrement,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[5] = {
			type = "checkbox",
			name = "Snap to X-axis",
			tooltip = "If checked, furniture will be snapped to the X-axis (east/west).",
			getFunc = function() return FurnSnap.Vars.GridAxes.X end,
			setFunc = function(value) FurnSnap.Vars.GridAxes.X = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.GridAxes.X,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[6] = {
			type = "checkbox",
			name = "Snap Pitch",
			tooltip = "If checked, furniture Pitch will be snapped (front to back rotation).",
			getFunc = function() return FurnSnap.Vars.OrientationAxes.Pitch end,
			setFunc = function(value) FurnSnap.Vars.OrientationAxes.Pitch = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.OrientationAxes.Pitch,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[7] = {
			type = "checkbox",
			name = "Snap to Y-axis",
			tooltip = "If checked, furniture will be snapped to the Y-axis (up/down).",
			getFunc = function() return FurnSnap.Vars.GridAxes.Y end,
			setFunc = function(value) FurnSnap.Vars.GridAxes.Y = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.GridAxes.Y,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[8] = {
			type = "checkbox",
			name = "Snap Yaw",
			tooltip = "If checked, furniture Yaw will be snapped (facing left to right rotation).",
			getFunc = function() return FurnSnap.Vars.OrientationAxes.Yaw end,
			setFunc = function(value) FurnSnap.Vars.OrientationAxes.Yaw = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.OrientationAxes.Yaw,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[9] = {
			type = "checkbox",
			name = "Snap to Z-axis",
			tooltip = "If checked, furniture will be snapped to the Z-axis (north/south).",
			getFunc = function() return FurnSnap.Vars.GridAxes.Z end,
			setFunc = function(value) FurnSnap.Vars.GridAxes.Z = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.GridAxes.Z,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		},
		[10] = {
			type = "checkbox",
			name = "Snap Roll",
			tooltip = "If checked, furniture Roll will be snapped (rolling from side to side).",
			getFunc = function() return FurnSnap.Vars.OrientationAxes.Roll end,
			setFunc = function(value) FurnSnap.Vars.OrientationAxes.Roll = value end,
			default = FurnSnap.SAVED_VARS_DEFAULTS.OrientationAxes.Roll,
			disabled = function() return not FurnSnap.Vars.Enabled end,
			width = "half"
		}
	}

	LAM:RegisterOptionControls( "FurnitureSnapSettings", optionsTable )

end


------[[ Methods : Grid ]]------


function FurnSnap.CalculateSnapCoords( x, y, z )

	local gridSize, gridOffsets, gridAngle = FurnSnap.Vars.GridSize, FurnSnap.Vars.GridOffsets, math.rad( FurnSnap.Vars.GridAngle )

	-- Align to Origin
	if nil ~= gridOffsets then x, y, z = x - gridOffsets[ 1 ], y - gridOffsets[ 2 ], z - gridOffsets[ 3 ] end
	if nil ~= gridAngle and 0 ~= gridAngle then x, y, z = FurnSnap.RotatePointOnAxisY( x, y, z, -1 * gridAngle ) end
	local dX, dY, dZ = x % gridSize, y % gridSize, z % gridSize

	if FurnSnap.Vars.GridAxes.X then if dX < gridSize / 2 then x = x - dX else x = x + ( gridSize - dX ) end end
	if FurnSnap.Vars.GridAxes.Y then if dY < gridSize / 2 then y = y - dY else y = y + ( gridSize - dY ) end end
	if FurnSnap.Vars.GridAxes.Z then if dZ < gridSize / 2 then z = z - dZ else z = z + ( gridSize - dZ ) end end

	-- Realign to Grid Angle
	if nil ~= gridAngle and 0 ~= gridAngle then x, y, z = FurnSnap.RotatePointOnAxisY( x, y, z, gridAngle ) end
	if nil ~= gridOffsets then x, y, z = x + gridOffsets[ 1 ], y + gridOffsets[ 2 ], z + gridOffsets[ 3 ] end

	return x, y, z

end


function FurnSnap.CalculateSnapOrientation( pitch, yaw, roll )

	local increment, gridAngle = math.rad( FurnSnap.Vars.OrientationIncrement ), math.rad( FurnSnap.Vars.GridAngle )

	-- Align to Origin
	if nil ~= gridAngle and 0 ~= gridAngle then yaw = yaw - gridAngle end

	local dPitch, dYaw, dRoll = pitch % increment, yaw % increment, roll % increment

	if FurnSnap.Vars.OrientationAxes.Pitch then if dPitch < increment / 2 then pitch = pitch - dPitch else pitch = pitch + ( increment - dPitch ) end end
	if FurnSnap.Vars.OrientationAxes.Yaw then if dYaw < increment / 2 then yaw = yaw - dYaw else yaw = yaw + ( increment - dYaw ) end end
	if FurnSnap.Vars.OrientationAxes.Roll then if dRoll < increment / 2 then roll = roll - dRoll else roll = roll + ( increment - dRoll ) end end

	-- Realign to Grid Angle
	if nil ~= gridAngle and 0 ~= gridAngle then yaw = yaw + gridAngle end

	-- Avoid Gimbal Lock scenarios
	local rightAngle, rightOffset = math.rad( 90 ), math.rad( 0.01 )
	if 0 == pitch % rightAngle then pitch = pitch + rightOffset end
	if 0 == yaw % rightAngle then yaw = yaw + rightOffset end
	if 0 == roll % rightAngle then roll = roll + rightOffset end

	return pitch, yaw, roll

end


------[[ Methods : Features ]]------


function FurnSnap.SnapFurniture( furnitureId, state )

	if nil ~= FurnSnap.CalibrationWorkflow then return end

	local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
	local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureId )

	if nil == x or nil == y or nil == z or nil == pitch or nil == yaw or nil == roll or 0 == x or 0 == y or 0 == z then return end
	if nil ~= state and ( state[1] == x and state[2] == y and state[3] == z and state[4] == pitch and state[5] == yaw and state[6] == roll ) then return end

	x, y, z = FurnSnap.CalculateSnapCoords( x, y, z )
	pitch, yaw, roll = FurnSnap.CalculateSnapOrientation( pitch, yaw, roll )
	HousingEditorRequestChangePositionAndOrientation( furnitureId, x, y, z, pitch, yaw, roll )

end


function FurnSnap.ToggleState()

	if not FurnSnap.IsInHouse() then return end

	if FurnSnap.Vars.Enabled then

		FurnSnap.Vars.Enabled = false
		d( "Furniture Snapping is OFF." )

	else

		FurnSnap.Vars.Enabled = true
		d( "Furniture Snapping is ON. Bend ...and Snap!" )

	end

end


function FurnSnap.ToggleGridSize()

	if not FurnSnap.IsInHouse() then return end

	local currentIndex = nil

	for i, size in ipairs( FurnSnap.GRID_SIZE_OPTIONS ) do
		if size == FurnSnap.Vars.GridSize then
			currentIndex = i
			break
		end
	end

	if nil ~= currentIndex then currentIndex = currentIndex + 1 else currentIndex = 1 end

	if currentIndex > #FurnSnap.GRID_SIZE_OPTIONS then
		FurnSnap.Vars.GridSize = FurnSnap.GRID_SIZE_OPTIONS[ 1 ]
	else
		FurnSnap.Vars.GridSize = FurnSnap.GRID_SIZE_OPTIONS[ currentIndex ]
	end

	df( "Furniture Snap grid size is now %s cm.", tostring( FurnSnap.Vars.GridSize ) )

end


function FurnSnap.CalibrateGrid()

	local workflow = FurnSnap.CalibrationWorkflow
	d( " " )

	if nil ~= FurnSnap.Vars.GridAngle and 0 ~= FurnSnap.Vars.GridAngle then

		FurnSnap.Vars.GridAngle = 0
		FurnSnap.Vars.GridOrigin = { 0, 0, 0 }

		d( "Furniture Snap grid calibration has been reset." )
		return

	elseif nil == workflow then

		workflow = { Coords1 = { }, Coords2 = { } }
		FurnSnap.CalibrationWorkflow = workflow

		d( "----------------------" )
		d( " " )
		d( "Furniture Snap grid calibration started." )
		d( "** You will need 1 furniture item for this process **" )
		d( " " )
		d( "Place the item on the floor, against the wall you wish to calibrate for; then, target the item and hit Calibrate again." )
		return

	else

		local coords = workflow.Coords1
		if 0 < #coords then coords = workflow.Coords2 end

		if not HousingEditorCanSelectTargettedFurniture() then

			d( "Place the item on the floor, against the wall you wish to calibrate for; then, target the item and hit Calibrate again." )
			return

		end

		HousingEditorSelectTargettedFurniture()
		local furnitureId = HousingEditorGetSelectedFurnitureId()
		HousingEditorRequestSelectedPlacement()

		if nil == furnitureId then

			d( "Failed to select the targeted furnishing." )
			return

		end

		local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )

		if 0 == x or 0 == y or 0 == z then 

			d( "You must place the item down first." )
			return

		else

			coords[1], coords[2], coords[3] = x, y, z

			if 0 >= #workflow.Coords2 then

				d( "Next, place the same item on the floor, further down the same wall, keeping the item against the wall; then, target the item and hit Calibrate again." )
				return

			else

				local gridSize = FurnSnap.Vars.GridSize
				local angle = FurnSnap.Round( math.deg( FurnSnap.FindRelativeAngle( workflow.Coords1[ 1 ], workflow.Coords1[ 3 ], workflow.Coords2[ 1 ], workflow.Coords2[ 3 ] ) ), 4 )

				if 0 == angle then

					d( "You must *move* the same item on the floor, further down the same wall, keeping the item against the wall; then, target the item and hit Calibrate again." )
					return

				else

					FurnSnap.Vars.GridAngle = angle
					FurnSnap.Vars.GridOffsets = { workflow.Coords2[ 1 ], workflow.Coords2[ 2 ], workflow.Coords2[ 3 ] }

					FurnSnap.CalibrationWorkflow = nil

					df( "Grid calibrated for grid size %s at %s degrees.", tostring( gridSize ), tostring( FurnSnap.Vars.GridAngle ) )
					d( "Grid calibration complete!" )
					d( "Hit Calibrate again when you wish to RESET the calibration." )
					return

				end

			end

		end

	end

end


------[[ Events : Handlers ]]------


function FurnSnap.OnModeChanged( event, oldMode, newMode )

	local mode = GetHousingEditorMode()

	if HOUSING_EDITOR_MODE_PLACEMENT == mode then

		-- Track currently selected Furniture Id.
		local id = HousingEditorGetSelectedFurnitureId()
		FurnSnap.SnapFurnitureId = id

		local x, y, z = HousingEditorGetFurnitureWorldPosition( id )
		local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( id )
		FurnSnap.SnapFurnitureState = { x, y, z, pitch, yaw, roll }

	elseif HOUSING_EDITOR_MODE_PLACEMENT == FurnSnap.PreviousEditorMode and nil ~= FurnSnap.SnapFurnitureId then

		-- Detect when a Furnishing has been placed and Snap that furnishing to the virtual grid.
		-- Do not snap furniture if Snapping is disabled or if Surface Drag Mode is enabled but the SnapInSurfaceDragMode setting is off.
		if not FurnSnap.Suspended and FurnSnap.Vars.Enabled and ( FurnSnap.Vars.SnapInSurfaceDragMode or not HousingEditorIsSurfaceDragModeEnabled() ) then

			local id = FurnSnap.SnapFurnitureId
			local state = FurnSnap.CloneTable( FurnSnap.SnapFurnitureState )

			zo_callLater( function() FurnSnap.SnapFurniture( id, state ) end, UPDATE_INTERVAL )

		end

		FurnSnap.SnapFurnitureId = nil
		FurnSnap.SnapFurnitureState = nil

	end

	FurnSnap.PreviousEditorMode = mode

end


function FurnSnap.OnFurniturePlaced( event, furnitureId, collectibleId )

	if nil ~= furnitureId then

		-- Detect when a Furnishing has been placed and Snap that furnishing to the virtual grid.
		-- Do not snap furniture if Snapping is disabled or if Surface Drag Mode is enabled but the SnapInSurfaceDragMode setting is off.
		if not FurnSnap.Suspended and FurnSnap.Vars.Enabled and ( FurnSnap.Vars.SnapInSurfaceDragMode or not HousingEditorIsSurfaceDragModeEnabled() ) then

			FurnSnap.SnapFurnitureId = nil
			zo_callLater( function() FurnSnap.SnapFurniture( furnitureId ) end, UPDATE_INTERVAL )

		end

	end

	FurnSnap.SnapFurnitureId = nil

end


function FurnSnap.OnAddOnLoaded( event, addonName )

	if( FurnSnap.ADDON_NAME == addonName ) then
		EVENT_MANAGER:UnregisterForEvent( FurnSnap.ADDON_NAME, EVENT_ADD_ON_LOADED )
		FurnSnap.Initialize()
	end

end


------[[ Events : Registration ]]------


EVENT_MANAGER:RegisterForEvent( FurnSnap.ADDON_NAME, EVENT_ADD_ON_LOADED, FurnSnap.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( FurnSnap.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, FurnSnap.OnModeChanged )
EVENT_MANAGER:RegisterForEvent( FurnSnap.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, FurnSnap.OnFurniturePlaced )
