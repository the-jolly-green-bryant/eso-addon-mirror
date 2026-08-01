--[[
Audio Control Doctor
by @DrGerm on the North American Megaserver
Code for Increasing and Decreasing Volumes
--]]

--Increase the Master Volume
function ACD.IncreaseMasterVolume()
    local currentMasterVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME))
	if currentMasterVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, currentMasterVolume + 1)
	end
end

--Decrease the Master Volume
function ACD.DecreaseMasterVolume()
    local currentMasterVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME))
	if currentMasterVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME, currentMasterVolume - 1)
	end
end

--Increase the Music Volume
function ACD.IncreaseMusicVolume()
    local currentMusicVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME))
	if currentMusicVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, currentMusicVolume + 1)
	end
end

--Decrease the Music Volume
function ACD.DecreaseMusicVolume()
    local currentMusicVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME))
	if currentMusicVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, currentMusicVolume - 1)
	end
end

--Increase the Ambient Volume
function ACD.IncreaseAmbientVolume()
    local currentAmbientVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME))
	if currentAmbientVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, currentAmbientVolume + 1)
	end
end

--Decrease the Ambient Volume
function ACD.DecreaseAmbientVolume()
    local currentAmbientVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME))
	if currentAmbientVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME, currentAmbientVolume - 1)
	end
end

--Increase the Effects Volume
function ACD.IncreaseSFXVolume()
    local currentSFXVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME))
	if currentSFXVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, currentSFXVolume + 1)
	end
end

--Decrease the Effects Volume
function ACD.DecreaseSFXVolume()
    local currentSFXVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME))
	if currentSFXVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, currentSFXVolume - 1)
	end
end

--Increase the Footsteps Volume
function ACD.IncreaseFootstepsVolume()
    local currentFootstepsVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME))
	if currentFootstepsVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, currentFootstepsVolume + 1)
	end
end

--Decrease the Footsteps Volume
function ACD.DecreaseFootstepsVolume()
    local currentFootstepsVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME))
	if currentFootstepsVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME, currentFootstepsVolume - 1)
	end
end

--Increase the Interface Volume
function ACD.IncreaseUIVolume()
    local currentUIVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))
	if currentUIVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, currentUIVolume + 1)
	end
end

--Decrease the Interface Volume
function ACD.DecreaseUIVolume()
    local currentUIVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))
	if currentUIVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, currentUIVolume - 1)
	end
end

--Increase the Dialogue Volume
function ACD.IncreaseVOVolume()
    local currentVOVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	if currentVOVolume < 100 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, currentVOVolume + 1)
	end
end

--Decrease the Dialogue Volume
function ACD.DecreaseVOVolume()
    local currentVOVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
	if currentVOVolume > 0 then
		SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, currentVOVolume - 1)
	end
end