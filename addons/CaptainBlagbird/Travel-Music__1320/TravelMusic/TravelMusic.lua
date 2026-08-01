--[[

Travel Music
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddonName = "TravelMusic"


local function OnMountedStateChanged(eventCode, isMounted)
    local newSetting = isMounted and "1" or "0"
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, newSetting)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)