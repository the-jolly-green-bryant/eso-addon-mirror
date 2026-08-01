-- RdK Group Tool Follow The Crown Audio
-- By @s0rdrak (PC / EU)

RdKGTool.group.ftca = RdKGTool.group.ftca or {}
local RdKGToolFtca = RdKGTool.group.ftca
RdKGTool.menu = RdKGTool.menu or {}
local RdKGToolMenu = RdKGTool.menu
RdKGTool.util = RdKGTool.util or {}
local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.group = RdKGToolUtil.group
local RdKGToolGroup = RdKGToolUtil.group
RdKGToolUtil.sound = RdKGToolUtil.sound or {}
local RdKGToolSound = RdKGToolUtil.sound

RdKGToolFtca.constants = RdKGToolFtca.constants or {}

RdKGToolFtca.callbackName = RdKGTool.addonName .. "FollowTheCrownAduio"

RdKGToolFtca.config = {}
RdKGToolFtca.config.updateInterval = 100

RdKGToolFtca.state = {}
RdKGToolFtca.state.initialized = false
RdKGToolFtca.state.registeredConsumer = false
RdKGToolFtca.state.lastPlayedSound = nil
RdKGToolFtca.state.isInRange = true

function RdKGToolFtca.Initialize()
	RdKGTool.profile.AddProfileChangeListener(RdKGToolFtca.callbackName, RdKGToolFtca.OnProfileChanged)
	
	RdKGToolFtca.state.sounds = RdKGToolSound.GetRestrictedSounds()
	
	RdKGToolFtca.state.initialized = true
	RdKGToolFtca.SetEnabled(RdKGToolFtca.ftcaVars.enabled)
end

function RdKGToolFtca.GetDefaults()
	local defaults = {}
	defaults.enabled = false
	defaults.maxDistance = 10
	defaults.ignoreDistance = 100
	defaults.pvpOnly = true
	defaults.interval = 3
	defaults.threshold = 3
	defaults.selectedSound = "BG_One_Minute_Warning"
	defaults.unmountedOnly = true
	return defaults
end

function RdKGToolFtca.SetEnabled(value)
	if RdKGToolFtca.state.initialized == true and value ~= nil then
		RdKGToolFtca.ftcaVars.enabled = value
		if value == true then
			if RdKGToolFtca.state.registeredConsumer == false then
				RdKGTool.util.group.AddFeature(RdKGToolFtca.callbackName, RdKGTool.util.group.features.FEATURE_GROUP_LEADER_DISTANCE, RdKGToolFtca.config.updateInterval)
				EVENT_MANAGER:RegisterForUpdate(RdKGToolFtca.callbackName, RdKGToolFtca.config.updateInterval, RdKGToolFtca.OnUpdate)
				EVENT_MANAGER:RegisterForEvent(RdKGToolFtca.callbackName, EVENT_END_SIEGE_CONTROL, RdKGToolFtca.SiegeEndEvent)
				EVENT_MANAGER:RegisterForEvent(RdKGToolFtca.callbackName, EVENT_MOUNTED_STATE_CHANGED, RdKGToolFtca.OnMountStateChanged)
				RdKGToolFtca.state.registeredConsumer = true
			end
		else
			if RdKGToolFtca.state.registeredConsumer == true then
				RdKGTool.util.group.RemoveFeature(RdKGToolFtca.callbackName, RdKGTool.util.group.features.FEATURE_GROUP_LEADER_DISTANCE)
				EVENT_MANAGER:UnregisterForUpdate(RdKGToolFtca.callbackName)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolFtca.callbackName, EVENT_END_SIEGE_CONTROL)
				EVENT_MANAGER:UnregisterForEvent(RdKGToolFtca.callbackName, EVENT_MOUNTED_STATE_CHANGED)
				RdKGToolFtca.state.registeredConsumer = false
			end
		end
	end
end

--callbacks
function RdKGToolFtca.OnProfileChanged(currentProfile)
	if currentProfile ~= nil then
		--RdKGToolFtca.SetEnabled(false)
		RdKGToolFtca.ftcaVars = currentProfile.group.ftca
		RdKGToolFtca.SetEnabled(RdKGToolFtca.ftcaVars.enabled)
	end
end

function RdKGToolFtca.OnUpdate()
	if IsUnitGrouped("player") == true and RdKGToolGroup.IsPlayerGroupLeader() == false and ( RdKGToolFtca.ftcaVars.pvpOnly == false or (RdKGToolFtca.ftcaVars.pvpOnly == true and RdKGToolUtil.IsInPvPArea())) then
		local distance = RdKGTool.util.group.GetLeaderDistance()
		if distance ~= nil then
			--d(IsPlayerControllingSiegeWeapon())
			if distance > RdKGToolFtca.ftcaVars.maxDistance and distance < RdKGToolFtca.ftcaVars.ignoreDistance then
				if RdKGToolFtca.state.isInRange == true then
					RdKGToolFtca.state.lastPlayedSound = GetTimeStamp() + RdKGToolFtca.ftcaVars.threshold - RdKGToolFtca.ftcaVars.interval
				end
				if RdKGToolFtca.state.lastPlayedSound == nil or (RdKGToolFtca.state.lastPlayedSound ~= nil and RdKGToolFtca.state.lastPlayedSound + RdKGToolFtca.ftcaVars.interval < GetTimeStamp()) then
					--d(IsPlayerControllingSiegeWeapon())
					if (RdKGToolFtca.ftcaVars.unmountedOnly == false or (RdKGToolFtca.ftcaVars.unmountedOnly == true and IsMounted() == false)) and IsPlayerControllingSiegeWeapon() == false and IsPlayerEscortingRam() == false and IsUnitDead("player") == false then
						RdKGToolSound.PlaySoundByName(RdKGToolFtca.ftcaVars.selectedSound)
						RdKGToolFtca.state.lastPlayedSound = GetTimeStamp() + RdKGToolFtca.ftcaVars.threshold - RdKGToolFtca.ftcaVars.interval
					else
						RdKGToolFtca.state.lastPlayedSound = GetTimeStamp() + RdKGToolFtca.ftcaVars.threshold - RdKGToolFtca.ftcaVars.interval
					end
				end
				RdKGToolFtca.state.isInRange = false
			else
				RdKGToolFtca.state.isInRange = true
			end
		end
	end
end

function RdKGToolFtca.SiegeEndEvent(eventCode)
	if eventCode == EVENT_END_SIEGE_CONTROL then
		RdKGToolFtca.state.lastPlayedSound = GetTimeStamp() + RdKGToolFtca.ftcaVars.threshold - RdKGToolFtca.ftcaVars.interval
	end
end

function RdKGToolFtca.OnMountStateChanged(eventCode, mounted)
	if eventCode == EVENT_MOUNTED_STATE_CHANGED and mounted == false then
		RdKGToolFtca.state.lastPlayedSound = GetTimeStamp() + RdKGToolFtca.ftcaVars.threshold - RdKGToolFtca.ftcaVars.interval
	end
end

--menu interaction
function RdKGToolFtca.GetMenu()
	local menu = {
		[1] = {
			type = "submenu",
			name = RdKGToolMenu.constants.FTCA_HEADER,
			--width = "full",
			controls = {
				[1] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCA_ENABLED,
					getFunc = RdKGToolFtca.GetFtcaEnabled,
					setFunc = RdKGToolFtca.SetFtcaEnabled,
				},
				[2] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCA_PVP_ONLY,
					getFunc = RdKGToolFtca.GetFtcaPvpOnly,
					setFunc = RdKGToolFtca.SetFtcaPvpOnly,
				},
				[3] = {
					type = "checkbox",
					name = RdKGToolMenu.constants.FTCA_UNMOUNTED_ONLY,
					getFunc = RdKGToolFtca.GetFtcaUnmountedOnly,
					setFunc = RdKGToolFtca.SetFtcaUnmountedOnly,
				},
				[4] = {
					type = "dropdown",
					name = RdKGToolMenu.constants.FTCA_SOUND,
					choices = RdKGToolFtca.GetFtcaAvailableSounds(),
					getFunc = RdKGToolFtca.GetFtcaSelectedSound,
					setFunc = RdKGToolFtca.SetFtcaSelectedSound,
					width = "full"
				},
				[5] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCA_DISTANCE,
					min = 0,
					max = 25,
					step = 1,
					getFunc = RdKGToolFtca.GetFtcaMaxDistance,
					setFunc = RdKGToolFtca.SetFtcaMaxDistance,
					width = "full",
					default = 8
				},
				[6] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCA_IGNORE_DISTANCE,
					min = 100,
					max = 1000,
					step = 1,
					getFunc = RdKGToolFtca.GetFtcaIgnoreDistance,
					setFunc = RdKGToolFtca.SetFtcaIgnoreDistance,
					width = "full",
					default = 100
				},
				[7] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCA_INTERVAL,
					min = 1,
					max = 10,
					step = 1,
					getFunc = RdKGToolFtca.GetFtcaInterval,
					setFunc = RdKGToolFtca.SetFtcaInterval,
					width = "full",
					default = 1
				},
				[8] = {
					type = "slider",
					name = RdKGToolMenu.constants.FTCA_THRESHOLD,
					min = 1,
					max = 25,
					step = 1,
					getFunc = RdKGToolFtca.GetFtcaThreshold,
					setFunc = RdKGToolFtca.SetFtcaThreshold,
					width = "full",
					default = 3
				}
			}
		}
	}
	return menu
end

function RdKGToolFtca.GetFtcaEnabled()
	return RdKGToolFtca.ftcaVars.enabled
end

function RdKGToolFtca.SetFtcaEnabled(value)
	RdKGToolFtca.SetEnabled(value)
end

function RdKGToolFtca.GetFtcaPvpOnly()
	return RdKGToolFtca.ftcaVars.pvpOnly
end

function RdKGToolFtca.SetFtcaPvpOnly(value)
	RdKGToolFtca.ftcaVars.pvpOnly = value
end

function RdKGToolFtca.GetFtcaUnmountedOnly()
	return RdKGToolFtca.ftcaVars.unmountedOnly
end

function RdKGToolFtca.SetFtcaUnmountedOnly(value)
	RdKGToolFtca.ftcaVars.unmountedOnly = value
end

function RdKGToolFtca.GetFtcaAvailableSounds()
	local sounds = {}
	for i = 1, #RdKGToolFtca.state.sounds do
		sounds[i] = RdKGToolFtca.state.sounds[i].name
	end
	return sounds
end

function RdKGToolFtca.GetFtcaSelectedSound()
	return RdKGToolFtca.ftcaVars.selectedSound
end

function RdKGToolFtca.SetFtcaSelectedSound(value)
	if value ~= nil then
		RdKGToolFtca.ftcaVars.selectedSound = value
		RdKGToolSound.PlaySoundByName(value)
	end
end

function RdKGToolFtca.GetFtcaMaxDistance()
	return RdKGToolFtca.ftcaVars.maxDistance
end

function RdKGToolFtca.SetFtcaMaxDistance(value)
	RdKGToolFtca.ftcaVars.maxDistance = value
end

function RdKGToolFtca.GetFtcaIgnoreDistance()
	return RdKGToolFtca.ftcaVars.ignoreDistance
end

function RdKGToolFtca.SetFtcaIgnoreDistance(value)
	RdKGToolFtca.ftcaVars.ignoreDistance = value
end

function RdKGToolFtca.GetFtcaInterval()
	return RdKGToolFtca.ftcaVars.interval
end

function RdKGToolFtca.SetFtcaInterval(value)
	RdKGToolFtca.ftcaVars.interval = value
end

function RdKGToolFtca.GetFtcaThreshold()
	return RdKGToolFtca.ftcaVars.threshold
end

function RdKGToolFtca.SetFtcaThreshold(value)
	RdKGToolFtca.ftcaVars.threshold = value
end
