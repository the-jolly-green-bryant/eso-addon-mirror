--[[
Audio Control Doctor
by @DrGerm on the North American Megaserver
Code for Enabling and Disabling each of the Audio streams
--]]

-- Enable or Disable the Master Volume
function ACD.ToggleMasterEnabled()
    local currentMasterEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED)
	if (currentMasterEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED, "0")
	end
end

-- Enable or Disable Music Volume
function ACD.ToggleMusicEnabled()
    local currentMusicEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED)
	if (currentMusicEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, "0")
	end
end

-- Enable or Disable Ambient Volume
function ACD.ToggleAmbientEnabled()
    local currentAmbientEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED)
	if (currentAmbientEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED, "0")
	end
end

-- Enable or Disable Sound Effect Volume
function ACD.ToggleSFXEnabled()
    local currentSFXEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED)
	if (currentSFXEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED, "0")
	end
end

-- Enable or Disable Footsteps Volume
function ACD.ToggleFootstepsEnabled()
    local currentFootstepsEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED)
	if (currentFootstepsEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED, "0")
	end
end

-- Enable or Disable Dialogue Volume
-- apparently VO = Dialogue
function ACD.ToggleVOEnabled()
    local currentVOEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED)
	if (currentVOEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED, "0")
	end
end

-- Enable or Disable Interface Volume
-- UI = User Interface
function ACD.ToggleUIEnabled()
    local currentUIEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED)
	if (currentUIEnabled == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED, "0")
	end
end

-- Enable or Disable Plays in Background
function ACD.ToggleBackgroundAudio()
    local currentBackgroundAudio = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO)
	if (currentBackgroundAudio == "0") then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO, "1")
	else
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO, "0")
	end
end