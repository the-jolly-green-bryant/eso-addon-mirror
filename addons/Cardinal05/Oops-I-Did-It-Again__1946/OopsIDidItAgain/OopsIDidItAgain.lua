-- Oops API


OopsAPI = { }


function OopsAPI.SuspendHistoryTracking( addonName )

	if nil == addonName or "" == addonName then return false end

	if OopsI.Vars.Verbose then 
		df( "Oops I Did It Again: History tracking suspended by add-on '%s'.", addonName )
	end

	OopsI.HistoryTrackingEnabled = false
	
	return true

end


function OopsAPI.ResumeHistoryTracking( addonName )

	if nil == addonName or "" == addonName then return false end

	if OopsI.Vars.Verbose then
		df( "Oops I Did It Again: History tracking resumed by add-on '%s'.", addonName )
	end

	OopsI.HistoryTrackingEnabled = true
	
	return true

end


-- Namespace


OopsI = { }


-- Member "Constants"


OopsI.ADDON_NAME = "OopsIDidItAgain"
OopsI.ADDON_VERSION = "1.0.2"

OopsI.SAVED_VARS_NAME = "OopsIDidItAgainSavedVars"
OopsI.SAVED_VARS_VERSION = 3
OopsI.SAVED_VARS_DEFAULTS = { Verbose = true, Houses = { }, MaxHouseHistory = 200 }

OopsI.OP = { }
OopsI.OP.PLACE = 1
OopsI.OP.REMOVE = 2
OopsI.OP.CHANGE = 3

OopsI.ONE_MORE_TIME = 400	-- Delay before follow-up housing editor operations (ms)


-- Member Variables


OopsI.Vars = { }
OopsI.HistoryTrackingEnabled = true
OopsI.PreviousEditorMode = nil
OopsI.PendingUndoRedo = false
OopsI.PendingHouseId = nil
OopsI.PendingFurniture = nil
OopsI.ReplacedFurnitureHistory = nil

OopsI.KeybindStrip = {
	{
		name = "Undo",
		keybind = "OOPSI_UNDO",
		callback = function() OopsI.Undo() end,
	},
	{
		name = "Redo",
		keybind = "OOPSI_REDO",
		callback = function() OopsI.Redo() end,
	},
	alignment = KEYBIND_STRIP_ALIGN_LEFT
}

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")


-- Methods : Utility


function OopsI.CloneTable( obj )

	if type( obj ) ~= 'table' then return obj end

	local res = {}
	for k, v in pairs( obj ) do res[ OopsI.CloneTable( k ) ] = OopsI.CloneTable( v ) end
	return res

end


function OopsI.Info( msg, ... )
	df( msg, ... )
end


function OopsI.Message( msg, ... )
	if OopsI.Vars.Verbose then df( msg, ... ) end
end


function OopsI.Error( msg, ... )
	df( msg, ... )
end


-- Methods : Initialization and Setup


function OopsI.Initialize()

	ZO_CreateStringId( "SI_BINDING_NAME_OOPSI_UNDO", "Oops, Oops! (Undo)" )
	ZO_CreateStringId( "SI_BINDING_NAME_OOPSI_REDO", "...Baby One More Time (Redo)" )

	OopsI.Vars = ZO_SavedVars:NewAccountWide( OopsI.SAVED_VARS_NAME, OopsI.SAVED_VARS_VERSION, nil, OopsI.SAVED_VARS_DEFAULTS )
	OopsI.SetupSettingsMenu()
	
	SLASH_COMMANDS[ "/oops" ] = OopsI.Undo
	SLASH_COMMANDS[ "/redo" ] = OopsI.Redo
	SLASH_COMMANDS[ "/undo" ] = OopsI.Undo
	SLASH_COMMANDS[ "/undohist" ] = OopsI.UndoHistory
	SLASH_COMMANDS[ "/undoclear" ] = OopsI.ClearUndoHistory

end


function OopsI.SetupSettingsMenu()

	local panelData = {
		type = "panel",
		name = "Oops I Did It Again",
		displayName = "Oops I Did It Again - Settings",
		author = "Jesus Take The Heal",
		version = OopsI.ADDON_VERSION,
		slashCommand = "/oopsset",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() for k, v in pairs( OopsI.SAVED_VARS_DEFAULTS ) do OopsI.Vars[ k ] = v end end
	}

	LAM:RegisterAddonPanel( "OopsISettings", panelData )

	local optionsTable = {
		[1] = {
			type = "button",
			name = "Clear All History",
			func = function() OopsI.ClearHistory() end,
			tooltip = "Clears all change history for all houses.",
			disabled = function() return false end,
			isDangerous = true,
			warning = "All change history for all houses will be lost.",
		},
		[2] = {
			type = "slider",
			name = "Maximum History per House",
			tooltip = "Controls the maximum number of furniture changes (Add/Remove/Move) to track, per house.",
			autoSelect = true,
			clampInput = true,
			decimals = 0,
			min = 20,
			max = 500,
			getFunc = function() return OopsI.Vars.MaxHouseHistory end,
			setFunc = function(value) OopsI.Vars.MaxHouseHistory = value end,
			default = OopsI.SAVED_VARS_DEFAULTS.MaxHouseHistory,
			disabled = function() return false end,
		},
		[3] = {
			type = "checkbox",
			name = "Show Undo/Redo in Chat",
			tooltip = "If ON, the result of Undo/Redo actions will be shown in the Chat window.",
			getFunc = function() return OopsI.Vars.Verbose end,
			setFunc = function(value) OopsI.Vars.Verbose = value end,
			default = OopsI.SAVED_VARS_DEFAULTS.Verbose,
			disabled = function() return false end,
		},
	}

	LAM:RegisterOptionControls( "OopsISettings", optionsTable )

end


-- Methods : Data Management


function OopsI.CreateHouse( houseId )

	return { HouseId = houseId, History = { }, HistoryIndex = nil }

end


function OopsI.CreateFurniture( furnitureId )

	if "string" == type( furnitureId ) then furnitureId = OopsI.FindFurnitureId( furnitureId ) end

	local link = GetPlacedFurnitureLink( furnitureId )

	if nil ~= link and "" ~= link then
		local x, y, z = HousingEditorGetFurnitureWorldPosition( furnitureId )
		local pitch, yaw, roll = HousingEditorGetFurnitureOrientation( furnitureId )

		return { Id = Id64ToString( furnitureId ), Link = link, State = { x, y, z, pitch, yaw, roll } }
	else
		return nil
	end

end


function OopsI.CreateHistory( op, oldFurniture, newFurniture )

	if nil == oldFurniture and nil == newFurniture then return nil end

	local furnitureId, link, oldState, newState = nil, nil

	if nil ~= oldFurniture then
		furnitureId, link, oldState = oldFurniture.Id, oldFurniture.Link, oldFurniture.State
	end

	if nil ~= newFurniture then
		if nil == furnitureId then furnitureId = newFurniture.Id end
		if nil == link then link = newFurniture.Link end
		newState = newFurniture.State
	end

	if OopsI.AreStatesEqual( oldState, newState ) then return nil end

	return { Op = op, Id = furnitureId, Link = link, OldState = oldState, NewState = newState }

end


function OopsI.AreStatesEqual( state1, state2 )

	if nil == state1 or nil == state2 then return false end

	for k, v in ipairs( state1 ) do
		if v ~= state2[ v ] then return false end
	end

	return true

end


function OopsI.AddHistory( history )

	if not OopsI.HistoryTrackingEnabled then return true end

	local house = OopsI.GetCurrentHouse()
	if nil == house or nil == history then return false end

	-- If changes have been undone, cull the newest changes back to the current Undo index.
	if nil ~= house.HistoryIndex and 1 < house.HistoryIndex then

		if #house.History < house.HistoryIndex then
			house.History = { }
		else
			for index = house.HistoryIndex - 1, 1, -1 do
				table.remove( house.History, index )
			end
		end

	end

	house.HistoryIndex = 1
	table.insert( house.History, 1, history )

	if nil == OopsI.Vars.MaxHouseHistory or 5 > OopsI.Vars.MaxHouseHistory then OopsI.Vars.MaxHouseHistory = 5 end

	while #house.History > OopsI.Vars.MaxHouseHistory do
		table.remove( house.History, #house.History )
	end

	return true

end


function OopsI.FindFurnitureId( furnitureId )

	local id = nil

	repeat
		id = GetNextPlacedHousingFurnitureId( id )
		if id ~= nil and Id64ToString( id ) == furnitureId then return id end
	until nil == id

	return nil

end


function OopsI.FindInventoryFurniture( furnitureLink )

	if nil ~= furnitureLink then

		local bagId = INVENTORY_BACKPACK
		local slots = GetBagSize( bagId )

		for index = 1, slots do
			if GetItemLink( bagId, index ) == furnitureLink then
				return bagId, index
			end
		end

	end

	return nil, nil

end


function OopsI.SubstituteFurnitureId( oldId, newId )

	local house = OopsI.GetCurrentHouse()
	if nil == house then return false end

	for _, history in ipairs( house.History ) do
		if history.Id == oldId then history.Id = newId end
	end

	return true

end


function OopsI.GetHouse( houseId )

	if nil == houseId or nil == OopsI or nil == OopsI.Vars or nil == OopsI.Vars.Houses then return nil end

	local house = OopsI.Vars.Houses[ houseId ]
	if nil == house then
		house = OopsI.CreateHouse( houseId )
		OopsI.Vars.Houses[ houseId ] = house
	end

	return house

end


function OopsI.GetCurrentHouse()

	if not OopsI.IsInHouse() then return nil end
	return OopsI.GetHouse( GetCurrentZoneHouseId() )

end


function OopsI.IsInHouse()

	local houseId = GetCurrentZoneHouseId()
	return nil ~= houseId and 0 < houseId and HasAnyEditingPermissionsForCurrentHouse()

end


function OopsI.ClearHistory()

	for houseId, house in pairs( OopsI.Vars.Houses ) do
		house.History = { }
		house.HistoryIndex = nil
	end

	OopsI.Info( "History has been cleared for all houses." )

end


-- Methods : User Functions


function OopsI.ClearUndoHistory()

	local house = OopsI.GetCurrentHouse()
	if nil == house or 0 >= #house.History then
		OopsI.Info( "No undo history." )
		return
	end

	house.History = { }
	house.HistoryIndex = nil
	OopsI.Info( "Undo history cleared for current house." )

end


function OopsI.UndoHistory()

	local house = OopsI.GetCurrentHouse()
	if nil == house or 0 >= #house.History then
		OopsI.Info( "No undo history." )
		return
	end

	local curIndex, curIndicator, op, history = tonumber( house.HistoryIndex or 0 ), "", "", nil
	for index = #house.History, 1, -1 do

		history = house.History[ index ]
		if curIndex == index then curIndicator = ">>" else curIndicator = "__" end

		if OopsI.OP.CHANGE == history.Op then op = "Changed"
		elseif OopsI.OP.PLACE == history.Op then op = "Placed"
		elseif OopsI.OP.REMOVED == history.Op then op = "Removed" end

		OopsI.Info( "%s %s. %s - %s", curIndicator, tostring( index ), op, history.Link )

	end

end


function OopsI.Undo()

	local result, msg = OopsI.UndoInt( false )

	if result and msg then OopsI.Message( msg )
	elseif not result and msg then OopsI.Error( msg ) end

	return result, msg

end


function OopsI.Redo()

	local result, msg = OopsI.RedoInt( false )

	if result and msg then OopsI.Message( msg )
	elseif not result and msg then OopsI.Error( msg ) end

	return result, msg

end


function OopsI.UndoInt( skipOnError )

	if OopsI.PendingUndoRedo then return false, "Undo or Redo in progress." end

	if nil == skipOnError then skipOnError = false end

	local house = OopsI.GetCurrentHouse()
	if nil == house then return false, "You do not own this home." end

	if nil == house.HistoryIndex then house.HistoryIndex = 1 end
	if 0 >= #house.History or #house.History < house.HistoryIndex then return false, "No more actions to undo." end

	local history = house.History[ house.HistoryIndex ]

	
	if OopsI.OP.CHANGE == history.Op then

	
		local furnitureId = OopsI.FindFurnitureId( history.Id )
		if nil == furnitureId then
			if not skipOnError then
				return false, "Changed furnishing not found: " .. history.Link .. " (" .. ( history.Id or "nil" ) .. ")"
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Changed furnishing not found: " .. history.Link .. " - action skipped."
			end
		end

		if nil == history.OldState then
			if not skipOnError then
				return false, "Furnishing change history invalid for: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Furnishing change history invalid for: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		local result = HousingEditorRequestChangePositionAndOrientation( furnitureId, history.OldState[1], history.OldState[2], history.OldState[3], history.OldState[4], history.OldState[5], history.OldState[6] )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to undo change to: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Failed to undo change to: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex + 1
		zo_callLater( function() OopsI.PendingUndoRedo = false end, OopsI.ONE_MORE_TIME )
		return true, "Change to " .. history.Link .. " undone."


	elseif OopsI.OP.PLACE == history.Op then

	
		local furnitureId = OopsI.FindFurnitureId( history.Id )
		if nil == furnitureId then
			if not skipOnError then
				return false, "Placed furnishing not found: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Placed furnishing not found: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		local result = HousingEditorRequestRemoveFurniture( furnitureId )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to remove: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Failed to remove: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex + 1
		return true, "Placement of " .. history.Link .. " undone."


	elseif OopsI.OP.REMOVE == history.Op then

	
		local bagId, slotIndex = OopsI.FindInventoryFurniture( history.Link )
		if nil == bagId or nil == slotIndex then
			if not skipOnError then
				return false, "Removed furnishing not found in inventory: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Removed furnishing not found in inventory: " .. history.Link .. " - action skipped."
			end
		end

		if nil == history.OldState then
			if not skipOnError then
				return false, "Furnishing change history invalid for: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Furnishing change history invalid for: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		OopsI.ReplacedFurnitureHistory = history
		local result = HousingEditorRequestItemPlacement( bagId, slotIndex, history.OldState[1], history.OldState[2], history.OldState[3], history.OldState[4], history.OldState[5], history.OldState[6] )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to place: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Failed to place: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex + 1
		return true, "Removal of " .. history.Link .. " undone."


	end

end


function OopsI.RedoInt( skipOnError )

	if OopsI.PendingUndoRedo then return false, "Undo or Redo in progress." end

	if nil == skipOnError then skipOnError = false end

	local house = OopsI.GetCurrentHouse()
	if nil == house then return false, "You do not own this home." end

	if nil == house.HistoryIndex then house.HistoryIndex = 1 end
	if 0 >= #house.History or 2 > house.HistoryIndex then return false, "No more actions to redo." end

	local history = house.History[ house.HistoryIndex - 1 ]

	if OopsI.OP.CHANGE == history.Op then

		local furnitureId = OopsI.FindFurnitureId( history.Id )
		if nil == furnitureId then
			if not skipOnError then
				return false, "Changed furnishing not found: " .. history.Link .. " (" .. ( history.Id or "nil" ) .. ")"
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Changed furnishing not found: " .. history.Link .. " - action skipped."
			end
		end

		if nil == history.NewState then
			if not skipOnError then
				return false, "Furnishing change history invalid for: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Furnishing change history invalid for: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		local result = HousingEditorRequestChangePositionAndOrientation( furnitureId, history.NewState[1], history.NewState[2], history.NewState[3], history.NewState[4], history.NewState[5], history.NewState[6] )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to redo change to: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Failed to redo change to: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex - 1
		zo_callLater( function() OopsI.PendingUndoRedo = false end, OopsI.ONE_MORE_TIME )
		return true, "Change to " .. history.Link .. " redone."


	elseif OopsI.OP.PLACE == history.Op then

	
		local bagId, slotIndex = OopsI.FindInventoryFurniture( history.Link )
		if nil == bagId or nil == slotIndex then
			if not skipOnError then
				return false, "Placed furnishing not found in inventory: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex + 1
				return true, "Placed furnishing not found in inventory: " .. history.Link .. " - action skipped."
			end
		end

		if nil == history.NewState then
			if not skipOnError then
				return false, "Furnishing change history invalid for: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Furnishing change history invalid for: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		OopsI.ReplacedFurnitureHistory = history
		local result = HousingEditorRequestItemPlacement( bagId, slotIndex, history.NewState[1], history.NewState[2], history.NewState[3], history.NewState[4], history.NewState[5], history.NewState[6] )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to replace: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Failed to replace: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex - 1
		return true, "Placement of " .. history.Link .. " redone."


	elseif OopsI.OP.REMOVE == history.Op then

	
		local furnitureId = OopsI.FindFurnitureId( history.Id )
		if nil == furnitureId then
			if not skipOnError then
				return false, "Furnishing not found: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Furnishing not found: " .. history.Link .. " - action skipped."
			end
		end

		OopsI.PendingUndoRedo = true
		local result = HousingEditorRequestRemoveFurniture( furnitureId )

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			OopsI.PendingUndoRedo = false
			if not skipOnError then
				return false, "Failed to redo remove: " .. history.Link
			else
				house.HistoryIndex = house.HistoryIndex - 1
				return true, "Failed to redo remove: " .. history.Link .. " - action skipped."
			end
		end

		house.HistoryIndex = house.HistoryIndex - 1
		return true, "Placement of " .. history.Link .. " undone."


	end


end


function OopsI.UpdateKeybindStrip()

	if HOUSING_EDITOR_MODE_SELECTION == GetHousingEditorMode() then
		KEYBIND_STRIP:AddKeybindButtonGroup( OopsI.KeybindStrip )
	else
		KEYBIND_STRIP:RemoveKeybindButtonGroup( OopsI.KeybindStrip )
	end

end


-- Methods : Event Handlers


function OopsI.OnUIModeChanged( event )

	if not OopsI.IsInHouse() then return end

	OopsI.UpdateKeybindStrip()

end


function OopsI.OnModeChanged( event, oldMode, newMode )

	if not OopsI.IsInHouse() then return end

	OopsI.UpdateKeybindStrip()

	local house = OopsI.GetCurrentHouse()
	local mode = GetHousingEditorMode()
	local id = HousingEditorGetSelectedFurnitureId()

	if HOUSING_EDITOR_MODE_PLACEMENT == mode then

		OopsI.PendingFurniture = OopsI.CreateFurniture( id )
		OopsI.PendingHouseId = house.HouseId

	elseif HOUSING_EDITOR_MODE_PLACEMENT == OopsI.PreviousEditorMode and nil ~= OopsI.PendingFurniture and OopsI.PendingHouseId == house.HouseId then

		local furniture = OopsI.CreateFurniture( OopsI.PendingFurniture.Id )
		if nil ~= furniture then

			local history = OopsI.CreateHistory( OopsI.OP.CHANGE, OopsI.PendingFurniture, furniture )
			if nil ~= history then OopsI.AddHistory( history ) end

		end

	end

	OopsI.PreviousEditorMode = mode

end


function OopsI.OnFurniturePlaced( event, furnitureId, collectibleId )

	if OopsI.PendingUndoRedo then

		if OopsI.ReplacedFurnitureHistory then
			OopsI.SubstituteFurnitureId( OopsI.ReplacedFurnitureHistory.Id, Id64ToString( furnitureId ) )
			OopsI.ReplacedFurnitureHistory = nil
		end

		zo_callLater( function() OopsI.PendingUndoRedo = false end, OopsI.ONE_MORE_TIME )
		return

	end

	if nil ~= furnitureId then

		local furniture = OopsI.CreateFurniture( furnitureId )
		if nil ~= furniture then

			local history = OopsI.CreateHistory( OopsI.OP.PLACE, nil, furniture )
			if nil ~= history then OopsI.AddHistory( history ) end

		end

	end

end


function OopsI.OnFurnitureRemoved( event, furnitureId, collectibleId )

	if OopsI.PendingUndoRedo then

		zo_callLater( function() OopsI.PendingUndoRedo = false end, OopsI.ONE_MORE_TIME )
		return

	end

	if nil ~= furnitureId and nil ~= OopsI.PendingFurniture and Id64ToString( furnitureId ) == OopsI.PendingFurniture.Id then

		local house = OopsI.GetCurrentHouse()
		if nil ~= house and OopsI.PendingHouseId == house.HouseId then

			local history = OopsI.CreateHistory( OopsI.OP.REMOVE, OopsI.PendingFurniture, nil )
			if nil ~= history then OopsI.AddHistory( history ) end

		end

	end

end


function OopsI.OnAddOnLoaded( event, addonName )

	if( OopsI.ADDON_NAME == addonName ) then
		EVENT_MANAGER:UnregisterForEvent( OopsI.ADDON_NAME, EVENT_ADD_ON_LOADED )
		OopsI.Initialize()
	end

end


-- Methods : Event Registration


EVENT_MANAGER:RegisterForEvent( OopsI.ADDON_NAME, EVENT_ADD_ON_LOADED, OopsI.OnAddOnLoaded )
EVENT_MANAGER:RegisterForEvent( OopsI.ADDON_NAME, EVENT_GAME_CAMERA_UI_MODE_CHANGED, OopsI.OnUIModeChanged )
EVENT_MANAGER:RegisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, OopsI.OnModeChanged )
EVENT_MANAGER:RegisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_PLACED, OopsI.OnFurniturePlaced )
EVENT_MANAGER:RegisterForEvent( OopsI.ADDON_NAME, EVENT_HOUSING_FURNITURE_REMOVED, OopsI.OnFurnitureRemoved )
