--[[
Audio Control Doctor
by @DrGerm on the North American Megaserver
Slash Commands in case anyone wanted to use them
--]]

SLASH_COMMANDS["/acd"] = function()
	d("|cE21E21Audio|r |cF6F6F6Control|r |cFFE55FDoctor|r |c888888by|r |cFFE55F@DrGerm|r |c888888on the North American Megaserver|r")
	d("|cE21E21Main Commands:|r")
	d("|cF6F6F6/acd|r |c888888= this menu|r")
	d("|cF6F6F6/acdstate|r |c888888= the state of each audio stream|r")
	d("|cF6F6F6/acdslash|r |c888888= list of slash commands|r")
	d("|cF6F6F6/acdhelp|r |c888888= gives a little help|r")
end

SLASH_COMMANDS["/acdstate"] = function()
	d("|cE21E21Audio|r |cF6F6F6Control|r |cFFE55FDoctor|r |c888888by|r |cFFE55F@DrGerm|r |c888888on the North American Megaserver|r")
	d("|cE21E21Current Sound States:|r")
	-- Find out of Master Volume is ON or OFF
    local currentMasterEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_ENABLED)
	local isMasterEnabled
		if (currentMasterEnabled == "1") then
			isMasterEnabled = "ON"
		else
			isMasterEnabled = "OFF"
		end
	local currentMasterVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AUDIO_VOLUME))
	-- Display if Master Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Master Volume|r |c888888= |r"..isMasterEnabled.."|c888888 set at |r"..currentMasterVolume.."%")
	
	-- Find out of Music Volume is ON or OFF
    local currentMusicEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED)
	local isMusicEnabled
		if (currentMusicEnabled == "1") then
			isMusicEnabled = "ON"
		else
			isMusicEnabled = "OFF"
		end
	local currentMusicVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME))
    -- Display if Music Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Music Volume|r |c888888= |r"..isMusicEnabled.."|c888888 set at |r"..currentMusicVolume.."%")
	
	-- Find out of Ambient Volume is ON or OFF
    local currentAmbientEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_ENABLED)
	local isAmbientEnabled
		if (currentAmbientEnabled == "1") then
			isAmbientEnabled = "ON"
		else
			isAmbientEnabled = "OFF"
		end
	local currentAmbientVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_AMBIENT_VOLUME))
    -- Display if Ambient Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Ambient Volume|r |c888888= |r"..isAmbientEnabled.."|c888888 set at |r"..currentAmbientVolume.."%")
	
	-- Find out of Effects Volume is ON or OFF
    local currentSFXEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_ENABLED)
	local isSFXEnabled
		if (currentSFXEnabled == "1") then
			isSFXEnabled = "ON"
		else
			isSFXEnabled = "OFF"
		end
	local currentSFXVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME))
    -- Display if Effects Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Effects Volume|r |c888888= |r"..isSFXEnabled.."|c888888 set at |r"..currentSFXVolume .."%")
	
		-- Find out of Footsteps Volume is ON or OFF
    local currentFootstepsEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_ENABLED)
	local isFootstepsEnabled
		if (currentFootstepsEnabled == "1") then
			isFootstepsEnabled = "ON"
		else
			isFootstepsEnabled = "OFF"
		end
	local currentFootstepsVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_FOOTSTEPS_VOLUME))
    -- Display if Footsteps Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Footsteps Volume|r |c888888= |r"..isFootstepsEnabled.."|c888888 set at |r"..currentFootstepsVolume.."%")
	
	-- Find out of Dialogue Volume is ON or OFF
	-- Reminder that VO = Dialogue
    local currentVOEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_ENABLED)
	local isVOEnabled
		if (currentVOEnabled == "1") then
			isVOEnabled = "ON"
		else
			isVOEnabled = "OFF"
		end
	local currentVOVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME))
    -- Display if Dialogue Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Dialogue Volume|r |c888888= |r"..isVOEnabled.."|c888888 set at |r"..currentVOVolume.."%")
	
	-- Find out of Interface Volume is ON or OFF
    local currentUIEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_ENABLED)
	local isUIEnabled
		if (currentUIEnabled == "1") then
			isUIEnabled = "ON"
		else
			isUIEnabled = "OFF"
		end
	local currentUIVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))
    -- Display if Interface Volume is ON or OFF and Level from 1 - 100
	d("|cF6F6F6Interface Volume|r |c888888= |r"..isUIEnabled.."|c888888 set at |r"..currentUIVolume.."%")
	
	-- Find out of Background Volume is ON or OFF
    local currentBackgroundEnabled = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_BACKGROUND_AUDIO)
	local isBackgroundEnabled
		if (currentBackgroundEnabled == "1") then
			isBackgroundEnabled = "ON"
		else
			isBackgroundEnabled = "OFF"
		end
    -- Display if Background Volume is ON or OFF
	d("|cF6F6F6Play in Background |r |c888888= |r"..isBackgroundEnabled)
end

SLASH_COMMANDS["/acdslash"] = function()
	d("|cE21E21Audio|r |cF6F6F6Control|r |cFFE55FDoctor|r |c888888by|r |cFFE55F@DrGerm|r |c888888on the North American Megaserver|r")
	d("|cE21E21Slash Commands for Audio Control Doctor:|r")
    d("|cF6F6F6/acdmaster|r |c888888= toggles the master volume|r")
	d("|cF6F6F6/acdmusic|r |c888888= toggles music volume|r")
	d("|cF6F6F6/acdambient|r |c888888= toggles ambient volume|r")
	d("|cF6F6F6/acdeffects|r |c888888= toggles sound effects volume|r")
	d("|cF6F6F6/acdfootsteps|r |c888888= toggles footsteps volume|r")
	d("|cF6F6F6/acddialogue|r |c888888= toggles dialogue volume|r")
	d("|cF6F6F6/acdinterface|r |c888888= toggles interface volume|r")
	d("|cF6F6F6/acdbackground|r |c888888= toggles playing in the background|r")
end

SLASH_COMMANDS["/acdmaster"] = function()
    ACD.ToggleMasterEnabled()
end

SLASH_COMMANDS["/acdmusic"] = function()
    ACD.ACD.ToggleMusicEnabled()
end

SLASH_COMMANDS["/acdambient"] = function()
    ACD.ToggleAmbientEnabled()
end

SLASH_COMMANDS["/acdeffects"] = function()
    ACD.ToggleSFXEnabled()
end

SLASH_COMMANDS["/acdfootsteps"] = function()
    ACD.ToggleFootstepsEnabled()
end

SLASH_COMMANDS["/acddialogue"] = function()
    ACD.ToggleVOEnabled()
end

SLASH_COMMANDS["/acdinterface"] = function()
    ACD.ToggleUIEnabled()
end

SLASH_COMMANDS["/acdbackground"] = function()
    ACD.ToggleBackgroundAudio()
end

SLASH_COMMANDS["/acdhelp"] = function()
	d("|cE21E21Audio|r |cF6F6F6Control|r |cFFE55FDoctor|r |c888888by|r |cFFE55F@DrGerm|r |c888888on the North American Megaserver|r")
	d("|cE21E21Where to Find Keybinding Settings:|r")
	d("|c888888Press|r |cF6F6F6Escape|r")
	d("|c888888Choose|r |cF6F6F6Controls|r")
	d("|c888888Choose|r |cF6F6F6Keybindings|r")
	d("|c888888Scroll down until you see|r |cE21E21Audio|r |cF6F6F6Control|r |cFFE55FDoctor|r")
end