if not EHT then EHT = { } end
if not EHT.CT then EHT.CT = { } end	-- Change-Tracking Namespace

local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end
local abs, floor = math.abs, math.floor

-- Member Variables

EHT.CT.ReplacedFurnitureHistory = nil

-- Methods : Utility

function EHT.CT.Info( msg, ... )
	df( msg, ... )
end

function EHT.CT.Message( msg, ... )
	if EHT.SavedVars.ShowUndoRedoInChat then df( msg, ... ) end
end

function EHT.CT.Error( msg, ... )
	df( msg, ... )
end

-- Methods : Data Management

function EHT.CT.CreateHistory( op, oldFurniture, newFurniture, force )
	if nil == oldFurniture and nil == newFurniture then return nil end

	local furnitureId, link, oldState, newState = nil, nil, nil, nil

	if nil ~= oldFurniture then
		furnitureId, link, oldState = oldFurniture.Id, oldFurniture.Link, oldFurniture

		if nil ~= furnitureId and "" == ( link or "" ) then
			link = EHT.Housing.GetFurnitureLink( furnitureId )
		end
	end

	if nil ~= newFurniture then
		if nil == furnitureId then furnitureId = newFurniture.Id end
		newState = newFurniture

		if nil ~= furnitureId and  "" == ( link or "" ) then
			link = EHT.Housing.GetFurnitureLink( furnitureId )
		end
	end

	if not force and EHT.CT.AreStatesEqual( oldState, newState ) then return nil end

	if "string" ~= type( furnitureId ) then furnitureId = string.fromId64( furnitureId ) end

	local history = { Op = op, Id = furnitureId, Link = link }
	if nil ~= oldState then history.O = { oldState.X, oldState.Y, oldState.Z, oldState.Pitch, oldState.Yaw, oldState.Roll, oldState.EffectType, oldState.SizeX, oldState.SizeY, oldState.SizeZ, oldState.Color, oldState.Alpha, EHT.Util.CloneTable( oldState.MetaData ), oldState.Groups, oldState.Contrast, oldState.Speed, oldState.DelayTime } end
	if nil ~= newState then history.N = { newState.X, newState.Y, newState.Z, newState.Pitch, newState.Yaw, newState.Roll, newState.EffectType, newState.SizeX, newState.SizeY, newState.SizeZ, newState.Color, newState.Alpha, EHT.Util.CloneTable( newState.MetaData ), newState.Groups, newState.Contrast, newState.Speed, newState.DelayTime } end

	return history
end

function EHT.CT.ChangeFailed( history, id )
	if nil == history or nil == id then return false end
	if "string" ~= type( id ) then id = string.fromId64( id ) end

	if nil ~= history.Batch then
		for index, item in ipairs( history.Batch ) do
			if EHT.Housing.CompareIds( id, item.Id ) then
				table.remove( history.Batch, index )
				return true
			end
		end
	end

	return false
end

function EHT.CT.AreStatesEqual( state1, state2 )
	if nil == state1 or nil == state2 then return false end

	local id1, id2 = state1.Id, state2.Id
	if nil ~= id1 and "string" ~= type( id1 ) then id1 = string.fromId64( id1 ) end
	if nil ~= id2 and "string" ~= type( id2 ) then id2 = string.fromId64( id2 ) end

	if	id1 ~= id2 or
		state1.Link ~= state2.Link or
		floor( state1.X or 0 ) ~= floor( state2.X or 0 ) or 
		floor( state1.Y or 0 ) ~= floor( state2.Y or 0 ) or 
		floor( state1.Z or 0 ) ~= floor( state2.Z or 0 ) or 
		1 < abs( floor( state1.Pitch and 10000*state1.Pitch or 0 ) - floor( state2.Pitch and 10000*state2.Pitch or 0 ) ) or
		1 < abs( floor( state1.Yaw and 10000*state1.Yaw or 0 ) - floor( state2.Yaw and 10000*state2.Yaw or 0 ) ) or
		1 < abs( floor( state1.Roll and 10000*state1.Roll or 0 ) - floor( state2.Roll and 10000*state2.Roll or 0 ) ) or
		state1.EffectType ~= state2.EffectType or
		state1.SizeX ~= state2.SizeX or
		state1.SizeY ~= state2.SizeY or
		state1.SizeZ ~= state2.SizeZ or
		state1.Color ~= state2.Color or
		state1.Alpha ~= state2.Alpha or
		state1.Groups ~= state2.Groups or
		state1.Contrast ~= state2.Contrast or
		state1.Speed ~= state2.Speed or
		state1.DelayTime ~= state2.DelayTime then
		return false
	end

	local isMetaData1Valid = "table" == type( state1.MetaData )
	local isMetaData2Valid = "table" == type( state2.MetaData )
	if ( not isMetaData1Valid and isMetaData2Valid ) or ( isMetaData1Valid and not isMetaData2Valid ) then
		return false
	end

	if isMetaData1Valid and isMetaData2Valid then
		for key, value in pairs( state1.MetaData ) do
			if state2.MetaData[key] ~= value then
				return false
			end
		end
	end

	return true
end

function EHT.CT.AreHistoryEntriesEqual( h1, h2 )
	if "table" ~= type( h1 ) then
		return "table" ~= type( h2 )
	elseif "table" ~= type( h2 ) then
		return "table" ~= type( h1 )
	end

	for k, v in pairs( h1 ) do
		if h2[k] ~= v then
			return false
		end
	end

	for k, v in pairs( h2 ) do
		if h1[k] ~= v then
			return false
		end
	end

	return true
end

function EHT.CT.AddHistory( history )
	if not EHT.SavedVars.EnableHouseHistory then return true end
	if nil == history then return false end

	if nil == history.Batch then
		for i = 1, 6 do
			if ( nil ~= history.O and math.isnan( history.O[i] ) ) or ( nil ~= history.N and math.isnan( history.N[i] ) ) then return false, string.format( "Corrupt entry data. Field %d", i ) end
		end
	else
		for entryIndex, rec in pairs( history.Batch ) do
			for i = 1, 6 do
				if ( nil ~= rec.O and math.isnan( rec.O[i] ) ) or ( nil ~= rec.N and math.isnan( rec.N[i] ) ) then return false, string.format( "Corrupt batch entry data. Entry %d, Field %d", entryIndex, i ) end
			end
		end
	end

	local house = EHT.Data.GetCurrentHouse( true )
	if nil == house then return false, "Not in a player home." end

	-- If changes have been undone, cull the newest changes back to the current History Index.
	if nil ~= house.HistoryIndex and 1 < house.HistoryIndex then
		if #house.History < house.HistoryIndex then
			house.History = { }
		else
			for index = house.HistoryIndex - 1, 1, -1 do
				table.remove( house.History, index )
			end
		end
	end

	if nil == history.Batch and nil ~= history.O and history.Op == EHT.CONST.CHANGE_TYPE.CHANGE and 0 == history.O[1] and 0 == history.O[2] and 0 == history.O[3] then
		return false, "Invalid entry position."
	end

	house.HistoryIndex = 1
	table.insert( house.History, 1, EHT.Data.SerializeHistoryRecord( history ) )

	if nil == EHT.SavedVars.MaxHouseHistory or EHT.CONST.MIN_HOUSE_HISTORY > EHT.SavedVars.MaxHouseHistory then EHT.SavedVars.MaxHouseHistory = EHT.CONST.MIN_HOUSE_HISTORY end
	if EHT.CONST.MAX_HOUSE_HISTORY < EHT.SavedVars.MaxHouseHistory then EHT.SavedVars.MaxHouseHistory = EHT.CONST.MAX_HOUSE_HISTORY end

	while #house.History > EHT.SavedVars.MaxHouseHistory do
		table.remove( house.History, #house.History )
	end

	return true
end

function EHT.CT.GetHistoryEntry( index )
	if not EHT.SavedVars.EnableHouseHistory then return nil end

	local house = EHT.Data.GetCurrentHouse( true )
	if not house or not house.History then return nil end

	local historyEntry = house.History[index]
	if historyEntry then
		historyEntry = EHT.Data.DeserializeHistoryRecord( historyEntry )
	end
	return historyEntry
end

function EHT.CT.CreateSessionHistoryEntry()
	if not EHT.Housing.IsHouseZone() then return end

	local house = EHT.Data.GetCurrentHouse( true )
	if nil == house then return end

	local item, itemHistory, furnitureId
	local history = { Op = EHT.CONST.CHANGE_TYPE.CHANGE, Id = 0, Link = "New Session" }
	local batch = { }
	history.Batch = batch

	-- Remove any existing New Session entries.
	if type( house.History ) == "table" then
		for index = #house.History, 1, -1 do
			local history = EHT.Data.DeserializeHistoryRecord( house.History[index] )

			if history and "New Session" == history.Link then
				table.remove( house.History, index )
			end
		end
	end

	repeat
		furnitureId = EHT.Housing.GetNextFurnitureId( furnitureId )
		if furnitureId then
			item = EHT.Data.CreateFurniture( furnitureId )
			itemHistory = EHT.Util.CloneTable( item )
			table.insert( batch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemHistory, item, true ) )
		end
	until not furnitureId

	if 0 < #batch then
		EHT.CT.AddHistory( history )
		EHT.UI.RefreshHistory()
	end
end

function EHT.CT.SubstituteFurnitureId( oldId, newId )
	if nil == oldId or nil == newId then return false end
	if "string" ~= type( oldId ) then oldId = string.fromId64( oldId ) end
	if "string" ~= type( newId ) then newId = string.fromId64( newId ) end

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return false end

	if nil ~= house.History then
		local history, updated

		for index, h in ipairs( house.History ) do
			history = EHT.Data.DeserializeHistoryRecord( h )
			updated = false

			if history.Id == oldId then
				history.Id = newId
				updated = true
			end

			if nil ~= history.Batch then
				for _, subHistory in ipairs( history.Batch ) do
					if subHistory.Id == oldId then
						subHistory.Id = newId
						updated = true
						break
					end
				end
			end

			if updated then
				house.History[index] = EHT.Data.SerializeHistoryRecord( history )
			end
		end
	end

	if nil ~= house.Groups then
		for groupName, group in pairs( house.Groups ) do
			group = EHT.Data.DeserializeGroup( group )

			for _, item in ipairs( group ) do
				if oldId == item.Id then
					item.Id = newId
					break
				end
			end

			if groupName == EHT.CONST.GROUP_DEFAULT then
				house.Groups[groupName] = group
			else
				house.Groups[groupName] = EHT.Data.SerializeGroup( group )
			end
		end
	end

	if nil ~= house.Scenes then
		for _, scene in pairs( house.Scenes ) do
			if nil ~= scene.Group then
				for _, item in ipairs( scene.Group ) do
					if oldId == item.Id then
						item.Id = newId
						break
					end
				end
			end

			if nil ~= scene.Frames then
				for _, frame in ipairs( scene.Frames ) do
					if nil ~= frame.State then
						for _, state in ipairs( frame.State ) do
							if oldId == state.Id then
								state.Id = newId
								break
							end
						end
					end
				end
			end
		end
	end

	return true
end

function EHT.CT.ClearAllHistory()
	for houseId, house in pairs( EHT.Data.GetHouses() ) do
		house.History = { }
		house.HistoryIndex = nil
	end

	EHT.CT.CreateSessionHistoryEntry()
	EHT.CT.Info( "Change History has been cleared for all houses." )
	EHT.UI.RefreshHistory()
end

-- Methods : User Functions

function EHT.CT.ClearUndoHistory()
	local house = EHT.Data.GetCurrentHouse()
	if nil == house or 0 >= #house.History then
		EHT.CT.Info( "No change history." )
		return
	end

	house.History = { }
	house.HistoryIndex = nil

	EHT.CT.CreateSessionHistoryEntry()
	EHT.CT.Info( "Change History has been cleared for current house." )
	EHT.UI.RefreshHistory()
end

function EHT.CT.UndoHistory()
	local house = EHT.Data.GetCurrentHouse()
	if nil == house or 0 >= #house.History then
		EHT.CT.Info( "No change history." )
		return
	end

	EHT.CT.Info( " " )

	local curIndex, curIndicator, op, history = tonumber( house.HistoryIndex or 0 ), "", "", nil
	for index = #house.History, 1, -1 do
		history = EHT.Data.DeserializeHistoryRecord( house.History[ index ] )

		if curIndex == index then curIndicator = ">>" else curIndicator = "__" end

		if EHT.CONST.CHANGE_TYPE.CHANGE == history.Op then op = "Changed"
		elseif EHT.CONST.CHANGE_TYPE.PLACE == history.Op then op = "Placed"
		elseif EHT.CONST.CHANGE_TYPE.REMOVE == history.Op then op = "Removed" end

		EHT.CT.Info( "%s %s. %s - %s", curIndicator, tostring( index ), op, history.Link )
	end
end

function EHT.CT.Undo()
	if not EHT.SavedVars.EnableHouseHistory then df( "Please enable Change Tracking in the %s settings to use Undo.", EHT.ADDON_NAME ) return end
	EHT.Biz.Undo()
end

function EHT.CT.Redo()
	if not EHT.SavedVars.EnableHouseHistory then df( "Please enable Change Tracking in the %s settings to use Redo.", EHT.ADDON_NAME ) return end
	EHT.Biz.Redo()
end

function EHT.CT.UndoInt( history )
	local link = history.Link or ""

	if EHT.CONST.CHANGE_TYPE.CHANGE == history.Op then

		local furnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( history.Id )
		if nil == furnitureId then
			return false, "Changed furnishing not found: " .. link
		end

		local o = history.O
		if nil == o then
			return false, "Furnishing change history invalid for: " .. link
		end

		local result
		local newState = { Id = string.fromId64( furnitureId ), Link = link, X = o[1], Y = o[2], Z = o[3], Pitch = o[4], Yaw = o[5], Roll = o[6], EffectType = o[7], SizeX = o[8], SizeY = o[9], SizeZ = o[10], Color = o[11], Alpha = o[12], MetaData = o[13], Groups = o[14], Contrast = o[15], Speed = o[16], DelayTime = o[17], }
		local oldState = EHT.Data.CreateFurniture( furnitureId )

		if o[7] then
			EHT.Data.RestoreEffectRecord( furnitureId, o[7], o[1], o[2], o[3], o[4], o[5], o[6], o[8], o[9], o[10], o[11], o[12], o[14], o[13], o[15] )
			return true, "Change to " .. link .. " undone."
		elseif furnitureId and pathIndex then
			result = EHT.Housing.SetFurniturePathNodeInfo( furnitureId, pathIndex, o[1], o[2], o[3], o[5], o[16], o[17] )
			if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
				return false, string.format( "Failed to undo change to path node: %s (%d)", link or "", result or -1 )
			else
				EHT.Handlers.OnFurnitureChanged( newState, nil, "Undo" )
			end

			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback )
			return true, "Change to " .. link .. " undone."
		else
			result = EHT.Housing.SetFurniturePositionAndOrientation( furnitureId, o[1], o[2], o[3], o[4], o[5], o[6] )
			if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
				return false, "Failed to undo change to furnishing: " .. link
			else
				EHT.Handlers.OnFurnitureChanged( newState, nil, "Undo" )
			end

			EHT.Biz.ScheduleProcessActivity( EHT.Biz.UndoProcessCallback )
			return true, "Change to " .. link .. " undone."
		end

	elseif EHT.CONST.CHANGE_TYPE.PLACE == history.Op then

		if EHT.Housing.IsValidFurnitureId( history.Id, EHT.Housing.GetFurnitureLinkItemId( link ), link ) then
			--local furnitureId = EHT.Housing.FindFurnitureId( history.Id )
			--if nil == furnitureId then
				--return false, "Placed furnishing not found: " .. link
			--end

			local result = EHT.Housing.RemoveFurniture( furnitureId )
			if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
				return false, "Failed to remove: " .. link
			end
		end

		return true, "Placement of " .. link .. " undone."

	elseif EHT.CONST.CHANGE_TYPE.REMOVE == history.Op then

		if nil == history.O then
			return false, "Furnishing change history invalid for: " .. link
		end
		
		local furnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( history.Id )

		local effectTypeId = history.O[7]
		local result

		if effectTypeId then
			local o = history.O
			local r = EHT.Data.RestoreEffectRecord( history.Id, effectTypeId, o[1], o[2], o[3], o[4], o[5], o[6], o[8], o[9], o[10], o[11], o[12], o[14], o[13] )

			if r and r.Id then
				EHT.CT.ReplacedFurnitureHistory = history
				EHT.CT.OnFurniturePlaced( history.Id, r.Id )
			end

			result = HOUSING_REQUEST_RESULT_SUCCESS
		elseif furnitureId and pathIndex then
			local o = history.O

			local function callback()
				
			end

			result = EHT.Housing.PlacePathNode( callback, furnitureId, pathIndex, o[1], o[2], o[3], o[5], o[16], o[17] )
		else
			if not EHT.Housing.IsValidFurnitureId( history.Id, EHT.Housing.GetFurnitureLinkItemId( link ), link ) then
				local bagId, slotIndex = EHT.Housing.FindInventoryFurniture( link )
				local collectibleId = GetCollectibleIdFromLink( link )

				if bagId and slotIndex then
					EHT.CT.ReplacedFurnitureHistory = history
					result = EHT.Housing.PlaceItem( bagId, slotIndex, history.O[1], history.O[2], history.O[3], history.O[4], history.O[5], history.O[6] )
				elseif collectibleId and 0 ~= collectibleId then
					EHT.CT.ReplacedFurnitureHistory = history
					result = EHT.Housing.PlaceCollectible( collectibleId, history.O[1], history.O[2], history.O[3], history.O[4], history.O[5], history.O[6] )
				else
					return false, "Removed furnishing not found in your inventory, bank or storage containers: " .. link
				end
			else
				return false, "Item already removed."
			end
		end

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.CT.ReplacedFurnitureHistory = nil
			return false, "Failed to place: " .. link
		else
			EHT.Handlers.OnFurnitureChanged( { Id = furnitureId, X = history.O[1], Y = history.O[2], Z = history.O[3], Pitch = history.O[4], Yaw = history.O[5], Roll = history.O[6], EffectType = history.O[7], SizeX = history.O[8], SizeY = history.O[9], SizeZ = history.O[10], Color = history.O[11], Alpha = history.O[12], MetaData = history.O[13], Groups = history.O[14] }, nil, "Undo" )
		end

		--if effectTypeId then
			--return nil, "Removal of " .. link .. " undone."
		--else
		return true, "Removal of " .. link .. " undone."
		--end

	end

	return false, "Invalid change history record."
end

function EHT.CT.RedoInt( history )
	local link = history.Link or ""

	if EHT.CONST.CHANGE_TYPE.CHANGE == history.Op then

		local furnitureId = EHT.Housing.FindFurnitureId( history.Id )
		if nil == furnitureId then
			return false, "Changed furnishing not found: " .. link .. " (" .. ( history.Id or "nil" ) .. ")"
		end

		local n = history.N
		if nil == n then
			return false, "Furnishing change history invalid for: " .. link
		end

		local result
		local newState = EHT.Data.CreateFurniture( furnitureId )
		local oldState = { Id = string.fromId64( furnitureId ), Link = link, X = n[1], Y = n[2], Z = n[3], Pitch = n[4], Yaw = n[5], Roll = n[6], EffectType = n[7], SizeX = n[8], SizeY = n[9], SizeZ = n[10], Color = n[11], Alpha = n[12], MetaData = n[13], Groups = n[14] }

		if not EHT.CT.AreStatesEqual( oldState, newState ) then
			if n[7] then
				EHT.Data.RestoreEffectRecord( furnitureId, n[7], n[1], n[2], n[3], n[4], n[5], n[6], n[8], n[9], n[10], n[11], n[12], n[14], n[13] )
				return true, "Change to " .. link .. " redone."
			else
				result = EHT.Housing.SetFurniturePositionAndOrientation( furnitureId, n[1], n[2], n[3], n[4], n[5], n[6] )
				if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
					return false, "Failed to redo change to: " .. link
				else
					EHT.Handlers.OnFurnitureChanged( { Id = furnitureId, X = n[1], Y = n[2], Z = n[3], Pitch = n[4], Yaw = n[5], Roll = n[6] }, nil, "Redo" )
				end

				EHT.Biz.ScheduleProcessActivity( EHT.Biz.RedoProcessCallback )
				return true, "Change to " .. link .. " redone."
			end
		else
			return nil, link .. " has not changed."
		end


	elseif EHT.CONST.CHANGE_TYPE.PLACE == history.Op then

	
		if nil == history.N then
			return false, "Furnishing change history invalid for: " .. link
		end

		local effectTypeId = history.N[7]
		local result

		if effectTypeId then
			local n = history.N
			local r = EHT.Data.RestoreEffectRecord( history.Id, effectTypeId, n[1], n[2], n[3], n[4], n[5], n[6], n[8], n[9], n[10], n[11], n[12], n[14], n[13] )

			if r and r.Id then
				EHT.CT.ReplacedFurnitureHistory = history
				EHT.CT.OnFurniturePlaced( history.Id, r.Id )
			end

			result = HOUSING_REQUEST_RESULT_SUCCESS
		elseif EHT.Housing.IsItemLinkCollectible( link ) then
			local cId = EHT.Housing.GetFurnitureLinkItemId( link )
			if not cId or 0 == cId then
				return false, "Placed collectible is invalid: " .. ( link or "" )
			end

			EHT.CT.ReplacedFurnitureHistory = history

			result = EHT.Housing.PlaceCollectible( cId, history.N[1], history.N[2], history.N[3], history.N[4], history.N[5], history.N[6] )
		else
			local bagId, slotIndex = EHT.Housing.FindInventoryFurniture( link )
			if not bagId or not slotIndex then
				return false, "Placed furnishing not found in your inventory, bank or storage containers: " .. ( link or "" )
			end

			EHT.CT.ReplacedFurnitureHistory = history

			result = EHT.Housing.PlaceItem( bagId, slotIndex, history.N[1], history.N[2], history.N[3], history.N[4], history.N[5], history.N[6] )
		end

		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			EHT.CT.ReplacedFurnitureHistory = nil
			return false, "Failed to replace: " .. link
		else
			EHT.Handlers.OnFurnitureChanged( { Id = furnitureId, X = history.N[1], Y = history.N[2], Z = history.N[3], Pitch = history.N[4], Yaw = history.N[5], Roll = history.N[6], EffectType = history.N[7], SizeX = history.N[8], SizeY = history.N[9], SizeZ = history.N[10], Color = history.N[11], Alpha = history.N[12], MetaData = history.N[13], Groups = history.N[14] }, nil, "Redo" )
		end

		--if effectTypeId then
			--return nil, "Placement of " .. link .. " redone."
		--else
		return true, "Placement of " .. link .. " redone."
		--end


	elseif EHT.CONST.CHANGE_TYPE.REMOVE == history.Op then


		local furnitureId = EHT.Housing.FindFurnitureId( history.Id )
		if nil == furnitureId then
			return false, "Furnishing not found: " .. link
		end

		local result = EHT.Housing.RemoveFurniture( furnitureId )
		if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
			return false, "Failed to redo remove: " .. link
		end

		--if EHT.Housing.IsEffectId( furnitureId ) then
			--return nil, "Placement of " .. link .. " undone."
		--else
		return true, "Placement of " .. link .. " undone."
		--end


	end


	return false, "Invalid change history record."

end

-- Methods : Event Handlers

function EHT.CT.OnPlayerActivated()
	EHT.CT.CreateSessionHistoryEntry()
end

function EHT.CT.OnFurnitureChanged( item, itemBefore )
	if not EHT.SavedVars.EnableHouseHistory then return end
	local history = EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.CHANGE, itemBefore, item )
	if nil ~= history then EHT.CT.AddHistory( history ) end
end

function EHT.CT.OnFurniturePlaced( furnitureId, collectibleId, skipChangeTracking )
	if nil ~= furnitureId and EHT.SavedVars.EnableHouseHistory and EHT.Housing.IsOwner() then
		local furniture = nil
		if "table" == type( furnitureId ) then
			furniture = furnitureId
			furnitureId = furniture.Id
		else
			furniture = EHT.Data.CreateFurniture( furnitureId )
		end

		if EHT.Process == EHT.PROCESS_NAME.UNDO or EHT.Process == EHT.PROCESS_NAME.REDO or EHT.Process == EHT.PROCESS_NAME.RESET_FURNITURE then
			if EHT.CT.ReplacedFurnitureHistory then
				EHT.CT.SubstituteFurnitureId( EHT.CT.ReplacedFurnitureHistory.Id, furnitureId )
				EHT.CT.ReplacedFurnitureHistory = nil
			end

			return
		end

		if not skipChangeTracking and nil ~= furniture then
			local history = EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.PLACE, nil, furniture )
			if nil ~= history then EHT.CT.AddHistory( history ) end
		end
	end
end

function EHT.CT.OnFurnitureRemoved( furniture )
	if nil ~= furniture and EHT.SavedVars.EnableHouseHistory and EHT.Housing.IsOwner() then

		local house = EHT.Data.GetCurrentHouse()
		if nil ~= house then

			local history = EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.REMOVE, furniture, nil )
			if nil ~= history then EHT.CT.AddHistory( history ) end

		end
	end
end

-- Setup : Slash Command Registration

function EHT.CT.RegisterSlashCommands()
	SLASH_COMMANDS[ "/redo" ] = EHT.CT.Redo
	SLASH_COMMANDS[ "/undo" ] = EHT.CT.Undo
	SLASH_COMMANDS[ "/history" ] = EHT.CT.UndoHistory
	SLASH_COMMANDS[ "/clearhistory" ] = EHT.CT.ClearUndoHistory
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.ChangeTracking = true
