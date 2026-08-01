------[[ Namespaces ]]------

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.Featherfall then MC.Featherfall = ZO_Object.New( ZO_Object:Subclass() ) end

------[[ Locals ]]------

local DEBUG_LEVEL = 0
local NS = "MC_Featherfall"

local REFRESH_HANDLE = NS .. "_Refresh"
local REFRESH_INTERVAL = 100

local FALL_THRESHOLD_MPS = 6.0		-- Minimum velocity (meters per second) to be considered falling.
local JUMP_THRESHOLD_M = 600		-- Disregard instantaneous travel distances that result from a jump operation, gap closer or streak.
local FF_THRESHOLD_M = 2000			-- Minimum distance to be considered in a state of freefall.

------[[ Methods ]]------

function MC.Featherfall.RefreshCallback()
	MC.Featherfall:Refresh()
end

function MC.Featherfall:Refresh()
	if not self:CanActivate() then
		self:SetActive( false )
		return
	end

	local state = self.State
	local firstState = false

	if nil == state then
		state = { }
		self.State = state
		firstState = true
	end

	local intervalTS = GetGameTimeMilliseconds()
	local intervalDelta = intervalTS - ( state.IntervalTS or intervalTS )
	if 0 >= intervalDelta then intervalDelta = 100 end

	local houseId = GetCurrentZoneHouseId()
	local x, y, z = GetPlayerWorldPositionInHouse()
	local beganFallingTS, beganFallingY, distance, fallDistance, sensitivity, velocityY = nil, nil, 0, 0, 0, 0

	if not firstState and houseId == state.HouseId then
		distance = zo_distance3D( x, y, z, state.X, state.Y, state.Z )

		if distance < JUMP_THRESHOLD_M then
			sensitivity, velocityY = self:GetSensitivity(), ( ( state.Y - y ) * ( 1000 / intervalDelta ) ) / 100

			if FALL_THRESHOLD_MPS < velocityY then
				if nil == state.BeganFallingTS then
					state.BeganFallingTS = intervalTS
					state.BeganFallingY = y
				end

				beganFallingTS, beganFallingY = state.BeganFallingTS, state.BeganFallingY
				fallDistance = beganFallingY - y

				if fallDistance >= sensitivity * FF_THRESHOLD_M then
					if 0 < DEBUG_LEVEL then D( ".\nts: %d, dI: %d, d: %d, v: %f, D: %d\nFEATHERFELL!", intervalTS or 0, intervalDelta or 0, distance or 0, velocityY or 0, fallDistance or 0 ) DEBUG_LEVEL = 0 end

					local isInstantFall = self.LastResetS and ( GetFrameTimeSeconds() - self.LastResetS ) < 6

					HousingEditorJumpToSafeLocation()
					self:ResetState()
					self:SuspendTemporarily( 2000 )

					local message
					if isInstantFall then
						message = "Oops. Looks like someone yanked the rug out from under you."
					else
						message = "Magic Carpet helped you land as softly as a feather"
					end

					MC.NotificationUI:QueueMessage( message )
					d( message )

					return
				end
			end
		end
	end

	state.IntervalTS, state.HouseId, state.X, state.Y, state.Z, state.BeganFallingTS, state.BeganFallingY = intervalTS, houseId, x, y, z, beganFallingTS, beganFallingY
	if 0 < DEBUG_LEVEL then D( ".\nts: %d, dI: %d, d: %d, v: %f, D: %d", intervalTS or 0, intervalDelta or 0, distance or 0, velocityY or 0, fallDistance or 0 ) end
end

function MC.Featherfall:SuspendTemporarily( duration )
	if self:IsEnabled() then
		EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )
		zo_callLater( function() EVENT_MANAGER:RegisterForUpdate( REFRESH_HANDLE, REFRESH_INTERVAL, MC.Featherfall.RefreshCallback ) end, duration )
		return true
	else
		return false
	end
end

function MC.Featherfall:IsEnabled()
	local enabled = MC.Vars.Settings.Featherfall
	return nil == enabled and true or enabled
end

function MC.Featherfall:SetEnabled( enabled )
	if nil ~= enabled and "boolean" == type( enabled ) then
		MC.Vars.Settings.Featherfall = enabled
	end
end

function MC.Featherfall:CanActivate()
	return self:IsEnabled() and 0 ~= GetCurrentZoneHouseId()
end

function MC.Featherfall:SetActive( active )
	self:ResetState()

	if self:CanActivate() then
		EVENT_MANAGER:RegisterForUpdate( REFRESH_HANDLE, REFRESH_INTERVAL, MC.Featherfall.RefreshCallback )
		return true
	else
		EVENT_MANAGER:UnregisterForUpdate( REFRESH_HANDLE )
		return false
	end
end

function MC.Featherfall:GetSensitivity()
	return MC.Vars.Settings.FeatherfallSensitivity or 1
end

function MC.Featherfall:SetSensitivity( coefficient )
	if "number" ~= type( coefficient ) then coefficient = 1.0 end
	MC.Vars.Settings.FeatherfallSensitivity = zo_clamp( coefficient, 0.8, 1.4 )
end

function MC.Featherfall:ResetState()
	self.State = nil
	self.LastResetS = GetFrameTimeSeconds()
end

------[[ Constructors ]]------

do
	local self = MC.Featherfall
	self.LastResetS = 0
	self.State = nil
end
