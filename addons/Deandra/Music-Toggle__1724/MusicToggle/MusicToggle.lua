MUSICTOGGLE = {}
MUSICTOGGLE.version = 1.0

ZO_CreateStringId("SI_BINDING_NAME_MUSICTOGGLE", "Toggle Music")

function ToggleMusic()
	local musicSetting = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED);
	if (musicSetting == "1") then
		musicSetting = "0";
		d("Music turned off.")
	else
		musicSetting = "1";
		d("Music turned on.")
	end
	
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, musicSetting);
end

SLASH_COMMANDS["/music"]= ToggleMusic