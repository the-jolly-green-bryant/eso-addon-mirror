if not EHT then EHT = { } end
if not EHT.Data then EHT.Data = { } end

local displayNameLower = string.lower( GetDisplayName() )

---[ Utilities : Data ]---

function EHT.Data.CreateHouse( houseId, houseKey )
	local obj
	if houseId then
		local collectibleId = GetCollectibleIdForHouse( houseId )
		local name = GetCollectibleName( collectibleId ) or ""
		local owner = GetCurrentHouseOwner()
		local isOwner = IsOwnerOfCurrentHouse()
		if isOwner then owner = nil end

		obj = { HouseId = houseId, CollectibleId = collectibleId, Name = name, Owner = owner, Groups = { }, History = { }, HistoryIndex = nil, Scenes = { } }
		obj.Groups[ EHT.CONST.GROUP_DEFAULT ] = { }
		houseKey = houseKey or houseId
		EHT.Data.GetHouses()[ houseKey ] = obj
		--EHT.UI.InsertCacheHubEntry( "OtherHomes", EHT.UI.CreateHubEntryRecord( obj ) )
		EHT.Data.FastInsertHouseLookup( houseKey, obj )
	end
	return obj
end

function EHT.Data.GetLocks()
	local locks = { }

	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return locks end

	locks = house.Locks
	if nil == locks then
		locks = { }
		house.Locks = locks
	end

	return locks
end

function EHT.Data.IsLocked( id )
	if nil == id then return false end

	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return false end

	local locks = house.Locks
	if nil == locks then return false end

	if "table" ~= type( id ) then
		if "string" ~= type( id ) then id = string.fromId64( id ) end
		return locks[ id ]
	else
		for _, item in ipairs( id ) do
			if locks[ item.Id ] then return true end
		end

		return false
	end
end

function EHT.Data.AreAllLocked( items )
	if nil == items or "table" ~= type( items ) then return false end

	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return false end

	local locks = house.Locks
	if nil == locks then return false end

	for _, item in ipairs( items ) do
		if not locks[ item.Id ] then return false end
	end

	return true
end

function EHT.Data.SetLock( id, locked, locks )
	if nil == locks then
		local house = EHT.Data.GetCurrentHouseRecord()
		if nil == house then return false end

		locks = house.Locks
		if nil == locks then locks = { } house.Locks = locks end
	end

	if nil == id or ( false ~= locked and true ~= locked ) then return false end
	if "string" ~= type( id ) then
		id = string.fromId64( id )
	end

	if locked then
		locks[ id ] = true
	else
		locks[ id ] = nil
	end

	return true
end

function EHT.Data.SetLocks( items, locked )
	if nil == items or ( false ~= locked and true ~= locked ) then return false end

	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return false end

	local locks = house.Locks
	if nil == locks then locks = { } house.Locks = locks end

	if "table" ~= type( items ) then
		local id = items
		EHT.Data.SetLock( id, locked, locks )
	else
		for _, item in ipairs( items ) do
			EHT.Data.SetLock( item.Id, locked, locks )
		end
	end

	return true
end

function EHT.Data.ResetLocks()
	local house = EHT.Data.GetCurrentHouseRecord()
	if nil == house then return false end

	house.Locks = { }
	EHT.UI.QueueRefreshLockedIndicators()

	return true
end

function EHT.Data.CreateScene( sceneName, houseId )
	local house, obj = nil, nil
	if nil == houseId then houseId = GetCurrentZoneHouseId() end

	house = EHT.Data.GetHouses()[ houseId ]
	sceneName = EHT.Util.Trim( string.lower( sceneName ) )

	if nil ~= house and nil ~= sceneName and "" ~= sceneName then
		obj = EHT.Data.GetScene( sceneName, houseId )
		if nil == obj then
			obj = { Name = sceneName, FrameIndex = 1, Loop = false, Group = { }, Frames = { } }
			house.Scenes[ sceneName ] = obj
		end
	end

	return obj
end

function EHT.Data.DeleteScene( sceneName )
	local house, obj = nil, nil
	local houseId = GetCurrentZoneHouseId()

	house = EHT.Data.GetHouses()[ houseId ]
	sceneName = EHT.Util.Trim( string.lower( sceneName ) )

	if nil ~= house and nil ~= sceneName and "" ~= sceneName then

		obj = house.Scenes[ sceneName ]
		house.Scenes[ sceneName ] = nil

	end

	EHT.Biz.OnAnimationChanged()
	return obj
end

function EHT.Data.CreateFrame( scene, frameIndex, frameDuration, houseId )
	local house, frame = nil, nil

	if nil == scene then
		if nil == houseId then houseId = GetCurrentZoneHouseId() end

		house = EHT.Data.GetHouses()[ houseId ]
		if nil == house or nil == house.Scenes then return nil end

		scene = house.Scenes[ EHT.CONST.SCENE_DEFAULT ]
		if nil == scene then return nil end
	end

	if nil == scene.Frames then scene.Frames = { } end
	if nil == frameDuration or EHT.CONST.SCENE_FRAME_DURATION_MIN > frameDuration or EHT.CONST.SCENE_FRAME_DURATION_MAX < frameDuration then frameDuration = EHT.CONST.SCENE_FRAME_DURATION_DEFAULT end

	if #scene.Frames >= EHT.CONST.SCENE_FRAME_COUNT_MAX then
		local msg = string.format( "Scene cannot exceed %d Frames.", EHT.CONST.SCENE_FRAME_COUNT_MAX )

		if EHT.RecordingSceneFrames then
			EHT.UI.ShowAlertDialog( "Recording Stopped", msg .. "\nRecording has been stopped automatically." )
			EHT.RecordingSceneFrames = false
		else
			EHT.UI.ShowAlertDialog( "Scene Frame Maximum Reached", msg )
		end

		return nil
	end

	frame = { Duration = frameDuration, State = { } }

	for index, item in ipairs( scene.Group ) do
		table.insert( frame.State, EHT.Data.CreateFurnitureState( item ) )
	end

	if frameIndex then
		table.insert( scene.Frames, frameIndex, frame )
	else
		table.insert( scene.Frames, frame )
	end

	return frame
end

function EHT.Data.GetTriggers()
	local houseId = GetCurrentZoneHouseId()
	if nil == houseId or 0 >= houseId or EHT.Data.IsHouseListEmpty() then return nil end

	local house = EHT.Data.GetCurrentHouseOrGuestHouseRecord()
	if nil == house then return nil end

	if nil == house.Triggers then house.Triggers = { } end
	return house.Triggers
end

function EHT.Data.GetTriggerByName( triggerName )
	local triggers = EHT.Data.GetTriggers()
	if not triggers or 0 >= #triggers then return nil end

	triggerName = string.lower( triggerName )

	for index, trigger in pairs( triggers ) do
		if string.lower( trigger.Name ) == triggerName then
			return trigger
		end
	end

	return nil
end

function EHT.Data.GetTriggerString( trigger )
	if nil == trigger then return nil end
	local desc, missingItem = "", ""
	local conditions = { }
	local actions = { }

	if nil ~= trigger.Name and "" ~= trigger.Name then
		if nil ~= trigger.Condition.FurnitureId and not EHT.Housing.IsValidFurnitureId( trigger.Condition.FurnitureId, trigger.Condition.ItemId ) then
			missingItem = " |cff3333(Missing Item(s)!)|r"
		else
			missingItem = ""
		end

		desc = string.format( "%s|r%s", trigger.Name, missingItem )
	end

	if nil ~= trigger.Condition.X and nil ~= trigger.Condition.Y and nil ~= trigger.Condition.Z then
		if nil ~= trigger.Condition.RadiusEnter then
			table.insert( conditions, string.format( " - YOU/GROUP ENTER %.2fm of {%d,%d,%d}", trigger.Condition.RadiusEnter, trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z ) )
		end

		if nil ~= trigger.Condition.RadiusExit then
			table.insert( conditions, string.format( " - YOU/GROUP LEAVE %.2fm of {%d,%d,%d}", trigger.Condition.RadiusExit, trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z ) )
		end
	end

	if nil ~= trigger.Condition.Emote then
		table.insert( conditions, string.format( " - YOU EMOTE %s", trigger.Condition.Emote ) )
	end

	if nil ~= trigger.Condition.QuickslotItem then
		table.insert( conditions, string.format( " - YOU USE %s from a Quickslot", trigger.Condition.QuickslotItem ) )
	end

	if nil ~= trigger.Condition.InteractTarget then
		table.insert( conditions, string.format( " - YOU INTERACT with %s", trigger.Condition.InteractTarget ) )
	end

	if nil ~= trigger.Condition.InCombat then
		table.insert( conditions, string.format( " - YOU %s combat", trigger.Condition.InCombat and "BEGIN" or "FINISH" ) )
	end

	if nil ~= trigger.Condition.PopulationChange then
		table.insert( conditions, string.format( " - A guest %s", 0 < trigger.Condition.PopulationChange and "ARRIVES" or "DEPARTS" ) )
	end

	if true == trigger.Condition.DayTime or true == trigger.Condition.DayTime2 then
		table.insert( conditions, string.format( " - it is DAY TIME" ) )
	elseif true == trigger.Condition.NightTime or true == trigger.Condition.NightTime2 then
		table.insert( conditions, string.format( " - it is NIGHT TIME" ) )
	end

	if nil ~= trigger.Condition.ItemId then
		local link = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId )
		local state = string.upper( trigger.Condition.State )
		local verb, s = "SETS"

		if "TOGGLED" == state then
			verb, state = "TOGGLES", ""
		end

		table.insert( conditions, string.format( " - ANYONE %s %s %s", verb, link, state ) )
	end

	if nil ~= trigger.Condition.X2 and nil ~= trigger.Condition.Y2 and nil ~= trigger.Condition.Z2 then
		if nil ~= trigger.Condition.RadiusEnter2 then
			table.insert( conditions, string.format( " - YOU/GROUP ENTER %.2fm of {%d,%d,%d}", trigger.Condition.RadiusEnter2, trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2 ) )
		end

		if nil ~= trigger.Condition.RadiusExit2 then
			table.insert( conditions, string.format( " - YOU/GROUP LEAVE %.2fm of {%d,%d,%d}", trigger.Condition.RadiusExit2, trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2 ) )
		end
	end

	if nil ~= trigger.Condition.Emote2 then
		table.insert( conditions, string.format( " - YOU EMOTE %s", trigger.Condition.Emote2 ) )
	end

	if nil ~= trigger.Condition.QuickslotItem2 then
		table.insert( conditions, string.format( " - YOU USE %s from a Quickslot", trigger.Condition.QuickslotItem2 ) )
	end

	if nil ~= trigger.Condition.InteractTarget2 then
		table.insert( conditions, string.format( " - YOU INTERACT with %s", trigger.Condition.InteractTarget2 ) )
	end

	if nil ~= trigger.Condition.InCombat2 then
		table.insert( conditions, string.format( " - YOU %s combat", trigger.Condition.InCombat2 and "BEGIN" or "FINISH" ) )
	end

	if nil ~= trigger.Condition.PopulationChange2 then
		table.insert( conditions, string.format( " - A guest %s", 0 < trigger.Condition.PopulationChange2 and "ARRIVES" or "DEPARTS" ) )
	end

	if nil ~= trigger.Condition.ItemId2 then
		local link = EHT.Housing.GetFurnitureItemIdLink( trigger.Condition.ItemId2 )
		local state = string.upper( trigger.Condition.State2 )
		local verb, s = "SETS"

		if "TOGGLED" == state then
			verb, state = "TOGGLES", ""
		end

		table.insert( conditions, string.format( " - ANYONE %s %s %s", verb, link, state ) )
	end

	if nil ~= trigger.Action.GroupName then
		if trigger.Action.GroupState == EHT.STATE.RESTORE then
			table.insert( actions, string.format( " - RESTORE the POSITION of items in selection \"%s\"", trigger.Action.GroupName ) )
		elseif trigger.Action.GroupState == EHT.STATE.TOGGLE then
			table.insert( actions, string.format( " - TOGGLE the STATE of items in selection \"%s\"", trigger.Action.GroupName ) )
		else
			table.insert( actions, string.format( " - SET the STATE of items in selection \"%s\" to \"%s\"", trigger.Action.GroupName, trigger.Action.GroupState ) )
		end
	end

	if nil ~= trigger.Action.SceneName then
		table.insert( actions, string.format( " - PLAY the scene \"%s\"", trigger.Action.SceneName ) )
	end

	if nil ~= trigger.TriggerIdAfter then
		local triggerAfter = EHT.Data.GetTriggerByUniqueId( trigger.TriggerIdAfter )

		if triggerAfter then
			table.insert( actions, string.format( " - RUN the actions of trigger \"%s\"", triggerAfter.Name ) )
		end
	end

	return string.format( "%s\n" ..
		"|ca9f9f9When...|cf9f9a9\n" ..
		"%s\n" ..
		"|ca9f9f9Then...|cf9f9a9\n" ..
		"%s|r", desc, table.concat( conditions, "\n" ), table.concat( actions, "\n" ) )
end

function EHT.Data.RefreshTriggerStates()
	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then return end

	for index, trigger in pairs( triggers ) do
		-- Build Trigger Phrase table.
		if nil ~= trigger.Condition.Phrase and "" ~= trigger.Condition.Phrase then
			table.insert( EHT.TriggerPhrases, string.lower( trigger.Condition.Phrase ) )
		end
	end
end

function EHT.Data.GetNextTriggerUniqueId()
	local uniqueId = EHT.SavedVars.LastTriggerUniqueId
	if nil == uniqueId then
		uniqueId = 10000
	else
		uniqueId = uniqueId + 1
	end
	EHT.SavedVars.LastTriggerUniqueId = uniqueId

	return uniqueId
end

function EHT.Data.GetTriggerByUniqueId( uniqueId )
	for _, house in pairs( EHT.Data.GetHouses() ) do
		if "table" == type( house.Triggers ) then
			for _, trigger in pairs( house.Triggers ) do
				if uniqueId == trigger.UniqueId then
					return trigger, house
				end
			end
		end
	end
end

function EHT.Data.SaveTrigger(
	triggerIndex,
	name,
	allowRecursion,
	triggerIdAfter,

	--[[ Conditions ]]--
	furnitureId, state,
	  --[[ or ]]--
	furnitureId2, state2,
	  --[[ or ]]--
	position, radiusEnter, radiusExit,
	  --[[ or ]]--
	position2, radiusEnter2, radiusExit2,
	  --[[ or ]]--
	emoteSlashName,
	  --[[ or ]]--
	quickslotItem,
	  --[[ or ]]--
	interactTarget,
	  --[[ or ]]--
	inCombat,
	  --[[ or ]]--
	populationChange,
	  --[[ or ]]--
	phrase,
	  --[[ or ]]--
	dayTime, dayTime2,
	  --[[ or ]]--
	nightTime, nightTime2,

	--[[ Actions ]]--
	groupName, groupState,
	  --[[ and/or ]]--
	sceneName )

	local itemId, furnitureIdString = nil, nil
	local itemId2, furnitureId2String = nil, nil

	local house = EHT.Data.GetCurrentHouse()
	if nil == house then return nil end

	local triggers = EHT.Data.GetTriggers()
	if nil == triggers then return nil end


	-- Validate parameters.


	if nil == allowRecursion then allowRecursion = false end


	if nil ~= phrase then
		phrase = EHT.Util.Trim( phrase )
		if nil == phrase then phrase = nil end
	end


	if nil == name or "" == name then
		return nil, nil, string.format( "Trigger description is required." )
	end

	local lowerName = string.lower( EHT.Util.Trim( name ) )

	for index, trigger in pairs( triggers ) do
		if ( nil == triggerIndex or index ~= triggerIndex ) and string.lower( EHT.Util.Trim( trigger.Name ) ) == lowerName then
			return nil, nil, string.format( "Trigger description is already in use by another trigger:\n%s", trigger.Name )
		end
	end


	if nil ~= triggerIdAfter then
		local triggerAfter, triggerHouse = EHT.Data.GetTriggerByUniqueId( triggerIdAfter )

		if nil == triggerAfter then
			return nil, nil, string.format( "Trigger specified to run after completion is invalid." )
		elseif triggerHouse ~= house then
			return nil, nil, string.format( "Trigger specified to run after completion is not from this House." )
		end
	end


	if nil ~= emoteSlashName then emoteSlashName = string.lower( emoteSlashName ) end


	local conditions = 0
	local conditionList = { }


	if nil ~= furnitureId then conditions = conditions + 1 table.insert( conditionList, "Toggled furniture" ) end
	if nil ~= furnitureId2 then conditions = conditions + 1 table.insert( conditionList, "Toggled furniture" ) end
	if nil ~= position then conditions = conditions + 1 table.insert( conditionList, "Location" ) end
	if nil ~= position2 then conditions = conditions + 1 table.insert( conditionList, "Location" ) end
	if nil ~= emoteSlashName then conditions = conditions + 1 table.insert( conditionList, "Emote" ) end
	if nil ~= quickslotItem then conditions = conditions + 1 table.insert( conditionList, "Quickslot" ) end
	if nil ~= interactTarget then conditions = conditions + 1 table.insert( conditionList, "Interactive target" ) end
	if nil ~= inCombat then conditions = conditions + 1 table.insert( conditionList, "Combat" ) end
	if nil ~= populationChange then conditions = conditions + 1 table.insert( conditionList, "Guest arrives/departs" ) end
	if nil ~= phrase then conditions = conditions + 1 table.insert( conditionList, "Phrase" ) end
	if dayTime then conditions = conditions + 1 table.insert( conditionList, "DayTime" ) end
	if dayTime2 then conditions = conditions + 1 table.insert( conditionList, "DayTime" ) end
	if nightTime then conditions = conditions + 1 table.insert( conditionList, "NightTime" ) end
	if nightTime2 then conditions = conditions + 1 table.insert( conditionList, "NightTime" ) end


	if 0 == conditions then
		return nil, nil, string.format( "A condition type must be selected." )
	end

	if 2 < conditions then
		return nil, nil, string.format(
			"More than 2 condition types have been selected.\n" ..
			"Please select a maximum of 2 conditions:\n\n" ..
			table.concat( conditionList, "; or,\n" ) )
	end


	if nil ~= furnitureId and nil == state then
		return nil, nil, string.format( "A state must be selected for the trigger condition furniture item." )
	end

	if nil ~= state and not EHT.Util.IsListValue( EHT.STATE, state ) then
		return nil, nil, string.format( "Invalid trigger condition state selected: %s", tostring( state ) or "nil" )
	end


	if nil ~= furnitureId2 and nil == state2 then
		return nil, nil, string.format( "A state must be selected for the trigger condition furniture item." )
	end

	if nil ~= state2 and not EHT.Util.IsListValue( EHT.STATE, state2 ) then
		return nil, nil, string.format( "Invalid trigger condition state selected: %s", tostring( state2 ) or "nil" )
	end


	if nil ~= position and ( nil == position.X or nil == position.Y or nil == position.Z ) then
		return nil, nil, string.format( "Invalid trigger condition location. Please select a new location." )
	end

	if nil ~= position and ( nil == radiusEnter and nil == radiusExit ) then
		return nil, nil, string.format( "A radius is required for the trigger condition location." )
	end

	if nil ~= position and ( nil ~= radiusEnter and nil ~= radiusExit ) then
		return nil, nil, string.format( "Enter and Leave radius values cannot be entered; please enter only one." )
	end

	if nil ~= position and nil ~= radiusEnter and "number" ~= type( radiusEnter ) then
		return nil, nil, string.format( "Trigger condition Radius is invalid or non-numeric." )
	end

	if nil ~= position and nil ~= radiusExit and "number" ~= type( radiusExit ) then
		return nil, nil, string.format( "Trigger condition Radius is invalid or non-numeric." )
	end


	if nil ~= position2 and ( nil == position2.X or nil == position2.Y or nil == position2.Z ) then
		return nil, nil, string.format( "Invalid trigger condition location. Please select a new location." )
	end

	if nil ~= position2 and ( nil == radiusEnter2 and nil == radiusExit2 ) then
		return nil, nil, string.format( "A radius is required for the trigger condition location." )
	end

	if nil ~= position2 and ( nil ~= radiusEnter2 and nil ~= radiusExit2 ) then
		return nil, nil, string.format( "Enter and Leave radius values cannot be entered; please enter only one." )
	end

	if nil ~= position2 and nil ~= radiusEnter2 and "number" ~= type( radiusEnter2 ) then
		return nil, nil, string.format( "Trigger condition Radius is invalid or non-numeric." )
	end

	if nil ~= position2 and nil ~= radiusExit2 and "number" ~= type( radiusExit2 ) then
		return nil, nil, string.format( "Trigger condition Radius is invalid or non-numeric." )
	end


	if nil ~= emoteSlashName and nil == EHT.Util.GetEmoteIndexBySlashName( emoteSlashName ) then
		return nil, nil, string.format( "Invalid emote: %s", emoteSlashName )
	end
	
	
	if  ( true == dayTime and true == dayTime2 ) or
		( true == nightTime and true == nightTime2 ) or
		( ( true == dayTime or true == dayTime2 ) and ( true == nightTime or true == nightTime2 ) ) then
		return nil, nil, string.format( "Triggers cannot have multiple Time of Day conditions." )
	end


	if nil == groupName and nil == sceneName and triggerIdAfter == nil then
		return nil, nil, string.format( "A trigger action must be selected:\nSelection State update, Animation Scene and/or Activation Trigger." )
	end


	if nil ~= groupName and nil == groupState then
		return nil, nil, string.format( "A trigger action state must be selected for the Saved Selection." )
	end

	if nil ~= groupState then
		if not EHT.Util.IsListValue( EHT.STATE, groupState ) then
			return nil, nil, string.format( "Invalid trigger action state selected: %s", tostring( groupState ) or "nil" )
		end
	end

	if nil ~= groupName then
		groupName = EHT.Util.Trim( string.lower( groupName ) )
		if nil == EHT.Data.GetGroup( groupName ) then
			return nil, nil, string.format( "Invalid trigger action Saved Selection: %s", groupName or "nil" )
		end
	end


	if nil ~= sceneName then
		sceneName = EHT.Util.Trim( string.lower( sceneName ) )
		if nil == EHT.Data.GetScene( sceneName ) then
			return nil, nil, string.format( "Invalid trigger action Animation Scene: %s", sceneName or "nil" )
		end
	end


	if nil ~= furnitureId then

		if "string" ~= type( furnitureId ) then
			furnitureIdString = string.fromId64( furnitureId )
		else
			furnitureIdString = furnitureId
		end

		furnitureId = EHT.Housing.FindFurnitureId( furnitureId )
		if nil == furnitureId or nil == furnitureIdString then
			return nil, nil, string.format( "Invalid trigger condition furniture item selected." )
		end

		itemId = EHT.Housing.GetFurnitureItemId( furnitureId )

	end


	if nil ~= furnitureId2 then

		if "string" ~= type( furnitureId2 ) then
			furnitureId2String = string.fromId64( furnitureId2 )
		else
			furnitureId2String = furnitureId2
		end

		furnitureId2 = EHT.Housing.FindFurnitureId( furnitureId2 )
		if nil == furnitureId2 or nil == furnitureId2String then
			return nil, nil, string.format( "Invalid trigger condition furniture item selected." )
		end

		itemId2 = EHT.Housing.GetFurnitureItemId( furnitureId2 )

	end

	---- Construct Trigger object.

	local trigger = { Name = name, Recursion = allowRecursion, TriggerIdAfter = triggerIdAfter, Condition = { }, Action = { } }

	-- Conditions

	if dayTime then
		trigger.Condition.DayTime = true
	elseif dayTime2 then
		trigger.Condition.DayTime2 = true
	elseif nightTime then
		trigger.Condition.NightTime = true
	elseif nightTime2 then
		trigger.Condition.NightTime2 = true
	end

	if nil ~= furnitureIdString then
		trigger.Condition.FurnitureId = furnitureIdString
		trigger.Condition.ItemId = itemId
		trigger.Condition.State = state
	end

	if nil ~= furnitureId2String then
		trigger.Condition.FurnitureId2 = furnitureId2String
		trigger.Condition.ItemId2 = itemId2
		trigger.Condition.State2 = state2
	end

	if nil ~= position then
		trigger.Condition.X, trigger.Condition.Y, trigger.Condition.Z = position.X, position.Y, position.Z
		trigger.Condition.RadiusEnter = radiusEnter
		trigger.Condition.RadiusExit = radiusExit
	end

	if nil ~= position2 then
		trigger.Condition.X2, trigger.Condition.Y2, trigger.Condition.Z2 = position2.X, position2.Y, position2.Z
		trigger.Condition.RadiusEnter2 = radiusEnter2
		trigger.Condition.RadiusExit2 = radiusExit2
	end

	if nil ~= emoteSlashName then
		trigger.Condition.Emote = emoteSlashName
	end

	if nil ~= quickslotItem then
		trigger.Condition.QuickslotItem = quickslotItem
	end

	if nil ~= interactTarget then
		trigger.Condition.InteractTarget = interactTarget
	end

	if nil ~= inCombat then
		trigger.Condition.InCombat = inCombat
	end

	if nil ~= populationChange then
		trigger.Condition.PopulationChange = populationChange
	end

	if nil ~= phrase then
		trigger.Condition.Phrase = phrase
	end

	-- Actions

	if nil == groupName and nil == sceneName and nil == triggerIdAfter then
		return nil, nil, string.format( "Invalid trigger action Saved Selection, Animation Scene or Activated Trigger." )
	end

	if nil ~= groupName then
		trigger.Action.GroupName, trigger.Action.GroupState = groupName, groupState
	end

	if nil ~= sceneName then
		trigger.Action.SceneName = sceneName
	end

	-- Initial State

	trigger.ConditionMet = false
	trigger.Condition2Met = false
	trigger.PreviousState = nil
	trigger.PreviousState2 = nil
	trigger.PreviouslyDayTime = nil

	-- Insert new, or update existing, Trigger

	local triggerName = string.lower( EHT.Util.Trim( trigger.Name ) )

	if nil ~= triggerIndex and nil ~= triggers[ triggerIndex ] and string.lower( EHT.Util.Trim( triggers[ triggerIndex ].Name ) ) == triggerName then
		trigger.UniqueId = triggers[ triggerIndex ].UniqueId
	else
		triggerIndex = nil
		trigger.UniqueId = nil
	end

	if nil == trigger.UniqueId then
		trigger.UniqueId = EHT.Data.GetNextTriggerUniqueId()
	end

	if nil == triggerIndex then
		triggerIndex = #triggers + 1
		table.insert( triggers, triggerIndex, trigger )
		EssentialHousingHub:IncUMTD("n_trg", 1)
	else
		triggers[ triggerIndex ] = trigger
	end

	EHT.Data.RefreshTriggerStates()

	return trigger, triggerIndex, nil
end

function EHT.Data.DeleteTrigger( trigger )
	if nil == trigger then return nil end

	local houseId = GetCurrentZoneHouseId()
	if 0 >= houseId or nil == houseId then return nil end

	local house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then return nil end

	local triggers = house.Triggers

	if "number" == type( trigger ) then
		for index, trig in pairs( triggers ) do
			if index == trigger then
				table.remove( triggers, index )
				return trig
			end
		end
	elseif "table" == type( trigger ) then
		for index, trig in pairs( triggers ) do
			if trig == trigger then
				table.remove( triggers, index )
				return trig
			end
		end
	end
end

function EHT.Data.DeleteAllTriggers()
	local houseId = GetCurrentZoneHouseId()
	if 0 >= houseId or nil == houseId then return nil end

	local house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then return nil end

	house.Triggers = { }
end

function EHT.Data.CreateFurniture( furnitureId, x, y, z, pitch, yaw, roll, speed, delayTime )
	local obj = nil
	if nil ~= furnitureId then
		local itemId, collectibleId, link, name, icon

		if not x or not y or not z then
			x, y, z, pitch, yaw, roll, itemId, collectibleId, link, name, icon = EHT.Housing.GetFurnitureInfo( furnitureId )
		else
			pitch, yaw, roll = pitch or 0, yaw or 0, roll or 0
			_, _, _, _, _, _, itemId, collectibleId, link, name, icon = EHT.Housing.GetFurnitureInfo( furnitureId )
		end

		if not speed or not delayTime then
			local pathFurnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( furnitureId )
			if pathFurnitureId and pathIndex then
				local pathX, pathY, pathZ, pathHeading, pathSpeed, pathDelayTime = EHT.Housing.GetFurniturePathNodeInfo( pathFurnitureId, pathIndex )
				x, y, z, yaw, speed, delayTime = x or pathX, y or pathY, z or pathZ, yaw or pathHeading, speed or pathSpeed, delayTime or pathDelayTime
			end
		end

		if nil ~= x then
			local idString = "string" == type( furnitureId ) and furnitureId or string.fromId64( furnitureId )

			obj = {
				Id = idString,
				CollectibleId = collectibleId,
				Link = link,
				Icon = icon,
				X = x,
				Y = y,
				Z = z,
				Pitch = pitch,
				Yaw = yaw,
				Roll = roll,
				Speed = speed,
				DelayTime = delayTime,
			}

			local effect = EHT.Data.GetEffectRecordById( tonumber( furnitureId ) )
			if effect then
				obj.EffectType = effect.EffectType
				obj.SizeX, obj.SizeY, obj.SizeZ = effect.SizeX, effect.SizeY, effect.SizeZ
				obj.Color, obj.Alpha, obj.Contrast = effect.Color, effect.Alpha or 1, effect.Contrast or 1
				obj.MetaData = EHT.Util.CloneTable( effect.MetaData )
			end
		end
	end

	return obj
end

function EHT.Data.CreateFurnitureState( furniture )
	local obj = nil

	if nil ~= furniture then
		local id = nil

		if "table" == type( furniture ) then
			id = furniture.Id
		else
			id = furniture
		end

		if nil ~= id then
			--local x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha, metaData = EHT.Housing.GetKnownFurniturePositionAndOrientation( id )
			local x, y, z, pitch, yaw, roll = EHT.Housing.GetFurniturePositionAndOrientation( id )
			local state
			if not EHT.Housing.IsEffectId( id ) then state = EHT.Housing.GetFurnitureState( id ) end

			obj = {
				Id = furniture.Id,
				X = x,
				Y = y,
				Z = z,
				Pitch = pitch,
				Yaw = yaw,
				Roll = roll,
				State = state,
				SizeX = sizeX,
				SizeY = sizeY,
				SizeZ = sizeZ,
				Color = color,
				Alpha = alpha,
				MetaData = metaData,
			}
		else
			obj = {
				Id = furniture.Id,
				X = furniture.X,
				Y = furniture.Y,
				Z = furniture.Z,
				Pitch = furniture.Pitch,
				Yaw = furniture.Yaw,
				Roll = furniture.Roll,
				State = furniture.State,
				SizeX = furniture.SizeX,
				SizeY = furniture.SizeY,
				SizeZ = furniture.SizeZ,
				Color = furniture.Color,
				Alpha = furniture.Alpha,
				MetaData = EHT.Util.CloneTable( furniture.MetaData ),
			}
		end
	end

	return obj
end

function EHT.Data.GetCurrentHouseRecord()
	local houseId = GetCurrentZoneHouseId()
	if nil ~= houseId and 0 < houseId then
		return EHT.Data.GetHouses()[ houseId ]
	end
end

function EHT.Data.GetHouseKey( houseId, owner )
	houseId = tonumber( houseId )
	if owner and "" ~= owner and displayNameLower ~= string.lower( owner ) then
		return string.format( "%d%s", houseId, owner )
	end
	return houseId
end

do
	local houseKeyCache

	function EHT.Data.ClearHouseLookupCache()
		houseKeyCache = nil
	end
	
	function EHT.Data.BuildHouseLookupCache()
		houseKeyCache = {}
		for houseKey, houseRecord in pairs( EHT.Data.GetHouses() ) do
			if "string" == type( houseKey ) then
				houseKeyCache[string.lower( houseKey )] = houseRecord
			end
		end
	end
	
	function EHT.Data.FastInsertHouseLookup( houseKey, houseRecord )
		if not houseKeyCache then
			EHT.Data.BuildHouseLookupCache()
		end

		if "string" == type( houseKey ) then
			houseKeyCache[string.lower( houseKey )] = houseRecord
		end
	end

	function EHT.Data.LookupHouseRecord( houseId, owner )
		if not houseKeyCache then
			EHT.Data.BuildHouseLookupCache()
		end

		local houseKey = EHT.Data.GetHouseKey( houseId, owner )
		return "string" == type( houseKey ) and houseKeyCache[string.lower( houseKey )] or EHT.Data.GetHouses()[houseKey]
	end
end

function EHT.Data.GetCurrentHouseOrGuestHouseRecord(houseId, owner, showMessage)
	EHT.Data.GetOrCreateHouseList()

	if "" == owner then
		owner = nil
	end
	
	if not houseId or not owner then
		local currentOwner, currentHouseId = EHT.Housing.GetHouseOwner()
		houseId, owner = houseId or currentHouseId, owner or currentOwner
	end

	if 0 >= houseId then
		if showMessage then
			d("Must be in a player house.")
			EHT.UI.PlaySoundFailure()
		end

		return nil
	end

	local houseKey = EHT.Data.GetHouseKey(houseId, owner)
	local house = EHT.Data.LookupHouseRecord(houseId, owner)
	if not house then
		house = EHT.Data.CreateHouse(houseId, houseKey)
	end

	return house, houseId, owner
end

function EHT.Data.GetCurrentHouseOrGuestHouse(houseId, owner, showMessage)
	local house
	house, houseId, owner = EHT.Data.GetCurrentHouseOrGuestHouseRecord(houseId, owner, showMessage)

	local effects, ts = EHT.Data.GetHouseEffectsAndTimestamp(houseId, owner)
	return house, effects, ts
end

function EHT.Data.GetHouseEffectsAndTimestamp(houseId, owner)
	local effects, ts
	if "string" == type(owner) and "" ~= owner and string.lower(owner) ~= displayNameLower then
		local communityRecord = EssentialHousingHub:GetCommunityHouseFXRecord(owner, EHT.Util.GetWorldCode(), houseId)
		if communityRecord and "table" == type(communityRecord.Effects) then
			local communityTimestamp = tonumber(communityRecord.TS)
			if communityTimestamp then
				effects = EHT.Util.CloneTable(communityRecord.Effects)
				ts = communityTimestamp
			end
		end
	end

	local house = EHT.Data.LookupHouseRecord(houseId, owner)
	if house then
		local houseEffects = house.Effects
		if houseEffects then
			local houseTimestamp = tonumber(house.EffectsTimestamp)
			if not ts or (houseTimestamp and houseTimestamp > ts) then
				effects = houseEffects
				ts = houseTimestamp
			end
		end
	end

	return effects, ts
end

function EHT.Data.GetCurrentHouseRecords()
	local house, group, scene = nil, nil, nil

	local houseId = GetCurrentZoneHouseId()
	if nil ~= houseId and 0 < houseId then
		house = EHT.Data.GetHouses()[ houseId ]
	end

	if nil ~= house then
		group = house.Groups[ string.lower( EHT.CONST.GROUP_DEFAULT ) ]
		scene = house.Scenes[ string.lower( EHT.CONST.SCENE_DEFAULT ) ] 
	end

	return house, group, scene
end

function EHT.Data.GetCurrentGroup()
	local house, group = nil, nil

	local houseId = GetCurrentZoneHouseId()
	if nil ~= houseId and 0 < houseId then
		house = EHT.Data.GetHouses()[ houseId ]
	end

	if nil ~= house then
		group = house.Groups[ string.lower( EHT.CONST.GROUP_DEFAULT ) ]

		if nil == group then
			group = { }
			house.Groups[ string.lower( EHT.CONST.GROUP_DEFAULT ) ] = group
		end
	
	end

	return group
end

function EHT.Data.GetCurrentHouse( suppressMessage )
	EHT.Data.GetOrCreateHouseList()

	local houseId = GetCurrentZoneHouseId()
	if nil == houseId or 0 >= houseId then
		if not suppressMessage then d( "Must be in a player house." ) EHT.UI.PlaySoundFailure() end
		return nil
	end
--[[
	if not HasAnyEditingPermissionsForCurrentHouse() then
		if not suppressMessage then d( "Must have edit permission." ) EHT.UI.PlaySoundFailure() end
		return nil
	end
]]
	local house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then
		house = EHT.Data.CreateHouse( houseId )
	end

	local group = house.Groups[ EHT.CONST.GROUP_DEFAULT ]
	if nil == group then
		group = { }
		house.Groups[ EHT.CONST.GROUP_DEFAULT ] = group
	end

	local scene = EHT.Data.CreateScene( EHT.CONST.SCENE_DEFAULT )

	local frame = nil
	if nil == scene.FrameIndex or nil == scene.Frames or 0 >= #scene.Frames then
		scene.FrameIndex = 1
	elseif scene.FrameIndex > #scene.Frames then
		frame = scene.Frames[ 1 ]
		scene.FrameIndex = 1
	else	
		frame = scene.Frames[ scene.FrameIndex ]
	end

	local build = EHT.Data.GetBuild()

	local effects = house.Effects
	if nil == effects then
		effects = { }
		house.Effects = effects
	end

	return house, group, scene, frame, build, effects
end

function EHT.Data.IsLocalHouseId( houseId )
	return nil ~= tonumber( houseId )
end

function EHT.Data.GetBuilds()
	local builds = EHT.SavedVars.Builds

	if nil == builds then
		builds = { }
		EHT.SavedVars.Builds = builds
	end

	return EHT.SavedVars.Builds

end


function EHT.Data.GetBuild( name )

	if nil == name or "" == name then
		if nil == EHT.SavedVars.Build then
			EHT.SavedVars.Build = EHT.Util.CloneTable( EHT.CONST.BUILD_TEMPLATE_DEFAULT_VALUES )
		end

		return EHT.SavedVars.Build, nil
	else
		name = string.lower( name )
		local builds = EHT.Data.GetBuilds()

		for index, build in pairs( builds ) do
			if string.lower( build.Name ) == name then
				return build, index
			end
		end
	end

	return nil, nil

end


function EHT.Data.SetBuild( name, build )

	if nil == build then return false end

	if nil == name or "" == name then
		EHT.SavedVars.Build = EHT.Util.CloneTable( build )
	else
		build.Name = name
		build = EHT.Util.CloneTable( build )

		local _, index = EHT.Data.GetBuild( name )
		local builds = EHT.Data.GetBuilds()

		if nil ~= index then
			builds[ index ] = build
			return true
		end

		table.insert( builds, build )
	end

	return true

end


function EHT.Data.RemoveBuild( name )

	if nil == name or "" == name then
		EHT.SavedVars.Build = EHT.Util.CloneTable( EHT.CONST.BUILD_TEMPLATE_DEFAULT_VALUES )
		return true
	else
		local _, index = EHT.Data.GetBuild( name )

		if nil ~= index then
			local builds = EHT.Data.GetBuilds()
			table.remove( builds, index )

			return true
		end
	end

	return false
end

function EHT.Data.GetHouses()
	local houses
	if EHT.SavedVars then
		houses = EHT.SavedVars.Houses
		if not houses then
			houses = {}
			EHT.SavedVars.Houses = houses
		end
	else
		houses = {}
	end
	return houses
end

function EHT.Data.IsHouseListEmpty()
	return nil == EHT.SavedVars or "table" ~= type(EHT.SavedVars.Houses) or nil == next(EHT.SavedVars.Houses)
end

function EHT.Data.GetOrCreateHouseList()
	if nil == EHT.SavedVars or "table" ~= type(EHT.SavedVars.Houses) then
		EHT.SavedVars.Houses = {}
	end
	return EHT.SavedVars.Houses
end

function EHT.Data.GetHouseById( houseId )
	return EHT.Data.GetHouses()[ houseId ]
end

function EHT.Data.DeserializeGroup( group )
	return EHT.Util.CloneTable( group )
end

function EHT.Data.SerializeGroup( group )
	return EHT.Util.CloneTable( group )
end

function EHT.Data.DeserializeHistoryRecord( history )
	if "string" == type( history ) or ( "table" == type( history ) and history[0] ) then
		local item = EHT.Util.DeserializeSaved( history )

		if item.Batch then
			for index, bitem in ipairs( item.Batch ) do
				if bitem.ItemId and not bitem.Link then
					bitem.Link = EHT.Housing.GetFurnitureItemIdLink( bitem.ItemId )
				end
			end
		else
			if item.ItemId and not item.Link then
				item.Link = EHT.Housing.GetFurnitureItemIdLink( item.ItemId )
			end
		end

		return item
	end

	return history
end

function EHT.Data.SerializeHistoryRecord( history )
	if "table" == type( history ) and not history[0] then
		local item = EHT.Util.CloneTable( history )

		if "table" == type( item.Batch ) then
			for index, bitem in ipairs( item.Batch ) do
				if bitem.Link and "" ~= bitem.Link and "Multiple Items" ~= bitem.Link and "New Session" ~= bitem.Link then
					bitem.ItemId = EHT.Housing.GetFurnitureLinkItemId( bitem.Link )
					bitem.Link = nil
				end
			end
		else
			if item.Link and "" ~= item.Link and "Multiple Items" ~= item.Link and "New Session" ~= item.Link then
				item.ItemId = EHT.Housing.GetFurnitureLinkItemId( item.Link )
				item.Link = nil
			end
		end

		return EHT.Util.SerializeSaved( item )
	end

	return history
end

function EHT.Data.GetGroups( house )
	local groups = { }

	if nil == house then
		house = EHT.Data.GetCurrentHouse()
	elseif "table" ~= type( house ) then
		house = EHT.Data.GetHouses()[ house ]
	end

	if nil ~= house and nil ~= house.Groups then
		for gName, group in pairs( house.Groups ) do
			groups[gName] = EHT.Data.DeserializeGroup( group )
		end
	end

	return groups
end

function EHT.Data.GetGroupNames( house )
	local names = { }

	local groups = EHT.Data.GetGroups( house )
	if not groups then
		return names
	end

	for groupName in pairs( groups ) do
		table.insert( names, groupName )
	end
	table.sort( names )

	return names
end

function EHT.Data.GetGroup( groupName, house )
	if nil == house then
		house, _ = EHT.Data.GetCurrentHouse()
	elseif "table" ~= type( house ) then
		house = EHT.Data.GetHouses()[ house ]
	end

	if nil == house then return nil end

	groupName = EHT.Util.Trim( string.lower( groupName ) )
	if nil ~= groupName and "" ~= groupName then
		for gName, group in pairs( house.Groups ) do
			if EHT.Util.Trim( string.lower( gName ) ) == groupName then
				return EHT.Data.DeserializeGroup( group ), gName
			end
		end
	end

	return nil
end

function EHT.Data.GetGroupName( group, house )
	if nil == house then
		house, _ = EHT.Data.GetCurrentHouse()
	elseif "table" ~= type( house ) then
		house = EHT.Data.GetHouses()[ house ]
	end

	if nil == house then
		return nil
	end

	for groupName, groupData in pairs( house.Groups ) do
		if groupData == group then
			return groupName
		end
	end

	return nil
end

function EHT.Data.GetGroupStatefulFurnitureIdList( groupName, house, maxStringLength )
	local furnitureIds = {}

	local group = EHT.Data.GetGroup( groupName, house )
	if not group then
		return ""
	end

	for index, item in ipairs( group ) do
		local id = item.Id
		if 0 < EHT.Housing.GetFurnitureNumStates( id ) then
			table.insert( furnitureIds, id )
		end
	end

	local idList = table.concat( furnitureIds, "," )
	if maxStringLength and #idList > maxStringLength then
		local endIndex = string.find( idList, "\,", -1 )
		if endIndex and 0 < endIndex then
			idList = string.sub( idList, 1, endIndex - 1 )
		else
			idList = ""
		end
	end
	
	return idList
end

function EHT.Data.GetScenes( houseId )
	local house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then return nil end

	return house.Scenes
end


function EHT.Data.GetScene( sceneName, houseId )

	if nil == houseId then houseId = GetCurrentZoneHouseId() end
	local house = EHT.Data.GetHouses()[ houseId ]

	if house then
		if nil == sceneName then
			sceneName = string.lower( EHT.CONST.SCENE_DEFAULT )
		else
			sceneName = string.lower( EHT.Util.Trim( sceneName ) )
		end

		return house.Scenes[ sceneName ]
	end

	return nil

end


function EHT.Data.ResetScene( scene )

	if nil == scene then scene = EHT.Data.GetScene() end

	if nil ~= scene then
		scene.Name = EHT.CONST.SCENE_DEFAULT
		scene.Group = { }
		scene.Frames = { }
		scene.FrameIndex = 1
	end

	return scene

end


function EHT.Data.RemoveGroup( groupName )

	local house = EHT.Data.GetCurrentHouseRecords()
	if nil == house then return nil end

	local group, gName = EHT.Data.GetGroup( groupName )
	if nil == group or nil == gName then return nil end

	house.Groups[ gName ] = nil

	local defaultGroup = house.Groups[ EHT.CONST.GROUP_DEFAULT ]
	if nil == defaultGroup then house.Groups[ EHT.CONST.GROUP_DEFAULT ] = { } end

	return group

end


function EHT.Data.GetSceneFurniture( furnitureId, scene )

	if nil ~= furnitureId then

		if nil == scene then _, _, scene = EHT.Data.GetCurrentHouse() end
		if nil == scene then return nil end

		local idString = furnitureId
		if "string" ~= type( furnitureId ) then idString = string.fromId64( furnitureId ) end

		for _, item in ipairs( scene.Group ) do
			if idString == item.Id then return item end
		end

	end

	return nil

end


function EHT.Data.GetSceneFrameFurniture( furnitureId )

	if nil ~= furnitureId then

		local _, _, scene = EHT.Data.GetCurrentHouse()
		if nil == scene or nil == scene.Frames or nil == scene.FrameIndex then return nil end

		local idString = furnitureId
		if "string" ~= type( furnitureId ) then idString = string.fromId64( furnitureId ) end

		local frame = scene.Frames[ scene.FrameIndex ]
		if nil == frame then return nil end

		for _, item in ipairs( frame.State ) do
			if idString == item.Id then return item end
		end

		for _, item in ipairs( scene.Group ) do
			if idString == item.Id then
				local i = EHT.Util.CloneSceneFrameFurniture( item )
				frame.State[ #frame.State + 1 ] = i
				return i
			end
		end
	end

	return nil
end

function EHT.Data.GetGroupFurniture( furnitureId, group )
	if nil ~= furnitureId then
		if nil == group then
			_, group = EHT.Data.GetCurrentHouse()
			if nil == group then return nil end
		end

		local idString = furnitureId
		if "string" ~= type( idString ) then idString = string.fromId64( idString ) end

		for _, item in ipairs( group ) do
			if idString == item.Id then return item end
		end
	end

	return nil
end

function EHT.Data.UpdateGroupFurniture()
	local _, group = EHT.Data.GetCurrentHouse()
	if nil == group then return end

	for index, item in ipairs( group ) do
		local id, pathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		if id and pathIndex then
			local x, y, z, yaw, speed, delayTime = EHT.Housing.GetFurniturePathNodeInfo( id, pathIndex )
			if x and 0 ~= x then
				item.X, item.Y, item.Z, item.Yaw, item.Speed, item.DelayTime = x, y, z, yaw, speed, delayTime
			end
		else
			id = EHT.Housing.FindFurnitureId( id )
			if nil ~= id then
				local x, y, z = EHT.Housing.GetFurniturePosition( id )
				local pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )
				if 0 ~= x or 0 ~= y or 0 ~= z then
					item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = x, y, z, pitch, yaw, roll
				end
			end
		end
	end
end

function EHT.Data.IsFurniturePathInGroup( id, group )
	if not id then
		return false
	end

	id = EHT.Housing.GetFurnitureIdInfo( id )
	id = string.fromId64( id )

	if not id then
		return false
	end

	if not group then
		group = EHT.Data.GetCurrentGroup()
		if not group then
			return false
		end
	end

	for index, item in ipairs( group ) do
		local itemId = EHT.Housing.GetFurnitureIdInfo( item.Id )
		if string.fromId64( itemId ) == id then
			return true
		end
	end
	
	return false
end

function EHT.Data.GetGroupFurniturePathInfo( id, group )
	if not id then
		return nil
	end

	id = EHT.Housing.GetFurnitureIdInfo( id )
	id = string.fromId64( id )

	if not id then
		return nil
	end

	if not group then
		group = EHT.Data.GetCurrentGroup()
		if not group then
			return nil
		end
	end

	local paths = group.Paths
	if not paths then
		return nil
	end

	return paths[id]
end

function EHT.Data.SetGroupFurniturePathInfo( id, group, info )
	if not id then
		return
	end

	id = EHT.Housing.GetFurnitureIdInfo( id )
	id = string.fromId64( id )

	if not id then
		return
	end

	if not group then
		group = EHT.Data.GetCurrentGroup()
		if not group then
			return
		end
	end

	if not info then
		info = EHT.Housing.GetFurniturePathInfo( id )
	end

	local paths = group.Paths
	if info then
		if not paths then
			paths = { }
			group.Paths = paths
		end

		paths[id] = info
	elseif paths then
		paths[id] = nil
		
		local empty = true
		for key in pairs( paths ) do
			if tonumber( key ) then
				empty = false
				break
			end
		end

		if empty then
			group.Paths = nil
		end
	end

	return info
end

function EHT.Data.ValidateGroupPathables( group, refreshPathInfo )
	if not group then return end
	local pathedFurnitureIds = { }
	local firstPathNodeFurnitureIds = { }

	for index, item in ipairs( group ) do
		local furnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		if furnitureId and pathIndex then
			furnitureId = string.fromId64( furnitureId )
			pathedFurnitureIds[ furnitureId ] = true
			if 1 == pathIndex then
				firstPathNodeFurnitureIds[ furnitureId ] = true
			end
		end
	end

	if next( pathedFurnitureIds ) then
		for index = #group, 1, -1 do
			local item = group[index]
			local furnitureId = item.Id
			if pathedFurnitureIds[ furnitureId ] then
				if firstPathNodeFurnitureIds[ furnitureId ] then
					table.remove( group, index )
				else
					local firstNodeFurnitureId = EHT.Housing.GetFurniturePathNodeId( furnitureId, 1 )
					item.Id = firstNodeFurnitureId
					item.Speed = HOUSING_PATH_MOVEMENT_SPEED_WALK
					item.DelayTime = 0
				end

				if refreshPathInfo then
					EHT.Data.SetGroupFurniturePathInfo( furnitureId, group )
				end
			end
		end
	end
end

function EHT.Data.SortGroupPathables( group )
	if not group then
		return
	end
	
	local function SortItems( left, right )
		if left.Id and right.Id then
			local id1, pathIndex1 = EHT.Housing.GetFurnitureIdInfo( left.Id )
			local id2, pathIndex2 = EHT.Housing.GetFurnitureIdInfo( right.Id )
			local sid1, sid2 = string.fromId64( id1 ), string.fromId64( id2 )
			if sid1 < sid2 then
				return true
			elseif sid1 == sid2 and pathIndex1 and pathIndex2 then
				return pathIndex1 < pathIndex2
			end
		end
		return false
	end

	table.sort( group, SortItems )
end

function EHT.Data.ShiftGroupFurniturePathNodes( id, pathIndex, direction, group )
	if not group then
		group = EHT.Data.GetCurrentGroup()
		if not group then
			return
		end
	end

	for index, item in ipairs( group ) do
		local itemId, itemPathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		if itemId and itemPathIndex then
			local comparison = EHT.Housing.CompareFurniturePathNodes( id, pathIndex, itemId, itemPathIndex )
			if comparison then
				if comparison == direction then
					itemPathIndex = itemPathIndex + direction
					item.Id = EHT.Housing.GetFurniturePathNodeId( itemId, itemPathIndex )
					item.Link = EHT.Housing.GetFurnitureLink( item.Id )
				end
			end
		end
	end
end

function EHT.Data.AddGroupFurniturePathNode( group, obj )
	if nil == group or nil == obj then
		return false
	end

	local furnitureId, pathIndex = EHT.Housing.GetFurnitureIdInfo( obj.Id )
	if nil == furnitureId or nil == pathIndex then
		return false
	end
	furnitureId = string.fromId64( furnitureId )

	local foundParentFurniture = false
	for index, item in ipairs( group ) do
		local itemFurnitureId, itemPathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		itemFurnitureId = itemFurnitureId and string.fromId64( itemFurnitureId ) or nil

		if itemFurnitureId and itemPathIndex and itemFurnitureId == furnitureId then
			foundParentFurniture = true
			if itemPathIndex > pathIndex then
				table.insert( group, index, obj )
				EHT.Data.SetGroupFurniturePathInfo( furnitureId, group )
				return true
			end
		elseif foundParentFurniture then
			table.insert( group, index, obj )
			EHT.Data.SetGroupFurniturePathInfo( furnitureId, group )
			return true
		end
	end

	table.insert( group, obj )
	EHT.Data.SetGroupFurniturePathInfo( furnitureId, group )
	return true
end

function EHT.Data.AddGroupFurniture( furnitureIds, group )
	if nil == furnitureIds then return end

	if nil == group then
		_, group = EHT.Data.GetCurrentHouse()
		if nil == group then return nil end
	end

	local obj, idString
	if "table" ~= type( furnitureIds ) then
		local furnitureId = furnitureIds
		obj = EHT.Data.CreateFurniture( furnitureId )
		if "string" ~= type( furnitureId ) then idString = string.fromId64( furnitureId ) else idString = furnitureId end

		if nil ~= obj then
			for index, item in ipairs( group ) do
				if idString == item.Id then
					group[ index ] = obj
					return obj
				end
			end

			if EHT.Housing.IsFurniturePathNodeId( obj.Id ) then
				EHT.Data.AddGroupFurniturePathNode( group, obj )
			else
				table.insert( group, obj )
			end

			EHT.Handlers.OnFurnitureSelected( obj )
			EHT.Data.ValidateGroupPathables( group )
			EHT.UI.RefreshPositionDialog()

			return obj
		end
	else
		local existingIds = { }
		for _, item in ipairs( group ) do
			existingIds[ item.Id ] = true
		end

		for _, furnitureId in ipairs( furnitureIds ) do
			if "string" ~= type( furnitureId ) then idString = string.fromId64( furnitureId ) else idString = furnitureId end
			if not existingIds[ idString ] then
				obj = EHT.Data.CreateFurniture( furnitureId )
				if nil ~= obj then
					if EHT.Housing.IsFurniturePathNodeId( obj.Id ) then
						EHT.Data.AddGroupFurniturePathNode( group, obj )
					else
						table.insert( group, obj )
					end

					EHT.Handlers.OnFurnitureSelected( obj )
				end
			end
		end

		EHT.Data.ValidateGroupPathables( group )
		EHT.UI.RefreshPositionDialog()
	end

	return nil
end

function EHT.Data.RemoveGroupFurniture( furnitureId, group )
	if nil ~= furnitureId then
		if nil == group then
			_, group = EHT.Data.GetCurrentHouse()
			if nil == group then return nil end
		end

		if "table" == type( furnitureId ) then
			local removeIds = { }
			for index, id in ipairs( furnitureId ) do
				local idString = id
				if "string" ~= type( idString ) then idString = string.fromId64( idString ) end
				removeIds[ idString ] = true
			end

			for index = #group, 1, -1 do
				local item = group[index]
				if removeIds[ item.Id ] then
					table.remove( group, index )
					EHT.Data.SetGroupFurniturePathInfo( item.Id, group )
					EHT.Handlers.OnFurnitureUnselected( item )
				end
			end

			EHT.UI.RefreshPositionDialog()
		else
			local idString = furnitureId
			if "string" ~= type( furnitureId ) then idString = string.fromId64( furnitureId ) end

			for index = #group, 1, -1 do
				local item = group[index]
				if idString == item.Id then
					table.remove( group, index )
					EHT.Data.SetGroupFurniturePathInfo( item.Id, group )
					EHT.UI.RefreshPositionDialog()
					EHT.Handlers.OnFurnitureUnselected( item )

					return item
				end
			end
		end
	end

	return nil
end

function EHT.Data.RemoveGroupFurniturePathNodes( id, group )
	if not id then
		return
	end

	if not group then
		group = EHT.Data.GetCurrentGroup()
		if not group then
			return
		end
	end

	id = string.fromId64( id )

	for index = #group, 1, -1 do
		local item = group[index]
		local itemId, itemPathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
		if itemId and string.fromId64( itemId ) == id then
			table.remove( group, index )
		end
	end

	EHT.Data.SetGroupFurniturePathInfo( id, group )
end

function EHT.Data.ReassignPathNodesToFurnitureIdForCurrentGroup( furnitureId, newFurnitureId )
	if not furnitureId or not newFurnitureId then
		return
	end

	local groups = { }

	do
		local group = EHT.Data.GetCurrentGroup()
		if group then
			table.insert( groups, group )
		end
	end

	do
		local group = EHT.SavedVars.Clipboard
		if group then
			table.insert( groups, group )
		end
	end
	
	do
		local group = EHT.ProcessData and EHT.ProcessData.Clipboard or nil
		if group then
			table.insert( groups, group )
		end
	end

	furnitureId, newFurnitureId = string.fromId64( furnitureId ), string.fromId64( newFurnitureId )

	for _, group in ipairs( groups ) do
		for index, item in ipairs( group ) do
			local itemId, itemPathIndex = EHT.Housing.GetFurnitureIdInfo( item.Id )
			if itemPathIndex and itemId and string.fromId64( itemId ) == furnitureId then
				item.Id = EHT.Housing.GetFurniturePathNodeId( newFurnitureId, itemPathIndex )
			end
		end
	end
end

function EHT.Data.ResetAllSelections()
	for _, house in pairs( EHT.Data.GetHouses() ) do
		if "table" == type( house.Groups ) then
			house.Groups[ EHT.CONST.GROUP_DEFAULT ] = { }
			house.CurrentGroupName = EHT.CONST.GROUP_DEFAULT
		end
	end
end

function EHT.Data.ResetAllGroups()
	EHT.SavedVars.Clipboard = nil

	for _, house in pairs( EHT.Data.GetHouses() ) do
		house.Groups = { }
		house.Groups[ EHT.CONST.GROUP_DEFAULT ] = { }
	end
end

function EHT.Data.ResetAllScenes()
	for _, house in pairs( EHT.Data.GetHouses() ) do
		house.Scenes = { }
	end
end

function EHT.Data.ResetEverything()
	for k, _ in pairs( EHT.SAVED_VARS_DEFAULTS ) do
		EHT.SavedVars[ k ] = nil
	end
end

function EHT.Data.RefreshEditorItemCache()
	if nil == EHT.EditorItemCache then EHT.EditorItemCache = { } end

	local cache = EHT.EditorItemCache
	local id, index, cacheItem, cacheSize = nil, 1, nil, #cache
	local link, x, y, z, pitch, yaw, roll

	repeat
		id = EHT.Housing.GetNextFurnitureId( id )

		if nil ~= id then
			if index > cacheSize then
				cacheItem = { 0, 0, 0, 0, 0, 0, 0, 0 }
				table.insert( cache, cacheItem )
				cacheSize = cacheSize + 1
			else
				cacheItem = cache[ index ]
			end

			link = EHT.Housing.GetFurnitureLink( id )
			x, y, z = EHT.Housing.GetFurniturePosition( id )
			pitch, yaw, roll = EHT.Housing.GetFurnitureOrientation( id )
			cacheItem[1], cacheItem[2], cacheItem[3], cacheItem[4], cacheItem[5], cacheItem[6], cacheItem[7], cacheItem[8] = id, link, x, y, z, pitch, yaw, roll
			index = index + 1
		end
	until nil == id

	for i = index + 1, cacheSize, 1 do
		cacheItem = cache[i]
		cacheItem[1], cacheItem[2], cacheItem[3], cacheItem[4], cacheItem[5], cacheItem[6], cacheItem[7], cacheItem[8] = 0, 0, 0, 0, 0, 0, 0, 0
	end
end

function EHT.Data.GetEditorItemCacheById( id )
	if "string" ~= type( id ) then id = string.fromId64( id ) end

	if nil == EHT.EditorItemCache then EHT.EditorItemCache = { } end
	local cache = EHT.EditorItemCache

	for index = 1, #cache, 1 do
		if 0 ~= cache[index][1] and string.fromId64( cache[index][1] ) == id then return cache[index] end
	end

	return nil
end

---[ Effects ]---

function EHT.Data.GetEffectRecordsByHouseId( houseId )
	EHT.Data.GetOrCreateHouseList()

	houseId = houseId or EHT.Housing.GetHouseId()
	local house = EHT.Data.GetHouses()[ houseId ]
	if nil == house then return end

	local effects = house.Effects
	if nil == effects then
		effects = { }
		house.Effects = effects
	end

	return effects
end

function EHT.Data.GetEffectRecords(houseId, player)
	local house, effects = EHT.Data.GetCurrentHouseOrGuestHouse(houseId, player)
	if house and effects then
		return effects
	end
end

function EHT.Data.GetEffectRecordByEffect( effect )
	if "table" ~= type( effect ) then return end
	local rec, effects = nil, EHT.Data.GetEffectRecords()
	if nil == effects then return end

	for index = 1, #effects do
		rec = effects[index]
		if effect.Record == rec then return rec, index end
	end

	return nil
end

function EHT.Data.GetEffectRecordById( id )
	if "string" == type( id ) then id = tonumber( id ) end
	if nil == id then return nil end

	local effects = EHT.Data.GetEffectRecordsByHouseId()
	if nil == effects then return end

	local rec
	for index = 1, #effects do
		rec = effects[index]
		if rec and rec.Id == id then return rec, index end
	end

	return nil
end

function EHT.Data.GetEffectByRecordId( id )
	return EHT.Effect:GetByRecordId( id )
end

function EHT.Data.AcquireNewEffectId()
	local newId = EHT.SavedVars.CurrentEffectId
	if nil == newId then newId = 1000 end
	newId = newId + 1
	EHT.SavedVars.CurrentEffectId = newId
	return newId
end

function EHT.Data.CreateEffectRecord( effect, effectIndex )
	if "table" ~= type( effect ) then return end
	local effectType = effect:GetEffectType()
	local effects = EHT.Data.GetEffectRecords()
	if nil == effects then return end

	local rec = effects[effectIndex]
	if nil == rec then
		local newId = EHT.Data.AcquireNewEffectId()
		rec = { Id = newId, EffectType = effectType.Index }
		table.insert( effects, rec )
		EHT.Housing.RegisterFurnitureId( rec.Id )
	end

	effect:SetRecord( rec )
	EHT.Data.UpdateEffectRecord( rec, effect, true )

	return rec
end

function EHT.Data.UpdateEffectRecord( rec, effect, isCreate )
	if nil == rec then return nil end
	if nil == effect then effect = EHT.Data.GetEffectByRecordId( rec.Id ) end
	if nil == effect then return nil end

	local x, y, z = effect:GetPosition()
	local pitch, yaw, roll = effect:GetOrientation()
	local cR, cG, cB = effect:GetColor()
	local color = EHT.Util.CompressColor( cR, cG, cB )
	local alpha = effect:GetAlpha() or 1
	local contrast = effect:GetContrast() or 1
	local sizeX, sizeY, sizeZ = effect:GetSize()
	local groups = effect:GetEffectGroupBitmask()
	local metaParams = effect.EffectType:GetMetaParams()

	rec.X, rec.Y, rec.Z = x, y, z
	rec.Pitch, rec.Yaw, rec.Roll = pitch, yaw, roll
	rec.Color, rec.Alpha, rec.Contrast = color, alpha, contrast
	rec.SizeX, rec.SizeY, rec.SizeZ = sizeX, sizeY, sizeZ
	rec.Groups = groups

	if metaParams and 0 < #metaParams then
		local data = rec.MetaData
		if "table" ~= type( data ) then
			data = { }
			rec.MetaData = data
		end

		for index, p in ipairs( metaParams ) do
			data[ string.lower( p.Name ) ] = effect:GetMetaData( p.Name )
		end
	end

	if not isCreate then
		EHT.Data.UpdateGroupEffectRecord( rec )
	end

	EHT.Data.SetHouseFXDirty()

	return rec
end

function EHT.Data.UpdateGroupEffectRecord( rec )
	local item = EHT.Data.GetGroupFurniture( rec.Id )
	if item then
		item.X, item.Y, item.Z, item.Pitch, item.Yaw, item.Roll = rec.X, rec.Y, rec.Z, rec.Pitch, rec.Yaw, rec.Roll
		item.SizeX, item.SizeY, item.SizeZ = rec.SizeX, rec.SizeY, rec.SizeZ
		item.Color, item.Alpha, item.Contrast = rec.Color, rec.Alpha or 1, rec.Contrast or 1
		item.Groups = rec.Groups
		item.MetaData = rec.MetaData
	end
end

function EHT.Data.IsValidEffectTimestamp( ts )
	local minVal, maxVal = GetTimeStamp() - 10 * 365 * 24 * 60 * 60, GetTimeStamp() + 24 * 60 * 60
	return ts and ts >= minVal and ts <= maxVal
end

function EHT.Data.ValidateSharedEffectTimestamp( player, houseId, timestamp )
	timestamp = tonumber( timestamp )

	if timestamp and not EHT.Data.IsValidEffectTimestamp( timestamp ) then
		return -1
	end

	local house, effects = EHT.Data.GetCurrentHouseOrGuestHouse( houseId, player )
	if not house then
		return nil
	end

	local current = house.EffectsTimestamp
	if current then
		current = tonumber( current )
		if EHT.Data.IsValidEffectTimestamp( current ) and ( not timestamp or current > timestamp ) then
			return current
		end
	end

	if timestamp then
		house.EffectsTimestamp = tostring( timestamp )
	end

	return nil
end

function EHT.Data.GetHouseEffects( houseId, player )
	if not houseId or 0 == houseId then return end

	local house, records = EHT.Data.GetCurrentHouseOrGuestHouse( houseId, player, false )

	if not house then return end
	if not records or "table" ~= type( records ) or 0 >= #records then return end

	local effects = { }
	local effect

	for index, record in ipairs( records ) do
		effect = { }
		effect.EffectType = EHT.EffectType:GetByIndex( record.EffectType )
		effect.X, effect.Y, effect.Z = record.X, record.Y, record.Z
		effect.SizeX, effect.SizeY, effect.SizeZ = record.SizeX, record.SizeY, record.SizeZ
		effect.Pitch, effect.Yaw, effect.Roll = record.Pitch, record.Yaw, record.Roll
		effect.ColorR, effect.ColorG, effect.ColorB = EHT.Util.DecompressColor( record.Color )
		effect.Alpha, effect.Contrast = record.Alpha, record.Contrast
		effect.MetaData = record.MetaData
		effect.Groups = record.Groups or 0
		effect.Id = record.Id
		table.insert( effects, index, effect )
	end

	return effects, house.EffectsTimestamp
end

function EHT.Data.CacheEffectRecord( player, houseId, effectIndex, effect )
	if "string" ~= type( player ) or "" == player then return end
	if "number" ~= type( houseId ) then return end
	if "number" ~= type( effectIndex ) then return end
	if "table" ~= type( effect ) then return end

	local effectType = effect:GetEffectType()
	local effects = EHT.Data.GetEffectRecords( houseId, player, true )

	if "table" ~= type( effects ) then return end

	rec = { EffectType = effectType.Index }
	EHT.Data.UpdateEffectRecord( rec, effect, true )
	effects[ effectIndex ] = rec

	return rec
end

function EHT.Data.CullEffectRecords( player, houseId, startingIndex )
	if "string" ~= type( player ) or "" == player then return end
	if "number" ~= type( houseId ) then return end
	if "number" ~= type( startingIndex ) then return end

	local effects = EHT.Data.GetEffectRecords( houseId, player )

	if "table" ~= type( effects ) then return end

	local numEffects = #effects

	if numEffects >= startingIndex then
		for index = numEffects, startingIndex, -1 do
			effects[index] = nil
		end
	end
end

function EHT.Data.DeleteEffectRecord( rec, suppressUndo )
	if nil == rec then return false end

	local effects = EHT.Data.GetEffectRecords()
	if nil == effects then return false end

	if not suppressUndo then
		EHT.Handlers.OnFurnitureRemoved( nil, rec.Id, nil, EHT.Data.CreateFurniture( rec.Id ) )
	end

	local effect = EHT.Effect:GetByRecord( rec )
	if nil ~= effect then effect:Delete() end

	for index = 1, #effects do
		if rec == effects[index] then
			table.remove( effects, index )
			EHT.Data.SetHouseFXDirty()
			return true
		end
	end

	return false
end

function EHT.Data.DeleteAllEffectRecords()
	local effects = EHT.Data.GetEffectRecords()
	if nil == effects then return end

	local history = { Op = EHT.CONST.CHANGE_TYPE.REMOVE, Id = 0, Link = "Multiple Items" }
	local batch = { }
	history.Batch = batch

	for index = #effects, 1, -1 do
		local rec = effects[index]

		if rec then
			local item = EHT.Data.CreateFurniture( rec.Id )
			if EHT.Data.DeleteEffectRecord( rec, true ) then
				table.insert( batch, EHT.CT.CreateHistory( EHT.CONST.CHANGE_TYPE.REMOVE, item, nil ) )
			end
		end
	end

	if 0 < #batch then
		EHT.CT.AddHistory( history )
		EHT.UI.RefreshHistory()
		EHT.Data.SetHouseFXDirty()
	end

	return true
end

function EHT.Data.RestoreEffectRecord( effectId, effectTypeIndex, x, y, z, pitch, yaw, roll, sizeX, sizeY, sizeZ, color, alpha, groups, metaData, contrast )
	local effects = EHT.Data.GetEffectRecords()
	if nil == effects then return end

	local rec = EHT.Data.GetEffectRecordById( effectId )
	if rec then
		rec.EffectType = tonumber( effectTypeIndex )
		rec.X, rec.Y, rec.Z = tonumber( x ), tonumber( y ), tonumber( z )
		rec.Pitch, rec.Yaw, rec.Roll = tonumber( pitch or 0 ), tonumber( yaw or 0 ), tonumber( roll or 0 )
		rec.SizeX, rec.SizeY, rec.SizeZ = tonumber( sizeX or 1 ), tonumber( sizeY or 1 ), tonumber( sizeZ or 1 )
		rec.Color, rec.Alpha, rec.Contrast = tonumber( color or 0 ), tonumber( alpha or 1 ), tonumber( contrast or 1 )
		rec.Groups = tonumber( groups or 0 )
		rec.MetaData = EHT.Util.CloneTable( metaData )

		local effect = EHT.Data.GetEffectByRecordId( effectId )
		if effect then effect:Delete() end

		EHT.EffectUI.CreateEffectFromEffectRecord( rec )
	else
		if not effectId then effectId = EHT.Data.AcquireNewEffectId() end
		rec = {
			Id = tonumber( effectId ),
			EffectType = tonumber( effectTypeIndex ),
			X = tonumber( x ), Y = tonumber( y ), Z = tonumber( z ),
			Pitch = tonumber( pitch or 0 ), Yaw = tonumber( yaw or 0 ), Roll = tonumber( roll or 0 ),
			SizeX = tonumber( sizeX or 1 ), SizeY = tonumber( sizeY or 1 ), SizeZ = tonumber( sizeZ or 1 ),
			Color = tonumber( color or 0 ), Alpha = tonumber( alpha or 1 ), Contrast = tonumber( contrast or 1 ),
			MetaData = EHT.Util.CloneTable( metaData ),
			Groups = tonumber( groups or 0 ),
		}
		table.insert( effects, rec )

		EHT.EffectUI.CreateEffectFromEffectRecord( rec )
	end

	EHT.Data.UpdateGroupEffectRecord( rec )

	return rec
end

function EHT.Data.ResetEffectsCache()
	for houseId, house in pairs( EHT.Data.GetHouses() ) do
		if "string" == type( houseId ) then
			local index = string.find( houseId, "@" )
			if index and 1 < index then
				house.LastEffectsUpdate = nil
				house.EffectsTimestamp = nil
				house.Effects = { }
			end
		end
	end
end

function EHT.Data.GetRecentlyVisited( world )
	local list = EHT.SavedVars.RecentlyVisited
	if not list then
		list = { }
		EHT.SavedVars.RecentlyVisited = list
	end

	world = world or EHT.Util.GetWorldCode()

	if not list.na then
		list.na = { }
		for index, item in ipairs( list ) do
			list.na[index] = EHT.Util.CloneTable( item )
		end
	end

	if not list.eu then
		list.eu = { }
		for index, item in ipairs( list ) do
			list.eu[index] = EHT.Util.CloneTable( item )
		end
	end

	return list[world] or list
end

function EHT.Data.UpdateRecentlyVisited()
	if not EHT.Housing.IsHouseZone() then return end

	local houseId, owner, isOwner, houseName, houseNickname, customHouseName = EHT.Housing.GetHouseInfo()
	if not houseId then return end

	if isOwner then owner = nil end

	-- Do not record a recently visited entry for home previews.
	if "" == owner then return end

	local ts = GetTimeStamp()
	local list = EHT.Data.GetRecentlyVisited()

	for index = #list, 1, -1 do
		if list[index].HouseId == houseId and list[index].Owner == owner then
			table.remove( list, index )
		end
	end

	table.insert( list, 1, { HouseId = houseId, Owner = owner, Timestamp = ts } )

	while #list > EHT.CONST.MAX_RECENTLY_VISITED do
		table.remove( list, EHT.CONST.MAX_RECENTLY_VISITED )
	end

	local house, effects = EHT.Data.GetCurrentHouseOrGuestHouse( houseId, owner )

	if house then
		house.VisitTimestamp = ts
	end
end

---[ Favorite Houses ]---

function EHT.Data.GetFavoriteHouses( world )
	local houses = EHT.SavedVars.FavoriteHouses

	if not houses then
		houses = { }
		EHT.SavedVars.FavoriteHouses = houses
	end

	world = world or EHT.Util.GetWorldCode()

	if not houses.na then
		houses.na = { }

		for index = 1, EHT.CONST.MAX_FAV_HOUSES do
			if houses[index] then
				houses.na[index] = EHT.Util.CloneTable( houses[index] )
			end
		end
	end

	if not houses.eu then
		houses.eu = { }

		for index = 1, EHT.CONST.MAX_FAV_HOUSES do
			if houses[index] then
				houses.eu[index] = EHT.Util.CloneTable( houses[index] )
			end
		end
	end
	
	return houses[world] or houses
end

function EHT.Data.AddFavoriteHouse( houseId, owner, world )
	local houses = EHT.Data.GetFavoriteHouses( world )

	houseId = tonumber( houseId )
	owner = EHT.Util.Trim( owner )
	local sOwner = string.lower( owner )

	for index, house in pairs( houses ) do
		if house.HouseId == houseId and string.lower( house.Owner ) == sOwner then
			return house
		end
	end

	for index = 1, EHT.CONST.MAX_FAV_HOUSES do
		local house = houses[index]

		if not house then
			house = {
				HouseId = houseId,
				Owner = owner,
			}

			houses[index] = house
			return house
		end
	end

	return nil
end

function EHT.Data.RemoveFavoriteHouse( houseId, owner, world )
	local houses = EHT.Data.GetFavoriteHouses( world )

	houseId = tonumber( houseId )
	local sOwner = EHT.Util.Trim( string.lower( owner ) )

	for index = 1, EHT.CONST.MAX_FAV_HOUSES do
		local house = houses[index]

		if house and house.HouseId == houseId and string.lower( house.Owner ) == sOwner then
			houses[index] = nil
			return house
		end
	end

	return nil
end

function EHT.Data.MoveFavoriteHouse( oldIndex, newIndex, world )
	if not oldIndex or not newIndex or 1 > oldIndex or 1 > newIndex or oldIndex > EHT.CONST.MAX_FAV_HOUSES or newIndex > EHT.CONST.MAX_FAV_HOUSES or oldIndex == newIndex then
		return
	end

	local houses = EHT.Data.GetFavoriteHouses( world )
	local temp = houses[newIndex]
	houses[newIndex] = houses[oldIndex]
	houses[oldIndex] = temp

	return houses
end

function EHT.Data.GetFavoriteHouse( houseId, owner, world )
	local houses = EHT.Data.GetFavoriteHouses()

	houseId = tonumber( houseId )
	local sOwner = EHT.Util.Trim( string.lower( owner ) )

	for index, house in pairs( houses ) do
		if house.HouseId == houseId and string.lower( house.Owner ) == sOwner then
			return house
		end
	end

	return nil
end

function EHT.Data.ToggleFavoriteHouse( houseId, owner, world )
	local house = EHT.Data.GetFavoriteHouse( houseId, owner, world )

	if house then
		EHT.Data.RemoveFavoriteHouse( houseId, owner, world )
	else
		EHT.Data.AddFavoriteHouse( houseId, owner, world )
	end

	return nil ~= EHT.Data.GetFavoriteHouse( houseId, owner, world )
end

---[ House Notes ]---

function EHT.Data.GetHouseNotes( world )
	local notes = EHT.SavedVars.HouseNotes
	if type( notes ) ~= "table" then
		notes = { }
		EHT.SavedVars.HouseNotes = notes
	end

	world = world or EHT.Util.GetWorldCode()

	if not notes.na then
		notes.na = { }
		for key, note in pairs( notes ) do
			notes.na[key] = EHT.Util.CloneTable( note )
		end
	end
	
	if not notes.eu then
		notes.eu = { }
		for key, note in pairs( notes ) do
			notes.eu[key] = EHT.Util.CloneTable( note )
		end
	end

	return notes[world] or notes
end

function EHT.Data.GetHouseNote( houseId, owner, world )
	if houseId or owner then
		local key = EHT.Data.GetHouseKey( houseId or 0, owner )
		local notes = EHT.Data.GetHouseNotes( world )
		local note = notes[key]
		return note
	end
end

function EHT.Data.SetHouseNote( houseId, owner, note, world )
	if houseId or owner then
		local key = EHT.Data.GetHouseKey( houseId or 0, owner )
		if key then
			local notes = EHT.Data.GetHouseNotes( world )
			notes[key] = note
		end
	end
end

---[ Kiosks ]---

function EHT.Data.GetKioskItemInfoOld( id )
	for _, item in pairs( EHT.CONST.KIOSK_ITEMS ) do
		if id == item.CollectibleId then
			return item
		end
	end
end

function EHT.Data.GetKioskItemInfo( name )
	name = string.lower( name )

	for _, item in pairs( EHT.CONST.KIOSK_ITEMS ) do
		if name == string.lower( item.Name ) then
			return item
		end
	end
end

function EHT.Data.GetHouseKiosk( filter )
	if not EHT.Housing.IsOwner() then
		return nil
	end

	if filter then
		filter = string.lower( filter )
	else
		return nil
	end

	local kiosk = { }
	local kioskItemList = EHT.Util.CloneTable( EHT.CONST.KIOSK_ITEMS )
	local matchedItems = EHT.Biz.MatchAndUpdateFurniture( kioskItemList )
	local nextIndex = 0

	for _, item in ipairs( kioskItemList ) do
		if string.find( filter, string.lower( item.Type ) ) then
			local id, collectibleId

			if item.CollectibleId then
				if IsCollectibleUnlocked( item.CollectibleId ) then
					collectibleId = item.CollectibleId
					id = string.fromId64( GetFurnitureIdFromCollectibleId( collectibleId ) )
				end
			else
				for _, matchedItem in ipairs( matchedItems ) do
					if matchedItem.Match and matchedItem.Match.Link == item.Link then
						id = string.fromId64( matchedItem.Id )
						break
					end
				end
			end

			local x, y, z = EHT.Housing.GetFurnitureLocalDimensions( id )
			if x and y and z and EHT.Housing.IsValidFurnitureId( id ) then
				if collectibleId then
					id = nil
				end

				nextIndex = nextIndex + 1
				local kioskItem = {
					Id = id,
					CollectibleId = collectibleId,
					Name = item.Name,
					Type = item.Type,
					FlipY = item.FlipY,
					RadiusOffset = item.RadiusOffset,
					YOffset = item.YOffset,
					X = x,
					Y = y,
					Z = z,
					InUse = false
				}
				kiosk[nextIndex] = kioskItem
			end
		end
	end

	return kiosk
end

do
	local function GetHouseFXDirtyValue(houseId)
		if not houseId then
			if not EHT.Housing.IsOwner() then
				return
			end
			houseId = EHT.Housing.GetHouseId()
		end
		return EHT.DirtyHouseFX[houseId], houseId
	end

	local function SetHouseFXDirtyValue(newValue, houseId)
		local currentValue, currentHouseId = GetHouseFXDirtyValue(houseId)
		if not houseId then
			if not EHT.Housing.IsOwner() then
				return
			end
			houseId = currentHouseId
		end
		if 0 == houseId then
			return
		end

		local hasCurrentValue = currentValue ~= nil
		local hasNewValue = newValue ~= nil
		if hasCurrentValue ~= hasNewValue then
			EHT.DirtyHouseFX[houseId] = newValue
			if houseId == EHT.Housing.GetHouseId() then
				EHT.Data.OnHouseFXDirtyStateChanged()
			end
		end
	end

	function EHT.Data.OnHouseFXDirtyStateChanged()
		EHT.UI.RefreshPublishFXButton()
	end
	
	function EHT.Data.AreHouseFXDirty(houseId)
		local dirtyValue = GetHouseFXDirtyValue(houseId)
		return dirtyValue ~= nil, dirtyValue
	end

	function EHT.Data.ClearHouseFXDirty(houseId)
		SetHouseFXDirtyValue(nil, houseId)
	end

	function EHT.Data.SetHouseFXDirty(houseId)
		SetHouseFXDirtyValue(GetTimeStamp(), houseId)
	end
end

function EHT.Data.OnZoneChanged(houseId, houseOwner, previousHouseId, previousHouseOwner)
	if 0 == houseId or not EHT.Housing.IsOwner() then
		-- This is not a house or a house that we own.
		return
	end
	
	local houseEffects = EHT.Data.GetHouseEffects(houseId)
	if not houseEffects or not next(houseEffects) then
		-- There are no local FX.
		return
	end

	local dirty = false
	local world = EssentialHousingHub:GetWorldCode()
	local publishedEffects = EssentialHousingHub:GetCommunityHouseFXRecord(houseOwner, world, houseId)
	if not publishedEffects or not next(publishedEffects) then
		-- There are local FX but no published FX.
		dirty = true
	end

	if dirty then
		-- Let the player know that their FX are dirty immediately.
		EHT.Data.SetHouseFXDirty(houseId)
	end
end

EHT.Modules = ( EHT.Modules or { } ) EHT.Modules.Data = true