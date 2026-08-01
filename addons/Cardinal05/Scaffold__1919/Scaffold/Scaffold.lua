Scaffold = { }


-- Member "Constants"


Scaffold.ADDON_NAME = "Scaffold"
Scaffold.ADDON_VER_MAJOR = 1
Scaffold.ADDON_VER_MINOR = 32

Scaffold.SAVED_VARS_NAME = "ScaffoldSavedVars"
Scaffold.SAVED_VARS_VERSION = 1
Scaffold.SAVED_VARS_DEFAULTS = { Settings = { DescendKey = "ALT", SuspendKey = "CTRL" } }

Scaffold.SLASH_COMMAND_STRING = "/scaf"

Scaffold.STATE = { }
Scaffold.STATE.INACTIVE = 0
Scaffold.STATE.ACTIVE = 1
Scaffold.STATE.SUSPENDED = 2

Scaffold.ITEM_MIN_COUNT = 3
Scaffold.ITEM_MAX_COUNT = 3
Scaffold.ITEM_MAX_DISTANCE = 100 * 10	-- ~10 meters

Scaffold.UPDATE_INTERVAL = 100


-- Member Variables


Scaffold.Vars = { }

Scaffold.State = Scaffold.STATE.INACTIVE
Scaffold.FirstUpdate = false
Scaffold.UpdateHandle = nil
Scaffold.PreviousPlayerY = nil
Scaffold.FlagDescend = false
Scaffold.FlagSuspend = false
Scaffold.FlagSuspendPending = false

Scaffold.Items = { }
Scaffold.ItemData = { }
Scaffold.ItemData[ 1 ] = { ItemLink = "|H1:item:117989:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", X = 1482, Y = 60, Z = 608, MarginX = 20, MarginY = 45, MarginZ = 20, OffsetY = -50, ThresholdX = 200, ThresholdZ = 40 }
Scaffold.ItemData[ 2 ] = { ItemLink = "|H1:item:134298:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", X = 600, Y = 60, Z = 600, MarginX = 20, MarginY = 45, MarginZ = 20, OffsetY = -50, ThresholdX = 100, ThresholdZ = 40 }
Scaffold.ItemMeasurements = nil

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")


-- Constructors


function Scaffold.CreateItem( furnitureId )

	local item = nil

	if nil ~= furnitureId then
		local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
		local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureId )
		local link = GetPlacedFurnitureLink( furnitureId, LINK_STYLE_BRACKETS )

		if nil ~= x and nil ~= y and nil ~= z and nil ~= link then
			item = { Id = furnitureId, IdString = Id64ToString( furnitureId ), Link = link, Original = { X = x, Y = y, Z = z, Yaw = yaw, Pitch = pitch, Roll = roll } }
		end
	end

	return item

end


-- Methods


function Scaffold.Initialize()

	ZO_CreateStringId( "SI_BINDING_NAME_SCAFFOLD_TOGGLE_STATE", "Toggle Scaffolding On/Off" )
	ZO_CreateStringId( "SI_BINDING_NAME_SCAFFOLD_SUSPEND_RESUME", "Suspend/Resume Scaffolding" )
	ZO_CreateStringId( "SI_BINDING_NAME_SCAFFOLD_DESCEND", "Descend" )

	Scaffold.Vars = ZO_SavedVars:NewAccountWide( Scaffold.SAVED_VARS_NAME, Scaffold.SAVED_VARS_VERSION, nil, Scaffold.SAVED_VARS_DEFAULTS )

	SLASH_COMMANDS[ Scaffold.SLASH_COMMAND_STRING ] = Scaffold.SlashCommand

	Scaffold.SetupSettingsMenu()

end


function Scaffold.SetupSettingsMenu()

	local panelData = {
		type = "panel",
		name = "Scaffold",
		displayName = Scaffold.ADDON_NAME .. " Settings (Ver " .. tostring( Scaffold.ADDON_VER_MAJOR ) .. "." .. tostring( Scaffold.ADDON_VER_MINOR ) .. ")",
		author = "Jesus Take The Heal",
		registerForRefresh = true,
		registerForDefaults = true
	}

	LAM:RegisterAddonPanel( "ScaffoldSettings", panelData )

	local optionsTable = {
		[1] = {
			type = 'dropdown',
			name = "Descend Key",
			tooltip = "Select the shortcut key you wish to use to descend downwards while using the scaffolding.",
			choices = { "-none-", "ALT", "COMMAND", "CTRL", "SHIFT" },
			getFunc = function() return Scaffold.Vars.Settings.DescendKey end,
			setFunc = function(value)
				Scaffold.Vars.Settings.DescendKey = value
				if Scaffold.Vars.Settings.DescendKey == Scaffold.Vars.Settings.SuspendKey then
					Scaffold.Vars.Settings.SuspendKey = "-none-"
				end
			end,
			default = Scaffold.SAVED_VARS_DEFAULTS.Settings.DescendKey,
			disabled = function() return false end,
		},
		[2] = {
			type = 'dropdown',
			name = "Suspend Key",
			tooltip = "Select the shortcut key you wish to use to suspend/resume the scaffolding.",
			choices = { "-none-", "ALT", "COMMAND", "CTRL", "SHIFT" },
			getFunc = function() return Scaffold.Vars.Settings.SuspendKey end,
			setFunc = function(value)
				Scaffold.Vars.Settings.SuspendKey = value
				if Scaffold.Vars.Settings.DescendKey == Scaffold.Vars.Settings.SuspendKey then
					Scaffold.Vars.Settings.DescendKey = "-none-"
				end
			end,
			default = Scaffold.SAVED_VARS_DEFAULTS.Settings.SuspendKey,
			disabled = function() return false end,
		}
	}

	LAM:RegisterOptionControls( "ScaffoldSettings", optionsTable )

end


function Scaffold.SlashCommand( commandArgs )

	local options = { }
    local searchResult = { string.match( commandArgs, "^(%S*)%s*(.-)$" ) }

    for i,v in pairs( searchResult ) do
        if( v ~= nil and v ~= "" ) then
            options[ #options + 1 ] = string.lower( v )
        end
    end

	d( " " )

	if 0 == #options or "on" == options[1] or "off" == options[1] or "toggle" == options[1] then

		Scaffold.ToggleState()
		return

	end

	if "sus" == options[1] == "sus" or "suspend" == options[1] or "pause" == options[1] or "resume" == options[1] then

		Scaffold.SuspendResume()
		return

	end

	d( "Unknown command. Available commands are:" )
	df( "%s - %s", Scaffold.SLASH_COMMAND_STRING, "Toggles scaffolding on/off." )
	df( "%s suspend - %s", Scaffold.SLASH_COMMAND_STRING, "Suspends/resumes scaffolding." )

end



function Scaffold.CloneTable( obj )

	if type( obj ) ~= 'table' then return obj end

	local res = {}
	for k, v in pairs( obj ) do res[ Scaffold.CloneTable( k ) ] = Scaffold.CloneTable( v ) end
	return res

end


function Scaffold.Distance2d( x1, z1, x2, z2 )

	return math.sqrt( ( ( x1 - x2 ) ^ 2 ) + ( ( z1 - z2 ) ^ 2 ) )

end


function Scaffold.Distance3d( x1, y1, z1, x2, y2, z2 )

	return math.sqrt( ( ( x1 - x2 ) ^ 2 ) + ( ( y1 - y2 ) ^ 2 ) + ( ( z1 - z2 ) ^ 2 ) )

end


function Scaffold.Reset()

	local items = Scaffold.Items
	local itemCount = 0

	if nil ~= items and #items > 0 then
		for _, item in ipairs( items ) do
			HousingEditorRequestChangePositionAndOrientation( item.Id, item.Original.X, item.Original.Y, item.Original.Z, item.Original.Pitch, item.Original.Yaw, item.Original.Roll )
			itemCount = itemCount + 1
		end

		Scaffold.Items = { }
	end

	return itemCount

end


function Scaffold.AddItem( newItem )

	if nil == newItem then return nil end

	for _, item in ipairs( Scaffold.Items ) do
		if( item.Id == newItem.Id ) then return nil end
	end

	table.insert( Scaffold.Items, newItem )

	return newItem

end


function Scaffold.SetupItems()

	local playerX, playerY, playerZ = GetPlayerWorldPositionInHouse()
	local item, link, lockedLink, measurements = nil, nil, nil, nil, nil
	local x, y, z, pitch, yaw, roll
	local matched = nil
	local id = nil

	Scaffold.Items = { }

	repeat
		id = GetNextPlacedHousingFurnitureId( id )

		if nil ~= id then
			link = GetPlacedFurnitureLink( id, LINK_STYLE_BRACKETS )
			matched = false

			if nil == lockedLink then
				for _, measure in pairs( Scaffold.ItemData ) do
					if measure.ItemLink == link then
						matched = true
						measurements = measure
						break
					end
				end
			elseif link == lockedLink then
				matched = true
			end

			if matched then
				x, y, z = HousingEditorGetFurnitureWorldPosition( id )
				distance = Scaffold.Distance3d( x, y, z, playerX, playerY, playerZ )

				if distance <= Scaffold.ITEM_MAX_DISTANCE then
					lockedLink = link
					item = Scaffold.CreateItem( id )

					if nil ~= item and nil ~= Scaffold.AddItem( item ) then
						if #Scaffold.Items >= Scaffold.ITEM_MAX_COUNT then break end
					end
				end
			end
		end
	until nil == id

	if Scaffold.ITEM_MIN_COUNT > #Scaffold.Items then
		df( "Failed to find %s usable scaffold items within %s meters.", tostring( Scaffold.ITEM_MIN_COUNT ), tostring( Scaffold.ITEM_MAX_DISTANCE / 100 ) )
		for _, i in pairs( Scaffold.ItemData) do
			df( "%s", i.ItemLink )
		end

		return false
	end

	Scaffold.ItemMeasurements = measurements

	return true

end


function Scaffold.ToggleState()

	if( 0 == GetCurrentZoneHouseId() ) then return end

	Scaffold.UpdateHandle = nil

	if Scaffold.STATE.ACTIVE == Scaffold.State then

		Scaffold.State = Scaffold.STATE.INACTIVE
		Scaffold.Reset()
		d( "Scaffolding is OFF." )
		df( "Restored scaffolding to its original position." )

		return

	end

	if Scaffold.SetupItems() then

		Scaffold.FirstUpdate = true
		Scaffold.FlagDescend = false
		Scaffold.FlagSuspend = false
		Scaffold.FlagSuspendPending = false
		Scaffold.PreviousPlayerY = nil
		Scaffold.State = Scaffold.STATE.ACTIVE
		Scaffold.QueueUpdate()

		d( "Scaffolding is ON." )

		local helpMsg = "Jump to ascend."
		if nil ~= Scaffold.Vars.Settings.DescendKey and "-none-" ~= Scaffold.Vars.Settings.DescendKey then
			helpMsg = helpMsg .. " Press " .. Scaffold.Vars.Settings.DescendKey .. " to descend."
		end
		if nil ~= Scaffold.Vars.Settings.SuspendKey and "-none-" ~= Scaffold.Vars.Settings.SuspendKey then
			helpMsg = helpMsg .. " Press " .. Scaffold.Vars.Settings.SuspendKey .. " to suspend/resume."
		end

		d( helpMsg )

	end

end


function Scaffold.SuspendResume()

	if( 0 == GetCurrentZoneHouseId() ) then return end

	Scaffold.FlagSuspend = not Scaffold.FlagSuspend

	if Scaffold.FlagSuspend then
		d( "Scaffolding suspended." )
	else
		d( "Scaffolding resumed." )
	end

end


function Scaffold.DescendDown()

	Scaffold.FlagDescend = true

end


function Scaffold.DescendUp()

	Scaffold.FlagDescend = false

end


function Scaffold.QueueUpdate()

	Scaffold.UpdateHandle = zo_callLater( Scaffold.OnUpdate, Scaffold.UPDATE_INTERVAL )

end


function Scaffold.IsDescendKeyPressed()

	local descendKey = Scaffold.Vars.Settings.DescendKey

	if "ALT" == descendKey and IsAltKeyDown() then
		return true
	elseif "COMMAND" == descendKey and IsCommandKeyDown() then
		return true
	elseif "CTRL" == descendKey and IsControlKeyDown() then
		return true
	elseif "SHIFT" == descendKey and IsShiftKeyDown() then
		return true
	else
		return false
	end

end


function Scaffold.IsSuspendKeyPressed()

	local suspendKey = Scaffold.Vars.Settings.SuspendKey

	if "ALT" == suspendKey and IsAltKeyDown() then
		return true
	elseif "COMMAND" == suspendKey and IsCommandKeyDown() then
		return true
	elseif "CTRL" == suspendKey and IsControlKeyDown() then
		return true
	elseif "SHIFT" == suspendKey and IsShiftKeyDown() then
		return true
	else
		return false
	end

end


-- Event Handlers


function Scaffold.OnUpdate( callHandle )

	if callHandle ~= Scaffold.UpdateHandle or Scaffold.STATE.ACTIVE ~= Scaffold.State or 0 == GetCurrentZoneHouseId() then return end

	local isSuspendKeyPressed = Scaffold.IsSuspendKeyPressed()

	if isSuspendKeyPressed then
		Scaffold.FlagSuspendPending = true
	elseif Scaffold.FlagSuspendPending then
		Scaffold.FlagSuspendPending = false
		Scaffold.FlagSuspend = not Scaffold.FlagSuspend

		if Scaffold.FlagSuspend then
			d( "Scaffolding suspended." )
		else
			d( "Scaffolding resumed." )
		end
	end

	local isDescendKeyPressed = Scaffold.IsDescendKeyPressed()

	if Scaffold.FlagSuspend or ( not Scaffold.FlagDescend and not isDescendKeyPressed and not IsPlayerMoving() ) then

		Scaffold.PreviousPlayerY = nil

	else

		local playerX, playerY, playerZ, playerHeading = GetPlayerWorldPositionInHouse()
		local minX, minY, minZ, maxX, maxY, maxZ = 0, 0, 0, 0, 0, 0
		local floorItem, nextItem1, nextItem2 = nil, nil, nil
		local floorItemIndex, floorItemDistance = nil, nil

		for index, item in ipairs( Scaffold.Items ) do
			item.X, item.Y, item.Z = HousingEditorGetFurnitureWorldPosition( item.Id )
			item.MinX, item.MinY, item.MinZ, item.MaxX, item.MaxY, item.MaxZ = HousingEditorGetFurnitureWorldBounds( item.Id )

			if playerX >= ( item.MinX - Scaffold.ItemMeasurements.MarginX ) and playerX <= ( item.MaxX + Scaffold.ItemMeasurements.MarginX ) and playerY >= ( item.MinY - Scaffold.ItemMeasurements.MarginY ) and playerY <= ( item.MaxY + Scaffold.ItemMeasurements.MarginY ) and playerZ >= ( item.MinZ - Scaffold.ItemMeasurements.MarginZ ) and playerZ <= ( item.MaxZ + Scaffold.ItemMeasurements.MarginZ ) then
				local distance = math.abs( Scaffold.Distance2d( item.X, item.Z, playerX, playerZ ) )

				if nil == floorItemDistance or distance < floorItemDistance then
					floorItemIndex = index
					floorItemDistance = distance
				end
			end
		end

		if nil == floorItemIndex then
			nextItem1 = Scaffold.Items[ 1 ]
			nextItem2 = Scaffold.Items[ 2 ]
		else
			floorItem = Scaffold.Items[ floorItemIndex ]

			if 1 == floorItemIndex then
				nextItem1 = Scaffold.Items[ 2 ]
				nextItem2 = Scaffold.Items[ 3 ]
			elseif 2 == floorItemIndex then
				nextItem1 = Scaffold.Items[ 1 ]
				nextItem2 = Scaffold.Items[ 3 ]
			else
				nextItem1 = Scaffold.Items[ 1 ]
				nextItem2 = Scaffold.Items[ 2 ]
			end
		end

		if Scaffold.FlagDescend or isDescendKeyPressed then

			for _, item in ipairs( Scaffold.Items ) do
				if 0 ~= item.X or 0 ~= item.Y or 0 ~= item.Z then
					HousingEditorRequestChangePosition( item.Id, 0, 0, 0 )
				end
			end

			Scaffold.PreviousPlayerY = playerY

		elseif Scaffold.FirstUpdate or nil == floorItem then

			if nil ~= Scaffold.PreviousPlayerY and playerY - Scaffold.PreviousPlayerY < Scaffold.ItemMeasurements.OffsetY then
				HousingEditorRequestChangePositionAndOrientation( nextItem1.Id, playerX, playerY + Scaffold.ItemMeasurements.OffsetY + ( playerY - Scaffold.PreviousPlayerY ), playerZ, 0, 0, 0 )
			else
				HousingEditorRequestChangePositionAndOrientation( nextItem1.Id, playerX, playerY + Scaffold.ItemMeasurements.OffsetY, playerZ, 0, 0, 0 )
			end

			Scaffold.PreviousPlayerY = playerY
			Scaffold.FirstUpdate = false

		else

			local deltaX, deltaZ = playerX - floorItem.X, playerZ - floorItem.Z
			local axisConstant, nextX, nextY, nextZ = 0, 0, 0, 0

			Scaffold.PreviousPlayerY = nil

			if math.abs( deltaX ) >= Scaffold.ItemMeasurements.ThresholdX then
				if deltaX > 0 then
					axisConstant = 1
				else
					axisConstant = -1
				end

				nextX, nextY, nextZ = floorItem.X + axisConstant * ( Scaffold.ItemMeasurements.X - Scaffold.ItemMeasurements.MarginX ), floorItem.Y, floorItem.Z
			else
				nextX, nextY, nextZ = 0, 0, 0
			end

			if nextX ~= nextItem1.X or nextY ~= nextItem1.Y or nextZ ~= nextItem1.Z then
				HousingEditorRequestChangePositionAndOrientation( nextItem1.Id, nextX, nextY, nextZ, 0, 0, 0 )
			end

			if math.abs( deltaZ ) >= Scaffold.ItemMeasurements.ThresholdZ then
				if deltaZ > 0 then
					axisConstant = 1
				else
					axisConstant = -1
				end

				nextX, nextY, nextZ = floorItem.X, floorItem.Y, floorItem.Z + axisConstant * ( Scaffold.ItemMeasurements.Z - Scaffold.ItemMeasurements.MarginZ )
			else
				nextX, nextY, nextZ = 0, 0, 0
			end

			if nextX ~= nextItem2.X or nextY ~= nextItem2.Y or nextZ ~= nextItem2.Z then
				HousingEditorRequestChangePositionAndOrientation( nextItem2.Id, nextX, nextY, nextZ, 0, 0, 0 )
			end

		end

	end

	Scaffold.QueueUpdate()

end


function Scaffold.OnAddOnLoaded( event, addonName )

	if( Scaffold.ADDON_NAME == addonName ) then
		EVENT_MANAGER:UnregisterForEvent( Scaffold.ADDON_NAME, EVENT_ADD_ON_LOADED )
		Scaffold.Initialize()
	end

end


-- Event Registration


EVENT_MANAGER:RegisterForEvent( Scaffold.ADDON_NAME, EVENT_ADD_ON_LOADED, Scaffold.OnAddOnLoaded )
