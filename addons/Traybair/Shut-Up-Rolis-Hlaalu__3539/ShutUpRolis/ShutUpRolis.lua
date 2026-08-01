ShutUpRolis = {
	name = "ShutUpRolis",
}

local ShutUpRolis = ShutUpRolis
local initialDialogVolume
local chatterIsRegistered = false

local rolisZoneIds = {
	[383] = true,
	[57] = true,
	[19] = true,
}

function ShutUpRolis.muteIfRolisHlaalu()
	if GetUnitName("interact") == "Rolis Hlaalu" then
		EVENT_MANAGER:RegisterForEvent(ShutUpRolis.name, EVENT_CHATTER_END, ShutUpRolis.restoreDialogVolumeDelayed)

		-- Set Dialog Volume setting to 0
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, "0")
	end
end

function ShutUpRolis.restoreDialogVolumeDelayed()
	local currentDialogVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	if currentDialogVolume == 0 then
		EVENT_MANAGER:UnregisterForEvent(ShutUpRolis.name, EVENT_CHATTER_END)
		-- Delay because Rolis doesn't know when to shut up if the player backs out mid sentence. Typical Rolis behavior.
		zo_callLater(function()
			SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, initialDialogVolume)
		end, 500)
	end
end

-- Instant Dialog Volume Restore for PreHooks
function ShutUpRolis.restoreDialogVolumeInstant()
	local currentDialogVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	if currentDialogVolume == 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, initialDialogVolume)
	end
end

function ShutUpRolis.handleEventChatterBegin()
	local currentZone = GetZoneId(GetUnitZoneIndex("player"))

	if rolisZoneIds[currentZone] and not chatterIsRegistered then
		EVENT_MANAGER:RegisterForEvent(ShutUpRolis.name, EVENT_CHATTER_BEGIN, ShutUpRolis.muteIfRolisHlaalu)
		chatterIsRegistered = true
	elseif not rolisZoneIds[currentZone] and chatterIsRegistered then
		EVENT_MANAGER:UnregisterForEvent(ShutUpRolis.name, EVENT_CHATTER_BEGIN)
		chatterIsRegistered = false
	end
end

function ShutUpRolis.Initialize()
	EVENT_MANAGER:UnregisterForEvent(ShutUpRolis.name, EVENT_ADD_ON_LOADED)

	EVENT_MANAGER:RegisterForEvent(ShutUpRolis.name, EVENT_PLAYER_ACTIVATED, ShutUpRolis.handleEventChatterBegin)
	initialDialogVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	chatterIsRegistered = false

	-- Invoke restoreDialogVolumeInstant() before executing ReloadUI(), Logout(), or Quit()
	ZO_PreHook("ReloadUI", ShutUpRolis.restoreDialogVolumeInstant)
	ZO_PreHook("Logout", ShutUpRolis.restoreDialogVolumeInstant)
	ZO_PreHook("Quit", ShutUpRolis.restoreDialogVolumeInstant)
end

function ShutUpRolis.OnAddOnLoaded(event, addonName)
	if addonName == ShutUpRolis.name then
		ShutUpRolis.Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(ShutUpRolis.name, EVENT_ADD_ON_LOADED, ShutUpRolis.OnAddOnLoaded)
