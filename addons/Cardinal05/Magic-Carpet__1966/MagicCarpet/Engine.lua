------[[ Namespaces ]]------


if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Engine then MC.Engine = ZO_Object.New( ZO_Object:Subclass() ) end

local matrix = MC.LibMatrix
local round = function( n, d ) if nil == d then return zo_roundToZero( n ) else return zo_roundToNearest( n, 1 / ( 10 ^ d ) ) end end


------[[ Locals ]]------


local NS = "MC_Engine"

local REFRESH_HANDLE = NS .. "_Refresh"
local COMBAT_HANDLE = NS .. "_Combat"

local INITIAL_FORCED_ASCENSION = 50
local MIN_THRESHOLD_MOVEMENT = 5

local SELECT_DIFFERENT_MODE = "\nPlease select a different mode."

local ABILITY_ID_ROLL_DODGE = 28549
local ABILITY_ID_BLOCK = 14890
local ABILITY_ID_CLOAK_DISGUISE = 25381
local ABILITY_ID_CLOAK_DARK = 25377
local ABILITY_ID_CLOAK_SHADOW = 25376
local ABILITY_ID_HIDDEN = 20309
local ABILITY_ID_INTERRUPT = 55146
local ABILITY_ID_SPRINT = 973
local ABILITY_ID_ZONE_JUMP = 6811

local ForceAscendToY = 0
local ShowKeybindReminder = true


------[[ Methods ]]------


function MC.Engine:Initialize()

	EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )

	self.CurrentMode = nil
	self.Active = false
	self.Locked = false
	self.CombatMode = false
	self:ResetState()

	MC.CarpetUI:SelectDefaultMode()
	self:ResetUsingAnyAvailableMode()

end


function MC.Engine:OnActivated()

	self.CombatMode = self:HasModeAttribute( MC.Mode.ATTRIBUTE.COMBAT_ENHANCED )
	self:RegisterCombatEvents()

	local keybindReminderShown = false
	if ShowKeybindReminder and false ~= MC.Vars.Settings.EnableKeybindReminder then
		ShowKeybindReminder = false
		keybindReminderShown = true
		MC.NotificationUI:QueueMessage( "Thank you for flying Magic Carpet airways.\nPlease fasten your Ascend / Descend key binding controls and enjoy your flight." )
	end

	local mode = self:GetMode()
	if mode then
		MC.Trophy:SetEarned( mode:GetName() )

		if false ~= MC.Vars.Settings.AutoAdjustCamera then
			local cameraDistance, cameraVerticalOffset = mode:GetCameraPreferences()

			if cameraDistance then
				MC.GameSettings:ModifySetting( SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, cameraDistance )
			end

			if cameraVerticalOffset then
				MC.GameSettings:ModifySetting( SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, cameraVerticalOffset )
			end
		end

		if mode:HasAttribute( MC.Mode.ATTRIBUTE.FLIGHT ) then
			local x, y, z = GetPlayerWorldPositionInHouse()
			ForceAscendToY = y + INITIAL_FORCED_ASCENSION

			local startTime = GetFrameTimeMilliseconds()
			local hint1Time, hint2Time = 12000, 5000
			local hint1, hint2 = false, false

			EVENT_MANAGER:RegisterForUpdate( "MC.IdleCheck", 500, function()
				if not self:IsActive() then
					ForceAscendToY = 0
					EVENT_MANAGER:UnregisterForUpdate( "MC.IdleCheck" )
					return
				end

				if 0 >= ForceAscendToY then
					EVENT_MANAGER:UnregisterForUpdate( "MC.IdleCheck" )
					return
				end

				local timeElapsed = GetFrameTimeMilliseconds() - startTime

				if not hint2 and hint2Time < timeElapsed then
					hint2 = true
					local MESSAGE = "|acJump to begin flying...\n|r"
					d(MESSAGE)
					MC.NotificationUI:QueueMessage(MESSAGE)
				end

				if not hint1 and hint1Time < timeElapsed then
					hint1 = true
					ForceAscendToY = 0
					local MESSAGE = "|acIf your Magic Carpet will not hold you:\n|al" ..
						"1. Stop Magic Carpet\n" ..
						"2. Retrieve the carpet items\n" ..
						"3. Place the items back into the house\n" ..
						"4. Start Magic Carpet again\n|r"
					d(MESSAGE)
					MC.NotificationUI:QueueMessage(MESSAGE)
					EVENT_MANAGER:UnregisterForUpdate("MC.IdleCheck")
				end
			end )
		end
	end

end


function MC.Engine:OnDeactivated()

	MagicCarpetHighLatencyWarning:SetHidden(true)
	self.CombatMode = false
	self:UnregisterCombatEvents()
	self:ResetUsingAnyAvailableMode()

	MC.GameSettings:RestoreAllSettings()

end


function MC.Engine:ResetUsingAnyAvailableMode()

	if self:IsUsingAnyAvailableMode() then
		self:SetMode( MC.Mode:GetDefaultMode() )
		self:SetUsingAnyAvailableMode( false )
	end

end


function MC.Engine:IsUsingAnyAvailableMode()

	return true == MC.Vars.Settings.UsingAnyAvailableMode

end


function MC.Engine:SetUsingAnyAvailableMode( value )

	MC.Vars.Settings.UsingAnyAvailableMode = value

end


function MC.Engine:RegisterCombatEvents()

	if 0 ~= GetCurrentZoneHouseId() then
		EVENT_MANAGER:RegisterForEvent( COMBAT_HANDLE, EVENT_COMBAT_EVENT, MC.Engine.OnCombatEvent )
		return true
	else
		self:UnregisterCombatEvents()
		return false
	end

end


function MC.Engine:UnregisterCombatEvents()

	EVENT_MANAGER:UnregisterForEvent( COMBAT_HANDLE, EVENT_COMBAT_EVENT )
	return true

end


function MC.Engine.OnCombatEvent( event, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, logged, sourceUnitId, targetUnitId, abilityId )

	if isError then return end

	local self = MC.Engine

	if result == ACTION_RESULT_BEGIN and abilityId == ABILITY_ID_ZONE_JUMP and sourceType == COMBAT_UNIT_TYPE_PLAYER then
		if self:IsActive() then
			if self:Deactivate() then
				df( "Automatically deactivating %s in preparation for jump...", MC.CONST.ADDON_TITLE_SHORT )
			end

			self:UnregisterCombatEvents()
		end
	end

	if not self.CombatMode then return end

	if targetType == COMBAT_UNIT_TYPE_PLAYER then

		if result == ACTION_RESULT_EFFECT_GAINED then

			if abilityId == ABILITY_ID_BLOCK then
				self.State.LastBlock = GetFrameTimeMilliseconds()
				self.State.Blocking = true
			elseif abilityId == ABILITY_ID_CLOAK_SHADOW or abilityId == ABILITY_ID_CLOAK_DARK or abilityId == ABILITY_ID_CLOAK_DISGUISE then
				self.State.LastCloak = GetFrameTimeMilliseconds()
				self.State.Cloaking = true
			elseif abilityId == ABILITY_ID_HIDDEN then
				self.State.LastHidden = GetFrameTimeMilliseconds()
				self.State.Hidden = true
			elseif abilityId == ABILITY_ID_INTERRUPT then
				self.State.LastInterrupt = GetFrameTimeMilliseconds()
			elseif abilityId == ABILITY_ID_ROLL_DODGE then
				self.State.LastRollDodge = GetFrameTimeMilliseconds()
				self.State.RollDodging = true
			elseif abilityId == ABILITY_ID_SPRINT then
				self.State.LastSprint = GetFrameTimeMilliseconds()
				self.State.Sprinting = true
			end

		elseif result == ACTION_RESULT_EFFECT_FADED then

			if abilityId == ABILITY_ID_BLOCK then
				self.State.Blocking = false
			elseif abilityId == ABILITY_ID_CLOAK_SHADOW or abilityId == ABILITY_ID_CLOAK_DARK or abilityId == ABILITY_ID_CLOAK_DISGUISE then
				self.State.Cloaking = false
			elseif abilityId == ABILITY_ID_HIDDEN then
				self.State.Hidden = false
			elseif abilityId == ABILITY_ID_ROLL_DODGE then
				self.State.RollDodging = false
			elseif abilityId == ABILITY_ID_SPRINT then
				self.State.Sprinting = false
			end

		end

		-- df( "Error: %s (%d), Ability: %s (%d), Source: %s (%d), Target: %s (%d) (id: %s)", isError and "Yes" or "No", result or 0, abilityName or "", abilityId or 0, sourceName or "", sourceType or 0, targetName or "", targetType or 0, tostring( targetUnitId or "" ) )

	end

end


function MC.Engine:QueueRefresh()

	self:DequeueRefresh()
	EVENT_MANAGER:RegisterForUpdate( REFRESH_HANDLE, MC.Vars.Settings.RefreshInterval, function() self:Refresh() end )

end


function MC.Engine:DequeueRefresh()

	EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )

end


function MC.Engine:Refresh()

	local mode = self:GetMode()

	if 0 >= GetCurrentZoneHouseId() or not self:IsActive() or nil == mode then
		self:DequeueRefresh()
		self:FinalizeDeactivation()
		return
	end

	self:UpdateState()

	if self:IsSuspended() then
		return
	end

	if self.State.Distance < MIN_THRESHOLD_MOVEMENT and GetHousingEditorMode() ~= HOUSING_EDITOR_MODE_DISABLED then
		return
	end

	local update = mode:GetUpdateFunction()
	update( self.State, self.Items, self.ModeData )

end


function MC.Engine:IsActive()

	return self.Active

end


function MC.Engine:SetActive( active )

	self.Active = active
	MC.CarpetButtonUI:Refresh()

end


function MC.Engine:ToggleActive()

	if self:IsActive() then
		return self:Deactivate()
	else
		return self:Activate()
	end

end


function MC.Engine:IsPanoramaViewEnabled()

	return MC.Vars.Settings.PanoramaView

end


function MC.Engine:SetPanoramaViewEnabled( enabled )

	MC.Vars.Settings.PanoramaView = enabled
	if self.State then self.State.PanoramaView = enabled end

end


function MC.Engine:IsLocked()

	return self.Locked

end


function MC.Engine:SetLocked( locked )

	self.Locked = locked

	if locked then
		MC.ProcessUI:Show()
	else
		MC.ProcessUI:Hide()
	end

end


function MC.Engine:IsSuspended()

	return self.Suspended

end


function MC.Engine:ToggleSuspended( value )

	if nil == value then value = not self.Suspended end
	self.Suspended = value

end


function MC.Engine:ToggleAscend( value )

	if nil == value then value = not self.Ascending end
	self.Ascending = value
	if value then self:ToggleDescend( false ) end

end


function MC.Engine:ToggleDescend( value )

	if nil == value then value = not self.Descending end
	self.Descending = value
	if value then self:ToggleAscend( false ) end

end


function MC.Engine:GetOffsetY()

	return MC.Vars.Settings.OffsetY or 0

end


function MC.Engine:AdjustOffsetY( offset )

	if "number" == type( offset ) then
		local previousOffsetY = MC.Vars.Settings.OffsetY
		MC.Vars.Settings.OffsetY = zo_clamp( MC.Vars.Settings.OffsetY + offset, MC.CONST.MIN_OFFSET_Y, MC.CONST.MAX_OFFSET_Y )

		if MC.LamPanel then
			CALLBACK_MANAGER:FireCallbacks( "LAM-RefreshPanel", MC.LamPanel )
		end

		return previousOffsetY ~= MC.Vars.Settings.OffsetY
	end

	return false

end


function MC.Engine:GetMode()

	return self.CurrentMode

end


function MC.Engine:HasModeAttribute( attribute )

	if not self.CurrentMode then return false end
	return self.CurrentMode:HasAttribute( attribute )

end


function MC.Engine:GetModeComponents()

	local mode = self:GetMode()
	if nil == mode then return nil end

	local components = mode:GetComponents()
	return components

end


function MC.Engine:GetAvailableModeComponents( searchOptions )

	local components = self:GetModeComponents()
	if nil == components then return nil end

	-- If the player cannot place items, disable any source other than the House itself.

	if nil == searchOptions or "table" ~= type( searchOptions ) then searchOptions = { } end
	if not MC.House:IsOwner() then
		searchOptions.SearchBackpack, searchOptions.SearchBank = false, false
	end

	-- Search for the required components.

	local available, total, list, avgDistance = MC.Furniture:SearchItems( components, searchOptions )
	return available, total, list, avgDistance

end


function MC.Engine:AreModeRequirementsMet()

	local available, total, components = MC.Engine:GetAvailableModeComponents()
	return available and available >= total and MC.House:IsCurrentlyInAHouse() and MC.House:CanEditCurrentHouse()

end


function MC.Engine:CanComponentsBePlaced()

	local available, total, components = MC.Engine:GetAvailableModeComponents()
	if not components or not available or available < total then return false end

	local limits = MC.House:GetCurrentLimits()
	local limit, limitType

	for limitType, limit in pairs( limits ) do
		limit.Valid = false
	end

	for _, item in ipairs( components ) do
		if nil == item.FurnitureId or 0 >= item.FurnitureId then
			limitType = MC.Furniture:GetLimitType( item.Link )
			limit = limits[ limitType ]

			if nil ~= limit then
				limit.Used = limit.Used + 1

				-- This flag indicates that we are trying to place items of this limit type for this Mode.
				limit.Valid = true
			end
		end
	end

	local slotShortage = 0

	for limitType, limit in pairs( limits ) do
		if limit.Valid and limit.Used > limit.Max then
			slotShortage = slotShortage + ( limit.Used - limit.Max )
		end
	end

	return 0 >= slotShortage, slotShortage

end


function MC.Engine:CanSetMode()

	return not self:IsActive() and not self:IsLocked()

end


function MC.Engine:SetMode( mode )

	if self:CanSetMode() and MC.Mode:IsInstance( mode ) then
		self.CurrentMode = mode
		MC.CarpetUI:SetMostRecentMode( mode )
		return true
	end

	return false

end


function MC.Engine:IsStateReadyForActivation()

	if nil == self:GetMode() then return false, "No mode selected. Please select a mode first with the MC button." end
	if self:IsActive() then return false, "Engine is already active." end
	if self:IsLocked() then return false, "Engine is currently busy." end
	if not MC.House:IsCurrentlyInAHouse() then return false, "Not currently in a house." end
	if not MC.House:CanEditCurrentHouse() then return false, "Cannot edit current house." end

	return true

end


function MC.Engine:CanActivate()

	local ready, message = self:IsStateReadyForActivation()
	if not ready then
		return ready, message
	end

	if not self:GetMode():IsActive() then
		MC.CarpetUI:Show()
		return false, "The selected mode is not yet available." .. SELECT_DIFFERENT_MODE
	end
	if not self:AreModeRequirementsMet() then
		MC.CarpetUI:Show()
		return false, "One or more required items are missing." .. SELECT_DIFFERENT_MODE
	end
	if not self:GetMode():GetUpdateFunction() then
		MC.CarpetUI:Show()
		return false, "The selected mode is corrupt or misconfigured." .. SELECT_DIFFERENT_MODE
	end

	local valid, slotsRequired = self:CanComponentsBePlaced()
	if not valid then
		MC.CarpetUI:Show()
		return false, string.format( "Components exceed house limits by %d slots.\nPlease make additional space or select a different mode.", slotsRequired or -1 )
	end

	return true

end


function MC.Engine:CanDeactivate()

	if not self:IsActive() then return false, "Engine is already inactive." end
	if self:IsLocked() then return false, "Engine is currently busy." end
	if not MC.House:IsCurrentlyInAHouse() then return false, "Not currently in a house." end
	if not MC.House:CanEditCurrentHouse() then return false, "Cannot edit current house." end

	return true

end


function MC.Engine:Activate()

	if nil == self:GetMode() then self:SetMode( MC.Mode:GetDefaultMode() ) end

	local ready, message = self:IsStateReadyForActivation()
	if not ready then
		return ready, message
	end

	local available, total, components, avgDistance

	self:SetUsingAnyAvailableMode( false )

	if self:GetMode():HasAttribute( MC.Mode.ATTRIBUTE.ANY_AVAILABLE ) then

		availble, total, components, avgDistance = 0, 0, nil, math.huge
		local mAvailable, mTotal, mComponents, mAvgDistance
		local allModes = MC.Mode:GetModesByAttribute( MC.Mode.ATTRIBUTE.FLIGHT )
		local cMode, bestMode

		for index = 1, #allModes do
			cMode = allModes[index]
			self:SetMode( cMode )
			mAvailable, mTotal, mComponents, mAvgDistance = self:GetAvailableModeComponents()
			--df( "%s: %s, %s", cMode:GetName(), tostring( mAvailable ), tostring( mAvgDistance ) )
			if mComponents and mAvailable and mTotal and mAvailable >= mTotal and mAvgDistance and mAvgDistance < avgDistance then
				bestMode = cMode
				available, total, components, avgDistance = mAvailable, mTotal, mComponents, mAvgDistance
			end
		end

		if bestMode then
			self:SetMode( bestMode )

			if not self:CanActivate() then
				self:SetMode( MC.Mode:GetDefaultMode() )
				return false, "No modes are ready based on the available items."
			end

			self:SetUsingAnyAvailableMode( true )
		else
			self:SetMode( MC.Mode:GetDefaultMode() )
			return false, "No modes are ready based on the available items."
		end

	else

		local canActivate, message = self:CanActivate()
		if not canActivate then
			return false, message
		end

		available, total, components = MC.Engine:GetAvailableModeComponents()
		if not components or not available or available < total then
			return false
		end

	end

	MC.CarpetUI:Hide()

	self:ResetState()
	self:SetActive( true )
	self:SetLocked( true )
	self.OriginalItems = components

	local list = { }
	for index = 1, #components do
		if nil == components[index].FurnitureId or 0 >= components[index].FurnitureId then
			table.insert( list, components[ index ] )
		end
	end

	if 0 < #list then

		MC.Transaction:New(

			"Start Engine",

			{ Index = 0, List = list },

			function( tran )

				local data = tran:GetData()
				local index = data.Index + 1
				data.Index = index
				local item = data.List[index]
				if nil == item then return true end

				MC.ProcessUI:SetStatus( string.format( "Placing items (%d of %d)", index, #data.List ) )

				local x, y, z = GetPlayerWorldPositionInHouse()
				if nil ~= item.BagId and 0 < item.BagId and nil ~= item.Slot then
					HousingEditorRequestItemPlacement( item.BagId, item.Slot, x, y + 100, z, 0, 0, 0 )
				elseif nil ~= item.CollectibleId and 0 == item.FurnitureId then
					HousingEditorRequestCollectiblePlacement( item.CollectibleId, x, y + 100, z, 0, 0, 0 )
				end

			end,

			nil,

			function()

				MC.ProcessUI:SetStatus( "" )
				self:ActivatePrepared()

			end

		)

	else

		self:ActivatePrepared()

	end

	return true

end


function MC.Engine:AbortActivation( message )

	self:SetLocked( false )
	self:SetActive( false )

	d( "Engine failed to start:" )

	if nil ~= message then
		d( message )
	else
		d( "Unknown cause." )
	end

end


function MC.Engine:ActivatePrepared()

	-- Enable house search to ensure that items just placed from inventory/bank are matched and used.
	local available, total, components = self:GetAvailableModeComponents( { SearchHouse = true } )
	if not components or not available or available < total then
		self:AbortActivation()
		return false
	end

	self.ModeData = { }
	self.Items = { }

	for index = 1, #components do
		table.insert( self.Items, index, MC.Furniture:New( components[ index ].FurnitureId ) )
	end

	local mode = self:GetMode()
	local setupFunc = mode:GetSetupFunction()

	if nil == setupFunc then
		self:FinalizeActivation()
	else
		setupFunc( function() self:FinalizeActivation() end, self.State, self.Items, self.ModeData )
	end

end


function MC.Engine:FinalizeActivation()

	self:QueueRefresh()
	self:SetLocked( false )
	self:OnActivated()

end


function MC.Engine:Deactivate()

	local canActivate, message = self:CanDeactivate()
	if not canActivate then return false, message end

	self:DequeueRefresh()
	self:SetLocked( true )

	local retainItemIds, originals = { }, self.OriginalItems
	local current = self.Items

	if nil ~= originals and 0 < #originals then
		for index = 1, #originals do
			if originals[index] then
				if nil ~= originals[index].FurnitureId and 0 ~= originals[index].FurnitureId then
					retainItemIds[ Id64ToString( originals[index].FurnitureId ) ] = originals[index]
				end
			end
		end
	end

	if nil ~= current then

		MC.Transaction:New(
			"Shut Engine",
			{ Index = 0, List = current, Retain = retainItemIds },
			function( tran )

				local data = tran:GetData()
				local index = data.Index + 1
				local item = data.List[index]
				if nil == item then return true end

				MC.ProcessUI:SetStatus( string.format( "Restoring items (%d of %d)", index, #data.List ) )

				local original = data.Retain[ Id64ToString( item:GetFurnitureId() ) ]
				if not original then
					HousingEditorRequestRemoveFurniture( item:GetFurnitureId() )
				else
					local parentId = GetPlacedFurnitureParent( item:GetFurnitureId() )
					if nil ~= parentId then
						HousingEditorRequestClearFurnitureParent( item:GetFurnitureId() )
						return false, 500
					else
						item:SetPositionAndOrientation( original.X, original.Y, original.Z, original.Pitch, original.Yaw, original.Roll )
					end
				end

				data.Index = index

			end,
			nil,
			function()

				MC.ProcessUI:SetStatus( "" )
				self:FinalizeDeactivation()

			end
		)

	else

		self:FinalizeDeactivation()

	end

	return true, nil

end


function MC.Engine:FinalizeDeactivation()

	self:SetActive( false )
	self:SetLocked( false )
	self:OnDeactivated()

end


local function SetVectorMap( t, x, y, z )
	t.X, t.Y, t.Z = x, y, z
end


local function MergeVectorMap( t1, t2 )
	t1.X, t1.Y, t1.Z = t2.X, t2.Y, t2.Z
end


function MC.Engine:UpdateState()

	local s = self.State
	local x, y, z, heading = GetPlayerWorldPositionInHouse()
	local cameraHeading = GetPlayerCameraHeading()
	local ms = GetGameTimeMilliseconds()
	local deltaMs
	local comp = s.VelocityCompensation

	if 0 ~= comp then
		x, y, z = x + comp * s.VelocityVect.X, y + comp * s.VelocityVect.Y, z + comp * s.VelocityVect.Z
	end

	if 0 ~= ForceAscendToY then
		if ForceAscendToY > (y + 1) then
			if y >= s.StableY or (s.StableY - y) < 25 then
				y = math.max(y, s.StableY)
				y = y + zo_clamp(zo_lerp(0.1, 0.5, (ForceAscendToY - y) / 10), 0.1, 0.5)
			end

			s.PreviousPosition.Y = y
			s.Position.Y = y
			s.StableY = y
			s.PreviousStableY = y
--[[
			s.PreviousPosition.Y = math.max( y, s.PreviousPosition.Y + 1.5 )
			y = s.PreviousPosition.Y
			s.StableY = y
			s.PreviousStableY = y
]]
		else
			ForceAscendToY = 0
		end
	end

	s.PreviousFrameMS = s.FrameMS
	s.PreviousFrameDeltaMS = s.FrameDeltaMS
	MergeVectorMap( s.PreviousPosition, s.Position )
	s.PreviousHeading = s.Heading
	s.PreviousCameraHeading = s.CameraHeading
	s.PreviousStableY = s.StableY
	MergeVectorMap( s.PreviousDistanceVect, s.DistanceVect )
	s.PreviousDistance = s.Distance
	s.PreviousDistanceY = s.DistanceY
	s.PreviousDistanceXZ = s.DistanceXZ
	s.PreviousDistanceAngle = s.DistanceAngle
	s.PreviousDistanceHeading = s.DistanceHeading
	MergeVectorMap( s.PreviousVelocityVect, s.VelocityVect )
	s.PreviousVelocity = s.Velocity
	s.PreviousVelocityY = s.VelocityY
	s.PreviousVelocityXZ = s.VelocityXZ
	s.PreviousVelocityHeading = s.VelocityHeading

	s.FrameMS = ms
	deltaMs = ms - s.PreviousFrameMS
	s.FrameDeltaMS = deltaMs
	SetVectorMap( s.Position, x, y, z )
	s.Heading = heading
	s.CameraHeading = cameraHeading
	if 0 == ForceAscendToY and s.StabilizationThresholdY < math.abs( y - s.PreviousStableY ) then
		s.StableY = y
	end
	SetVectorMap( s.DistanceVect, x - s.PreviousPosition.X, y - s.PreviousPosition.Y, z - s.PreviousPosition.Z )
	s.Distance = zo_distance3D( x, y, z, s.PreviousPosition.X, s.PreviousPosition.Y, s.PreviousPosition.Z )
	s.DistanceY = y - s.PreviousPosition.Y
	s.DistanceXZ = zo_distance3D( x, 0, z, s.PreviousPosition.X, 0, s.PreviousPosition.Z )
	if 4 < math.abs( x - s.PreviousPosition.X ) or 4 < math.abs( z - s.PreviousPosition.Z ) then
		s.DistanceAngle = math.atan2( x - s.PreviousPosition.X, z - s.PreviousPosition.Z )
	end
	s.DistanceHeading = heading - s.PreviousHeading,
	SetVectorMap( s.VelocityVect, s.DistanceVect.X / deltaMs, s.DistanceVect.Y / deltaMs, s.DistanceVect.Z / deltaMs )
	s.Velocity = s.Distance / deltaMs
	s.VelocityY = s.DistanceY / deltaMs
	s.VelocityXZ = s.DistanceXZ / deltaMs
	s.VelocityHeading = s.DistanceHeading / deltaMs

	s.Ascending, s.Descending = self.Ascending, self.Descending
	s.OffsetY = MC.Vars.Settings.OffsetY

	if s.PreviousStableY == s.PreviousStableY and 2 > s.DistanceXZ then
		if nil == s.IdlingStart then
			s.IdlingStart = ms
		else
			s.IdlingTimer = ms - s.IdlingStart

			if s.IdlingTimer > MC.CONST.MAX_IDLE_TIMER then
				s.Idling, s.IdleAnimations = false, false
			else
				s.Idling = true
			end
		end
	else
		s.IdleAnimations, s.Idling, s.IdlingStart, s.IdlingTimer = MC.Vars.Settings.IdleAnimations, false, nil, nil
	end

	local framerate, latency = GetFramerate(), GetLatency()
	if s.PanoramaView and ( framerate < MC.Mode.PANORAMA_VIEW_MIN_FRAMEFRATE * 1 or latency > MC.Mode.PANORAMA_VIEW_MAX_LATENCY * 1 ) then
		s.PanoramaView = false
	elseif ( framerate >= MC.Mode.PANORAMA_VIEW_MIN_FRAMEFRATE and latency <= MC.Mode.PANORAMA_VIEW_MAX_LATENCY ) and MC.Engine:IsPanoramaViewEnabled() then
		s.PanoramaView = true
	end
	
	MagicCarpetHighLatencyWarning:SetHidden(GetLatency() <= MC.CONST.MAX_LATENCY_MS)

end


function MC.Engine:ResetState()

	MagicCarpetHighLatencyWarning:SetHidden(true)

	self.Suspended = false
	self.Ascending = false
	self.Descending = false
	self.State = {

		PanoramaView = MC.Engine:IsPanoramaViewEnabled(),
		StabilizationThresholdY = 10,
		VelocityCompensation = 0,

		PreviousFrameMS = 1,
		PreviousFrameDeltaMS = 1,
		PreviousPosition = { X = 1, Y = 1, Z = 1 },
		PreviousHeading = math.rad( 1 ),
		PreviousCameraHeading = math.rad( 1 ),
		PreviousStableY = 1,
		PreviousDistanceVect = { X = 1, Y = 1, Z = 1 },
		PreviousDistance = 1,
		PreviousDistanceY = 1,
		PreviousDistanceXZ = 1,
		PreviousDistanceAngle = math.rad( 1 ),
		PreviousDistanceHeading = math.rad( 1 ),
		PreviousVelocityVect = { X = 0.01, Y = 0.01, Z = 0.01 },
		PreviousVelocity = 0.01,
		PreviousVelocityY = 0.01,
		PreviousVelocityXZ = 0.01,
		PreviousVelocityHeading = math.rad( 0.01 ),

		FrameMS = 1,
		FrameDeltaMS = 1,
		Position = { X = 1, Y = 1, Z = 1 },
		Heading = math.rad( 1 ),
		CameraHeading = math.rad( 1 ),
		StableY = 1,
		DistanceVect = { X = 1, Y = 1, Z = 1 },
		Distance = 1,
		DistanceY = 1,
		DistanceXZ = 1,
		DistanceAngle = math.rad( 1 ),
		DistanceHeading = math.rad( 1 ),
		VelocityVect = { X = 0.01, Y = 0.01, Z = 0.01 },
		Velocity = 0.01,
		VelocityY = 0.01,
		VelocityXZ = 0.01,
		VelocityHeading = math.rad( 0.01 ),

		Ascending = false,
		Descending = false,
		IdleAnimations = MC.Vars.Settings.IdleAnimations,
		OffsetY = 0,
		Idling = nil,
		IdlingStart = nil,
		IdlingTimer = nil,

	}

end


------[[ Helper Functions ]]------


function MC.Engine:LinkItemsToPrimary( updateFunc, completeFunc, state, items, data )

	local x, y, z = GetPlayerWorldPositionInHouse()

	MC.Transaction:New(

		"Configure Components",

		{ Index = 0, List = items, X = x, Y = y - 500, Z = z },

		function( tran )

			local data = tran:GetData()
			local index = data.Index + 1
			local item = data.List[index]
			if nil == item then return true end
			local id = item:GetFurnitureId()

			if not data.Initialized then
				for index, listItem in ipairs( data.List ) do
					if nil ~= GetPlacedFurnitureParent( listItem:GetFurnitureId() ) then
						MC.ProcessUI:SetStatus( string.format( "Preparing items (%d of %d)", index, #data.List ) )
						local result = HousingEditorRequestClearFurnitureParent( listItem:GetFurnitureId() )

						if 0 ~= result then
							MC.Engine:AbortActivation( string.format( "Failed to clear the parent of one or more items. (Code %s)", tostring( result ) ) )
							return true
						end

						return false, 500
					end
				end

				data.Initialized = true
			end

			MC.ProcessUI:SetStatus( string.format( "Linking items (%d of %d)", index, #data.List ) )

			if 1 == index % HOUSING_MAX_FURNITURE_CHILDREN then
				if 1 == index then
					if nil ~= GetPlacedFurnitureParent( id ) then
						local result = HousingEditorRequestClearFurnitureParent( id )
--df( "%d. Cleared furniture parent of %s", index, Id64ToString( id ) )

						if 0 ~= result then
							MC.Engine:AbortActivation( string.format( "Failed to clear the parent of the linked list head item. (Code %s, Id %s)", tostring( result ), Id64ToString( id ) ) )
							return true
						end

						return false, 500
					else
--df( "%d. Parent item prepared.", index )
					end
				else
					local predecessorIndex = 1 + math.floor( ( index - 2 ) / HOUSING_MAX_FURNITURE_CHILDREN ) * HOUSING_MAX_FURNITURE_CHILDREN
					local predecessorId = items[ predecessorIndex ]:GetFurnitureId()

					if predecessorId ~= GetPlacedFurnitureParent( id ) then
						local result = HousingEditorRequestSetFurnitureParent( id, predecessorId )
--df( "%d. Set furniture parent of node parent %s", index, Id64ToString( id ) )
--df( "Result: %d", result )
						if 0 ~= result then
							MC.Engine:AbortActivation( string.format( "Failed to set the parent of a linked list node item. (Code %s, Index %d, Id %s, Predecessor Index %d, Predecessor Id %s)", tostring( result ), index, Id64ToString( id ), predecessorIndex, Id64ToString( predecessorId ) ) )
							return true
						end

						return false, 500
					else
--df( "%d. Node parent prepared.", index )
					end
				end
			else
				local parentIndex = 1 + math.floor( ( index - 2 ) / HOUSING_MAX_FURNITURE_CHILDREN ) * HOUSING_MAX_FURNITURE_CHILDREN
				local parentId = items[ parentIndex ]:GetFurnitureId()
				local currentParentId = GetPlacedFurnitureParent( id )
--df( "%s ?= %s", Id64ToString( parentId ), currentParentId and Id64ToString( currentParentId ) or "nil" )
				if nil == currentParentId or Id64ToString( parentId ) ~= Id64ToString( currentParentId ) then
					local result = HousingEditorRequestSetFurnitureParent( id, parentId )
--df( "%d. Set furniture parent of node child %s to %s", index, Id64ToString( id ), Id64ToString( parentId ) )
--df( "Result: %d", result )
					if 0 ~= result then
						MC.Engine:AbortActivation( string.format( "Failed to set the parent of a child item. (Code %s, Index %d, Child Id %s, Parent Index %d, Parent Id %s)", tostring( result ), index, Id64ToString( id ), parentIndex, Id64ToString( parentId ) ) )
						return true
					end

					return false, 500
				else
--df( "%d. Furniture parent already set for node child %s", index, Id64ToString( id ) )
				end
			end

			if updateFunc then updateFunc( data, index, item, items ) end
			data.Index = index

			return false, 100

		end,

		nil,

		completeFunc

	)

end


------[[ 3D Functions ]]------


function MC.Engine:GetRotationMatrix( pitch, yaw, roll )

	local siny, cosy = math.sin( yaw ), math.cos( yaw )
	--siny, cosy = round( siny, 6 ), round( cosy, 6 )
	local ym = matrix {
		{ 1, 0, 0 },
		{ 0, cosy, -siny },
		{ 0, siny, cosy }
	}

	local sinp, cosp = math.sin( pitch ), math.cos( pitch )
	--sinp, cosp = round( sinp, 6 ), round( cosp, 6 )
	local pm = matrix {
		{ cosp, 0, sinp },
		{ 0, 1, 0 },
		{ -sinp, 0, cosp }
	}

	local sinr, cosr = math.sin( roll ), math.cos( roll )
	--sinr, cosr = round( sinr, 6 ), round( cosr, 6 )
	local rm = matrix {
		{ cosr, -sinr, 0 },
		{ sinr, cosr, 0 },
		{ 0, 0, 1 }
	}

	return matrix.mul( rm, matrix.mul( pm, ym ) )

end


function MC.Engine:GetRotationMatrixPosition( m )

	local y = m[1][1]
	local x = m[1][2]
	local z = m[1][3]

	return round( y, 2 ), round( x, 2 ), round( z, 2 )

end


function MC.Engine:GetRotationMatrixOrientation( m )

	local pitch = -math.asin( m[3][1] )
	local yaw = -math.atan2( -m[3][2], m[3][3] )
	local roll = -math.atan2( -m[2][1], m[1][1] )

	return pitch, yaw, roll

end


function MC.Engine:RotateAxisX( x, y, z, radians )

	local c, s = math.cos( radians ), math.sin( radians )
	return x	,	y * c - z * s	,	y * s + z * c

end


function MC.Engine:RotateAxisY( x, y, z, radians )

	local c, s = math.cos( radians ), math.sin( radians )
	return z * s + x * c	,	y	,	z * c - x * s

end


function MC.Engine:RotateAxisZ( x, y, z, radians )

	local c, s = math.cos( radians ), math.sin( radians )
	return x * c - y * s	,	x * s + y * c	,	z

end


function MC.Engine:Rotate( x, y, z, radX, radY, radZ )

	x, y, z = MC.Engine:RotateAxisZ( x, y, z, radZ )
	x, y, z = MC.Engine:RotateAxisX( x, y, z, radX )
	x, y, z = MC.Engine:RotateAxisY( x, y, z, radY )
	return x, y, z

end



function MC.Engine:CalculateRotation( targetPitch, targetYaw, targetRoll, currentPitch, currentYaw, currentRoll, currentX, currentY, currentZ, relativePitch, relativeYaw, relativeRoll, relativeX, relativeY, relativeZ, debugMode )

	local x, y, z, pitch, yaw, roll = nil, nil, nil, nil, nil, nil

	-- Build target rotation transformation matrix.
	local targetTransform = MC.Engine:GetRotationMatrix( targetPitch, targetYaw, targetRoll )
	local inverseRelativeOrientationTransform = nil

	if nil ~= relativePitch then
		-- Build inverse relative rotation transformation matrix.
		inverseRelativeOrientationTransform = matrix.invert( MC.Engine:GetRotationMatrix( relativePitch, relativeYaw, relativeRoll ) )
	end

	-- Rotate Position
	if nil ~= currentX and nil ~= relativeX then

		local newPosition = matrix { { currentY, currentX, currentZ } }

		-- Offset position by relative position.
		newPosition[1][1], newPosition[1][2], newPosition[1][3] = newPosition[1][1] - relativeY, newPosition[1][2] - relativeX, newPosition[1][3] - relativeZ

		if nil ~= inverseRelativeOrientationTransform then
			-- Offset position by relative orientation.
			newPosition = matrix.mul( newPosition, inverseRelativeOrientationTransform )
		end

		-- Rotate position using target pitch, yaw and roll.
		newPosition = matrix.mul( newPosition, targetTransform )

		-- Extract y, x and z from rotation output matrix.
		y, x, z = MC.Engine:GetRotationMatrixPosition( newPosition )

		-- Reverse offset position by relative position.
		y, x, z = y + relativeY, x + relativeX, z + relativeZ

	end

	-- Rotate Orientation
	if nil ~= currentPitch then

		-- Current orientation matrix.
		local newOrientation = MC.Engine:GetRotationMatrix( currentPitch, currentYaw, currentRoll )

		if nil ~= inverseRelativeOrientationTransform then
			-- Offset orientation by relative orientation.
			newOrientation = matrix.mul( newOrientation, inverseRelativeOrientationTransform )
		end

		-- Rotate orientation using target pitch, yaw and roll.
		newOrientation = matrix.mul( newOrientation, targetTransform )

		-- Extract pitch, yaw and roll from rotation output matrix.
		pitch, yaw, roll = MC.Engine:GetRotationMatrixOrientation( newOrientation )

	end

	return pitch, yaw, roll, x, y, z

end


function MC.Engine:GetOrientationOffsets( offsetX, offsetY, offsetZ, pitch, yaw, roll )

	local _, _, _, x, y, z = MC.Engine:CalculateRotation( pitch, yaw, roll,		0, 0, 0,	offsetX, offsetY, offsetZ,		nil, nil, nil,		0, 0, 0 )
	return x, y, z

end


function MC.Engine:AutoCalibrate( furnitureId, startY, yawOffset, xOffset, zOffset, calibrationSpeed )

	if nil == startY then startY = -100 end
	if nil == calibrationSpeed then calibrationSpeed = 100 end
	local pX, pY, pZ, pYaw = GetPlayerWorldPositionInHouse()

	MC.Engine.Calibration = {
		Id = furnitureId,
		XOffset = xOffset or 0,
		ZOffset = zOffset or 0,
		Iteration = 0,
		PlayerY = pY,
		Y = startY,
		YawOffset = yawOffset,
	}

	EVENT_MANAGER:UnregisterForUpdate( "MCEngine_AutoCalibrate" )
	EVENT_MANAGER:RegisterForUpdate( "MCEngine_AutoCalibrate", calibrationSpeed, function() MC.Engine:AutoCalibrateProcess() end )

end
-- /script MagicCarpet.Engine:AutoCalibrate( eid(), -120, 0, 0, 500 )

function MC.Engine:AutoCalibrateProcess()

	local c = MC.Engine.Calibration
	local xOffset, zOffset = c.XOffset, c.ZOffset
	local id = c.Id
	local iteration = c.Iteration
	local playerY = c.PlayerY
	local y = c.Y
	local yawOffset = math.rad( c.YawOffset )

	local pX, pY, pZ, pYaw = GetPlayerWorldPositionInHouse()
	local pitch, _, roll = HousingEditorGetFurnitureOrientation( id )
	local yaw = pYaw + yawOffset

	pX, pZ = pX + xOffset * math.sin( yaw ), pZ + zOffset * math.cos( yaw )
	HousingEditorRequestChangePositionAndOrientation( id, pX, pY + y, pZ, pitch, yaw, roll )

	if 0 < iteration then

		if pY > playerY then
			c.Offset = y - 1
			EVENT_MANAGER:UnregisterForUpdate( "MCEngine_AutoCalibrate" )
			d( "\nCalibration complete:" )
			d( c )
			return
		end

		c.PlayerY = pY

	end

	c.Iteration = iteration + 1
	c.Y = y + 1

end
