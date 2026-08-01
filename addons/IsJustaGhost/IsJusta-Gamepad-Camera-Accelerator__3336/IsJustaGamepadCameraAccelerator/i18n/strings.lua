------------------------------------------------
-- English localization
------------------------------------------------

local strings = {
	SI_IJA_GAMEPADCAMERAACCELERATOR_NORMAL	= "Default.",
	SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN	= "For Science!",
	
	SI_IJA_GAMEPADCAMERAACCELERATOR_MAX	= "Max Camera Speed",
	SI_IJA_GAMEPADCAMERAACCELERATOR_SLIDER_TOOTIP	= "1.05 is the the game's default max.",
	
	SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN_TOOTIP	= "This will allow you to go beyond the above slider's max of 5.",
	SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN_WARNING	= "Anything above 5 is not recommended.",
}

-- The description here is broken up into multiple lines to make it more manageable to edit.
local cameraSensitivity = GetString(SI_GAMEPAD_OPTIONS_CAMERA_SENSITIVITY)
local description = 'Adjusting the maximum camera speed changes the maximum the ' .. cameraSensitivity .. ' can be set to and, sets the game setting to that value.\n'
description = description .. 'With the maximum value being adjusted, ' .. cameraSensitivity .. ' can be adjusted anywhere from there to the minimum the game allows in "Options > Camera > ' .. cameraSensitivity .. '".\n\n'
description = description .. 'The 2 options above are.\n'
description = description .. '1\) <<1>>: this option allows you to set it from the game\'s default maximum to a maximum of 5.\n'
description = description .. '2\) <<2>>: this option allows you to set it from the game\'s default maximum to a maximum of 100. This option is not recommended to be used for anything besides getting a laugh.'
strings['SI_IJA_GAMEPADCAMERAACCELERATOR_DESCRIPTION'] = zo_strformat(description, strings['SI_IJA_GAMEPADCAMERAACCELERATOR_NORMAL'], strings['SI_IJA_GAMEPADCAMERAACCELERATOR_FORFUN'])

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end

