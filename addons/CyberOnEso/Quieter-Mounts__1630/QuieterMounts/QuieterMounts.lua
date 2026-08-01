--[[

MuteMounts
by: @CyberOnEso

--]]

-- Addon info

local AddonName = "QuieterMounts"

local function OnMountedStateChanged(eventCode, isMounted)
	if isMounted then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, 15)
	else
		SetFlashWaitTime(10000)
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, 80)
	end
end

EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)